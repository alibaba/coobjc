//
//  co_autorelease.m
//  coobjc
//
//  Copyright © 2018 Alibaba Group Holding Limited All rights reserved.
//  Copyright (c) 1999-2003 Apple Computer, Inc. All Rights Reserved.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

#import "co_autorelease.h"
#import "coobjc.h"
#include <malloc/malloc.h>
#include <stdint.h>
#include <stdbool.h>
#include <mach/mach.h>
#include <mach-o/dyld.h>
#include <mach-o/nlist.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <libkern/OSAtomic.h>
#include <Block.h>
#include <map>
#include <execinfo.h>
#import "co_errors.h"
#import <pthread/pthread.h>
#import <fishhook/fishhook.h>
#import <objc/runtime.h>

BOOL co_enableAutorelease = YES;

// Define SUPPORT_TAGGED_POINTERS=1 to enable tagged pointer objects
// Be sure to edit tagged pointer SPI in objc-internal.h as well.
#if !(__OBJC2__  &&  __LP64__)
#   define SUPPORT_TAGGED_POINTERS 0
#else
#   define SUPPORT_TAGGED_POINTERS 1
#endif

// Define SUPPORT_MSB_TAGGED_POINTERS to use the MSB
// as the tagged pointer marker instead of the LSB.
// Be sure to edit tagged pointer SPI in objc-internal.h as well.
#if !SUPPORT_TAGGED_POINTERS  ||  !TARGET_OS_IPHONE
#   define SUPPORT_MSB_TAGGED_POINTERS 0
#else
#   define SUPPORT_MSB_TAGGED_POINTERS 1
#endif

#if SUPPORT_MSB_TAGGED_POINTERS
#   define TAG_MASK (1ULL<<63)
#   define TAG_SLOT_SHIFT 60
#   define TAG_PAYLOAD_LSHIFT 4
#   define TAG_PAYLOAD_RSHIFT 4
#else
#   define TAG_MASK 1
#   define TAG_SLOT_SHIFT 0
#   define TAG_PAYLOAD_LSHIFT 0
#   define TAG_PAYLOAD_RSHIFT 4
#endif

/* Use this for functions that are intended to be breakpoint hooks.
 If you do not, the compiler may optimize them away.
 BREAKPOINT_FUNCTION( void stop_on_error(void) ); */
#   define BREAKPOINT_FUNCTION(prototype)                             \
OBJC_EXTERN __attribute__((noinline, used, visibility("hidden"))) \
prototype { asm(""); }

BREAKPOINT_FUNCTION(void co_autoreleaseNoPool(id obj));


static BOOL DebugMissingPools = NO;
static BOOL DebugPoolAllocation = NO;
static BOOL PrintPoolHiwat = NO;

/***********************************************************************
 Autorelease pool implementation
 
 A Coroutine's autorelease pool is a stack of pointers.
 Each pointer is either an object to release, or POOL_SENTINEL which is
 an autorelease pool boundary.
 A pool token is a pointer to the POOL_SENTINEL for that pool. When
 the pool is popped, every object hotter than the sentinel is released.
 The stack is divided into a doubly-linked list of pages. Pages are added
 and deleted as necessary.
 Thread-local storage points to the hot page, where newly autoreleased
 objects are stored.
 **********************************************************************/

namespace {
    
    struct co_magic_t {
        static const uint32_t M0 = 0xA1A1A1A1;
#   define M1 "AUTORELEASE!"
        static const size_t M1_len = 12;
        uint32_t m[4];
        
        co_magic_t() {
            assert(M1_len == strlen(M1));
            assert(M1_len == 3 * sizeof(m[1]));
            
            m[0] = M0;
            strncpy((char *)&m[1], M1, M1_len);
        }
        
        ~co_magic_t() {
            m[0] = m[1] = m[2] = m[3] = 0;
        }
        
        bool check() const {
            return (m[0] == M0 && 0 == strncmp((char *)&m[1], M1, M1_len));
        }
        
        bool fastcheck() const {
#if DEBUG
            return check();
#else
            return (m[0] == M0);
#endif
        }
        
#   undef M1
    };
    
#   define CO_AUTORELEASE_PAGE_MASK        0x0000088ffffffff8ULL

    
    class COAutoreleasePoolPage
    {
        
    public:
#define POOL_SENTINEL nil
//        static pthread_key_t const key = AUTORELEASE_POOL_KEY;
        static uint8_t const SCRIBBLE = 0xA3;  // 0xA3A3A3A3 after releasing
        static size_t const SIZE = PAGE_MAX_SIZE;

        static size_t const COUNT = SIZE / sizeof(id);
        
        uintptr_t bitMask;
        co_magic_t const magic;
        id *next;
        coroutine_t * const routine;
        COAutoreleasePoolPage * const parent;
        COAutoreleasePoolPage *child;
        uint32_t const depth;
        uint32_t hiwat;
        
        // SIZE-sizeof(*this) bytes of contents follow
        
        static void * operator new(size_t size) {
            return malloc_zone_memalign(malloc_default_zone(), SIZE, SIZE);
        }
        static void operator delete(void * p) {
            return free(p);
        }
        
        inline void protect() {

        }
        
        inline void unprotect() {

        }
        
        COAutoreleasePoolPage(COAutoreleasePoolPage *newParent)
        : magic(), next(begin()), routine(coroutine_self()),
        parent(newParent), child(nil),
        depth(parent ? 1+parent->depth : 0),
        hiwat(parent ? parent->hiwat : 0)
        {
            bitMask = (uintptr_t)CO_AUTORELEASE_PAGE_MASK;
            if (parent) {
                parent->check();
                assert(!parent->child);
                parent->unprotect();
                parent->child = this;
                parent->protect();
            }
            protect();
        }
        
        ~COAutoreleasePoolPage()
        {
            check();
            unprotect();
            assert(empty());
            
            // Not recursive: we don't want to blow out the stack
            // if a thread accumulates a stupendous amount of garbage
            assert(!child);
        }
        
        
        void busted(bool die = true)
        {
            co_magic_t right;
            if (die) {
                co_fatal("co autorelease pool page %p corrupted\n"
                         "  magic     0x%08x 0x%08x 0x%08x 0x%08x\n"
                         "  should be 0x%08x 0x%08x 0x%08x 0x%08x\n"
                         "  coroutine   %p\n"
                         "  should be %p\n",
                         this,
                         magic.m[0], magic.m[1], magic.m[2], magic.m[3],
                         right.m[0], right.m[1], right.m[2], right.m[3],
                         this->routine, coroutine_self());
            }
            else{
                co_inform("co autorelease pool page %p corrupted\n"
                          "  magic     0x%08x 0x%08x 0x%08x 0x%08x\n"
                          "  should be 0x%08x 0x%08x 0x%08x 0x%08x\n"
                          "  coroutine   %p\n"
                          "  should be %p\n",
                          this,
                          magic.m[0], magic.m[1], magic.m[2], magic.m[3],
                          right.m[0], right.m[1], right.m[2], right.m[3],
                          this->routine, coroutine_self());
            }
        }
        
        void check(bool die = true)
        {
            if (!magic.check() || (this->routine != coroutine_self())) {
                busted(die);
            }
        }
        
        void fastcheck(bool die = true)
        {
            if (! magic.fastcheck()) {
                busted(die);
            }
        }
        
        
        id * begin() {
            return (id *) ((uint8_t *)this+sizeof(*this));
        }
        
        id * end() {
            return (id *) ((uint8_t *)this+SIZE);
        }
        
        bool empty() {
            return next == begin();
        }
        
        bool full() {
            return next == end();
        }
        
        bool lessThanHalfFull() {
            return (next - begin() < (end() - begin()) / 2);
        }
        
        id *add(id obj)
        {
            assert(!full());
            unprotect();
            id *ret = next;  // faster than `return next-1` because of aliasing
            *next++ = obj;
            protect();
            return ret;
        }
        
        void releaseAll()
        {
            releaseUntil(begin());
        }
        
        void releaseUntil(id *stop)
        {
            // Not recursive: we don't want to blow out the stack
            // if a thread accumulates a stupendous amount of garbage
            
            while (this->next != stop) {
                // Restart from hotPage() every time, in case -release
                // autoreleased more objects
                COAutoreleasePoolPage *page = hotPage();
                
                // fixme I think this `while` can be `if`, but I can't prove it
                while (page->empty()) {
                    page = page->parent;
                    setHotPage(page);
                }
                
                page->unprotect();
                id obj = *--page->next;
                memset((void*)page->next, SCRIBBLE, sizeof(*page->next));
                page->protect();
                
                if (obj != POOL_SENTINEL) {
                    [obj release];
                    //objc_release(obj);
                }
            }
            
            setHotPage(this);
            
#if DEBUG
            // we expect any children to be completely empty
            for (COAutoreleasePoolPage *page = child; page; page = page->child) {
                assert(page->empty());
            }
#endif
        }
        
        void kill()
        {
            // Not recursive: we don't want to blow out the stack
            // if a thread accumulates a stupendous amount of garbage
            COAutoreleasePoolPage *page = this;
            while (page->child) page = page->child;
            
            COAutoreleasePoolPage *deathptr;
            do {
                deathptr = page;
                page = page->parent;
                if (page) {
                    page->unprotect();
                    page->child = nil;
                    page->protect();
                }
                delete deathptr;
            } while (deathptr != this);
        }
        
        static void routine_dealloc(void *p)
        {
            // reinstate TLS value while we work
            setHotPage((COAutoreleasePoolPage *)p);
            
            if (COAutoreleasePoolPage *page = coldPage()) {
                if (!page->empty()) pop(page->begin());  // pop all of the pools
                page->kill();  // free all of the pages

            }
            
            // clear TLS value so TLS destruction doesn't loop
            setHotPage(nil);
        }
        
        static COAutoreleasePoolPage *pageForPointer(const void *p)
        {
            return pageForPointer((uintptr_t)p);
        }
        
        static COAutoreleasePoolPage *pageForPointer(uintptr_t p)
        {
            COAutoreleasePoolPage *result;
            uintptr_t offset = p % SIZE;
            
            assert(offset >= sizeof(COAutoreleasePoolPage));
            
            result = (COAutoreleasePoolPage *)(p - offset);
            result->fastcheck();
            
            return result;
        }
        
        
        static inline COAutoreleasePoolPage *hotPage()
        {
            COAutoreleasePoolPage *result = (COAutoreleasePoolPage *)(coroutine_self()->autoreleasepage);
            if (result) result->fastcheck();
            return result;
        }
        
        static inline void setHotPage(COAutoreleasePoolPage *page)
        {
            if (page) page->fastcheck();
            coroutine_t  *routine = coroutine_self();
            if (routine) {
                routine->autoreleasepage = (void*)page;
            }
        }
        
        static inline COAutoreleasePoolPage *coldPage()
        {
            COAutoreleasePoolPage *result = hotPage();
            if (result) {
                while (result->parent) {
                    result = result->parent;
                    result->fastcheck();
                }
            }
            return result;
        }
        
        
        static inline id *autoreleaseFast(id obj)
        {
            COAutoreleasePoolPage *page = hotPage();
            if (page && !page->full()) {
                return page->add(obj);
            } else if (page) {
                return autoreleaseFullPage(obj, page);
            } else {
                return autoreleaseNoPage(obj);
            }
        }
        
        static __attribute__((noinline))
        id *autoreleaseFullPage(id obj, COAutoreleasePoolPage *page)
        {
            // The hot page is full.
            // Step to the next non-full page, adding a new page if necessary.
            // Then add the object to that page.
            assert(page == hotPage());
            assert(page->full());
            
            do {
                if (page->child) page = page->child;
                else page = new COAutoreleasePoolPage(page);
            } while (page->full());
            
            setHotPage(page);
            return page->add(obj);
        }
        
        static __attribute__((noinline))
        id *autoreleaseNoPage(id obj)
        {
            // No pool in place.
            assert(!hotPage());
            
            if (obj != POOL_SENTINEL  &&  DebugMissingPools) {
                // We are pushing an object with no pool in place,
                // and no-pool debugging was requested by environment.
                co_inform("MISSING POOLS: Object %p of class %s "
                             "autoreleased with no pool in place - "
                             "just leaking - break on "
                             "objc_autoreleaseNoPool() to debug",
                             (void*)obj, object_getClassName(obj));
                co_autoreleaseNoPool(obj);
                return nil;
            }
            
            // Install the first page.
            COAutoreleasePoolPage *page = new COAutoreleasePoolPage(nil);
            setHotPage(page);
            
            // Push an autorelease pool boundary if it wasn't already requested.
            if (obj != POOL_SENTINEL) {
                page->add(POOL_SENTINEL);
            }
            
            // Push the requested object.
            return page->add(obj);
        }
        
        
        static __attribute__((noinline))
        id *autoreleaseNewPage(id obj)
        {
            COAutoreleasePoolPage *page = hotPage();
            if (page) return autoreleaseFullPage(obj, page);
            else return autoreleaseNoPage(obj);
        }
        
    public:
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-objc-pointer-introspection"
        static inline BOOL isTaggedPointer(id obj){
            return ((uintptr_t)obj & TAG_MASK);

        }
#pragma clang diagnostic pop
        
        static inline id autorelease(id obj)
        {
            assert(obj);
            assert(!isTaggedPointer(obj));
            id *dest __unused = autoreleaseFast(obj);
            assert(!dest  ||  *dest == obj);
            return obj;
        }
        
        
        static inline void *push()
        {
            id *dest;
            if (DebugPoolAllocation) {
                // Each autorelease pool starts on a new pool page.
                dest = autoreleaseNewPage(POOL_SENTINEL);
            } else {
                dest = autoreleaseFast(POOL_SENTINEL);
            }
            assert(*dest == POOL_SENTINEL);
            return dest;
        }
        
        static inline void pop(void *token)
        {
            COAutoreleasePoolPage *page;
            id *stop;
            
            page = pageForPointer(token);
            stop = (id *)token;
            if (DebugPoolAllocation  &&  *stop != POOL_SENTINEL) {
                // This check is not valid with DebugPoolAllocation off
                // after an autorelease with a pool page but no pool in place.
                co_fatal("invalid or prematurely-freed autorelease pool %p; ",
                            token);
            }
            
            if (PrintPoolHiwat) printHiwat();
            
            page->releaseUntil(stop);
            
            // memory: delete empty children
            if (DebugPoolAllocation  &&  page->empty()) {
                // special case: delete everything during page-per-pool debugging
                COAutoreleasePoolPage *parent = page->parent;
                page->kill();
                setHotPage(parent);
            } else if (DebugMissingPools  &&  page->empty()  &&  !page->parent) {
                // special case: delete everything for pop(top)
                // when debugging missing autorelease pools
                page->kill();
                setHotPage(nil);
            }
            else if (page->child) {
                // hysteresis: keep one empty child if page is more than half full
                if (page->lessThanHalfFull()) {
                    page->child->kill();
                }
                else if (page->child->child) {
                    page->child->child->kill();
                }
            }
        }
        
        static void init()
        {
//            int r __unused = pthread_key_init_np(AutoreleasePoolPage::key,
//                                                 AutoreleasePoolPage::tls_dealloc);
            //assert(r == 0);
        }
        
        void print()
        {
            co_inform("[%p]  ................  PAGE %s %s %s", this,
                         full() ? "(full)" : "",
                         this == hotPage() ? "(hot)" : "",
                         this == coldPage() ? "(cold)" : "");
            check(false);
            for (id *p = begin(); p < next; p++) {
                if (*p == POOL_SENTINEL) {
                    co_inform("[%p]  ################  POOL %p", p, p);
                } else {
                    co_inform("[%p]  %#16lx  %s",
                                 p, (unsigned long)*p, object_getClassName(*p));
                }
            }
        }
        
        static void printAll()
        {
            co_inform("##############");
            co_inform("AUTORELEASE POOLS for routine %p", coroutine_self());
            
            COAutoreleasePoolPage *page;
            ptrdiff_t objects = 0;
            for (page = coldPage(); page; page = page->child) {
                objects += page->next - page->begin();
            }
            co_inform("%llu releases pending.", (unsigned long long)objects);
            
            for (page = coldPage(); page; page = page->child) {
                page->print();
            }
            
            co_inform("##############");
        }
        
        static void printHiwat()
        {
            // Check and propagate high water mark
            // Ignore high water marks under 256 to suppress noise.
            COAutoreleasePoolPage *p = hotPage();
            uint32_t mark = p->depth*COUNT + (uint32_t)(p->next - p->begin());
            if (mark > p->hiwat  &&  mark > 256) {
                for( ; p; p = p->parent) {
                    p->unprotect();
                    p->hiwat = mark;
                    p->protect();
                }
                
                co_inform("POOL HIGHWATER: new high water mark of %u "
                             "pending autoreleases for routine %p:",
                             mark, coroutine_self());
                
                void *stack[128];
                int count = backtrace(stack, sizeof(stack)/sizeof(stack[0]));
                char **sym = backtrace_symbols(stack, count);
                for (int i = 0; i < count; i++) {
                    co_inform("POOL HIGHWATER:     %s", sym[i]);
                }
                free(sym);
            }
        }
        
#undef POOL_SENTINEL
    };
    
    // anonymous namespace
};

void co_autoreleasePoolDealloc(void *p){
    COAutoreleasePoolPage::routine_dealloc(p);
}

void * co_autoreleasePoolPush(void){
    if (!co_enableAutorelease) {
        return nil;
    }
    return COAutoreleasePoolPage::push();
}
void co_autoreleasePoolPop(void *ctxt){
    if (!co_enableAutorelease) {
        return;
    }
    return COAutoreleasePoolPage::pop(ctxt);
}

void co_autoreleasePoolPrint(){
    if (!co_enableAutorelease) {
        return;
    }
    COAutoreleasePoolPage::printAll();
}

id co_autoreleaseObj(id obj){
    if (!obj) {
        return obj;
    }
    if (COAutoreleasePoolPage::isTaggedPointer(obj)) {
        return obj;
    }
    return COAutoreleasePoolPage::autorelease(obj);
}


static void (*orig_autorelease_pop)(void *ctx);
static void* (*orig_autorelease_push)(void);
static id (*orig_autorelease_obj)(id);

static BOOL co_is_autoreleasepage(void *ctx){
    uintptr_t address = (uintptr_t)ctx;
    uintptr_t baseAddress = (address / PAGE_MAX_SIZE) * PAGE_MAX_SIZE;
    COAutoreleasePoolPage *page = (COAutoreleasePoolPage*)baseAddress;
    if (page->bitMask == (uintptr_t)CO_AUTORELEASE_PAGE_MASK) {
        return YES;
    }
    return NO;
}

void co_hook_autorelease_pop(void *ctx){
    if (co_enableAutorelease && coroutine_self() && co_is_autoreleasepage(ctx)) {
        co_autoreleasePoolPop(ctx);
    }
    else{
        orig_autorelease_pop(ctx);
    }
}

void *co_hook_autorelease_push(void){
    if (co_enableAutorelease && coroutine_self()) {
        return co_autoreleasePoolPush();
    }
    else{
        return orig_autorelease_push();
    }
}

id co_hook_autorelease_obj(id obj){
    if (co_enableAutorelease){
        coroutine_t *routine = coroutine_self();
        if (routine && routine->autoreleasepage) {
            return co_autoreleaseObj(obj);
        }
    }
    return orig_autorelease_obj(obj);
}

@interface NSArray (fix_autorelease_crash)

+ (void)co_hook_autorelease;

@end

@implementation NSArray (fix_autorelease_crash)

+ (void)co_hook_autorelease{
    {
        Method m1 = class_getInstanceMethod(self, @selector(enumerateObjectsUsingBlock:));
        Method m2 = class_getInstanceMethod(self, @selector(co_enumerateObjectsUsingBlock_proxy:));
        method_exchangeImplementations(m1, m2);
    }
}

- (void)co_enumerateObjectsUsingBlock_proxy:(void (^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block{
    if (co_enableAutorelease) {
        for (NSUInteger index = 0; index < self.count; index++) {
            BOOL stop = NO;
            id obj = self[index];
            void *ctx = co_hook_autorelease_push();

            block(obj, index, &stop);
            
            co_hook_autorelease_pop(ctx);
            if (stop) {
                break;
            }
        }
    }
    else{
        [self co_enumerateObjectsUsingBlock_proxy:block];
    }
}


@end

void co_autoreleaseInit(void){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rebind_symbols((struct rebinding[3]){{"objc_autoreleasePoolPop", (void*)co_hook_autorelease_pop, (void **)&orig_autorelease_pop},{"objc_autoreleasePoolPush", (void*)co_hook_autorelease_push, (void **)&orig_autorelease_push}, {"objc_autorelease", (void*)co_hook_autorelease_obj, (void **)&orig_autorelease_obj}}, 3);
        [NSArray co_hook_autorelease];
    });
}
