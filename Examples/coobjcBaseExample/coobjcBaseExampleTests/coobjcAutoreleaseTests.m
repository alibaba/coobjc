//
//  coobjcAutoreleaseTests.m
//  coobjcBaseExampleTests
//
//  Copyright © 2018 Alibaba Group Holding Limited All rights reserved.
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

#import <XCTest/XCTest.h>
#import <Specta/Specta.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import <coobjc.h>
#import <coobjc/co_autorelease.h>

#   define RR_PUSH() objc_autoreleasePoolPush()
#   define RR_POP(p) objc_autoreleasePoolPop(p)
#   define RR_RETAIN(o) [o retain]
#   define RR_RELEASE(o) [o release]
#   define RR_AUTORELEASE(o) objc_autorelease(o)
#   define RR_RETAINCOUNT(o) [o retainCount]

extern id objc_autorelease(id obj);
extern void *
objc_autoreleasePoolPush(void);
extern void
objc_autoreleasePoolPop(void *context);

static int state;

static dispatch_queue_t get_test_queue(){
    static dispatch_queue_t q = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        q = dispatch_queue_create("test_queue", NULL);
    });
    return q;
}

static dispatch_queue_t get_test_queue1(){
    static dispatch_queue_t q = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        q = dispatch_queue_create("test_queue_1", NULL);
    });
    return q;
}

#define NESTED_COUNT 8

@interface Deallocator : NSObject @end
@implementation Deallocator
-(void) dealloc
{
    // testprintf("-[Deallocator %p dealloc]\n", self);
    state++;
    [super dealloc];
}
@end

@interface AutoreleaseDuringDealloc : NSObject @end
@implementation AutoreleaseDuringDealloc
-(void) dealloc
{
    state++;
    RR_AUTORELEASE([[Deallocator alloc] init]);
    [super dealloc];
}
@end

@interface AutoreleasePoolDuringDealloc : NSObject @end
@implementation AutoreleasePoolDuringDealloc
-(void) dealloc
{
    // caller's pool
    for (int i = 0; i < NESTED_COUNT; i++) {
        RR_AUTORELEASE([[Deallocator alloc] init]);
    }
    
    // local pool, popped
    void *pool = RR_PUSH();
    for (int i = 0; i < NESTED_COUNT; i++) {
        RR_AUTORELEASE([[Deallocator alloc] init]);
    }
    RR_POP(pool);
    
    // caller's pool again
    for (int i = 0; i < NESTED_COUNT; i++) {
        RR_AUTORELEASE([[Deallocator alloc] init]);
    }
    
    {
        static bool warned;
        if (!warned) NSLog(@"rdar://7138159 NSAutoreleasePool leaks");
        warned = true;
    }
    state += NESTED_COUNT;
    
    [super dealloc];
}
@end

void *autorelease_lots_fn(void *singlePool)
{
    // Enough to blow out the stack if AutoreleasePoolPage is recursive.
    const int COUNT = 1024*1024;
    state = 0;
    
    int p = 0;
    void **pools = (void**)malloc((COUNT+1) * sizeof(void*));
    pools[p++] = RR_PUSH();
    
    id obj = RR_AUTORELEASE([[Deallocator alloc] init]);
    
    // last pool has only 1 autorelease in it
    pools[p++] = RR_PUSH();
    
    for (int i = 0; i < COUNT; i++) {
        if (rand() % 1000 == 0  &&  !singlePool) {
            pools[p++] = RR_PUSH();
        } else {
            RR_AUTORELEASE(RR_RETAIN(obj));
        }
    }
    
    assert(state == 0);
    while (--p) {
        RR_POP(pools[p]);
    }
    assert(state == 0);
    assert(RR_RETAINCOUNT(obj) == 1);
    RR_POP(pools[0]);
    assert(state == 1);
    free(pools);
    
    return NULL;
}

void *nsthread_fn(void *arg __unused)
{
    [NSThread currentThread];
    void *pool = RR_PUSH();
    RR_AUTORELEASE([[Deallocator alloc] init]);
    RR_POP(pool);
    return NULL;
}

@interface coobjcAutoreleaseTests : XCTestCase

@end

@implementation coobjcAutoreleaseTests

- (COPromise<NSNumber*>*)makeAsynPromise{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            resolve(@1);
        });
    }];
}

- (void)setUp {
    [super setUp];
    co_autoreleaseInit();
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)cycle{
    // Normal autorelease.
    NSLog(@"-- Normal autorelease.");
    {
        void *pool = RR_PUSH();
        state = 0;
        RR_AUTORELEASE([[Deallocator alloc] init]);
        XCTAssert(state == 0);
        RR_POP(pool);
        XCTAssert(state == 1);
    }
    
    // Autorelease during dealloc during autoreleasepool-pop.
    // That autorelease is handled by the popping pool, not the one above it.
    printf("-- Autorelease during dealloc during autoreleasepool-pop.\n");
    {
        void *pool = RR_PUSH();
        state = 0;
        RR_AUTORELEASE([[AutoreleaseDuringDealloc alloc] init]);
        XCTAssert(state == 0);
        RR_POP(pool);
        XCTAssert(state == 2);
    }
    
    // Autorelease pool during dealloc during autoreleasepool-pop.
    printf("-- Autorelease pool during dealloc during autoreleasepool-pop.\n");
    {
        void *pool = RR_PUSH();
        state = 0;
        RR_AUTORELEASE([[AutoreleasePoolDuringDealloc alloc] init]);
        XCTAssert(state == 0);
        RR_POP(pool);
        XCTAssert(state == 4 * NESTED_COUNT);
    }
    
    // Top-level thread pool popped normally.
    printf("-- Thread-level pool popped normally.\n");
    {
        state = 0;
        co_launch_onqueue(get_test_queue1(), ^{
            void *pool = RR_PUSH();
            RR_AUTORELEASE([[Deallocator alloc] init]);
            RR_POP(pool);
        });
        co_delay(0.1);
        XCTAssert(state == 1);
    }
    
    
    // Autorelease with no pool.
    printf("-- Autorelease with no pool.\n");
    {
        state = 0;
        co_launch_onqueue(get_test_queue1(), ^{
            @autoreleasepool{
                RR_AUTORELEASE([[Deallocator alloc] init]);
            }
        });
        co_delay(0.1);
        XCTAssert(state == 1);
    }
    
    // Autorelease with no pool after popping the top-level pool.
    printf("-- Autorelease with no pool after popping the last pool.\n");
    {
        state = 0;
        co_launch_onqueue(get_test_queue1(), ^{
            //NSAutoreleasePool *pool1 = [[NSAutoreleasePool alloc] init];
            @autoreleasepool{
                void *pool = RR_PUSH();
                RR_AUTORELEASE([[Deallocator alloc] init]);
                RR_POP(pool);
                RR_AUTORELEASE([[Deallocator alloc] init]);
            }
            
           // [pool1 release];
        });
        co_delay(0.1);

        XCTAssert(state == 2);
    }
    
    // Top-level thread pool not popped.
    // The runtime should clean it up.
    {
        static bool warned;
        if (!warned) printf("rdar://7138159 NSAutoreleasePool leaks\n");
        warned = true;
    }
    
    // Intermediate pool not popped.
    // Popping the containing pool should clean up the skipped pool first.

}

- (void)slow_cycle{
    // Large autorelease stack.
    // Do this only once because it's slow.
    printf("-- Large autorelease stack.\n");
    {
        // limit stack size: autorelease pop should not be recursive
        co_launch_onqueue(get_test_queue1(), ^{
            autorelease_lots_fn(NULL);
        });
        co_delay(2.0);
    }
    
    // Single large autorelease pool.
    // Do this only once because it's slow.
    printf("-- Large autorelease pool.\n");
    {
        // limit stack size: autorelease pop should not be recursive
        co_launch_onqueue(get_test_queue1(), ^{
            autorelease_lots_fn((void*)1);
        });
        co_delay(2.0);
    }
}

- (void)testEnableAutoreleasePool{
    co_enableAutorelease = YES;
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    co_launch_onqueue(get_test_queue(), ^{
        state = 0;
        void *ctx = co_autoreleasePoolPush();
        
        coroutine_t *routine = coroutine_self();
        XCTAssert(routine->autoreleasepage != NULL);
        for (int i = 0; i < 10; i++) {
            RR_AUTORELEASE([[Deallocator alloc] init]);
        }
        
        co_autoreleasePoolPop(ctx);
        
        XCTAssert(state == 10);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [e fulfill];
        });
    });
    [self waitForExpectations:@[e] timeout:1000];
    
}

- (void)testEnableAutoreleasePoolAwait{
    co_enableAutorelease = YES;
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    co_launch_onqueue(get_test_queue(), ^{
        state = 0;
        void *ctx = co_autoreleasePoolPush();
        
        coroutine_t *routine = coroutine_self();
        XCTAssert(routine->autoreleasepage != NULL);
        for (int i = 0; i < 10; i++) {
            RR_AUTORELEASE([[Deallocator alloc] init]);
        }
        id val = await([self makeAsynPromise]);
        //TODO: NSLog会导致autorelease崩溃
        printf("%d\n", [val intValue]);
        for (int i = 0; i < 10; i++) {
            RR_AUTORELEASE([[Deallocator alloc] init]);
        }
        
        co_autoreleasePoolPop(ctx);
        
        XCTAssert(state == 20);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [e fulfill];
        });
    });
    [self waitForExpectations:@[e] timeout:1000];
    
}

- (void)testEnableAutoreleasePoolNSLog{
    co_enableAutorelease = YES;
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    co_launch_onqueue(get_test_queue(), ^{
        state = 0;
        void *ctx = co_autoreleasePoolPush();
        
        coroutine_t *routine = coroutine_self();
        XCTAssert(routine->autoreleasepage != NULL);
        for (int i = 0; i < 10; i++) {
            RR_AUTORELEASE([[Deallocator alloc] init]);
        }
        NSLog(@"test");
        for (int i = 0; i < 10; i++) {
            RR_AUTORELEASE([[Deallocator alloc] init]);
        }
        
        co_autoreleasePoolPop(ctx);
        
        XCTAssert(state == 20);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [e fulfill];
        });
    });
    [self waitForExpectations:@[e] timeout:1000];
    
}

- (void)testDisableAutoreleasePool{
    co_enableAutorelease = NO;
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    co_launch_onqueue(get_test_queue(), ^{
        state = 0;
        void *ctx = co_autoreleasePoolPush();
        
        coroutine_t *routine = coroutine_self();
        XCTAssert(routine->autoreleasepage == NULL);
        for (int i = 0; i < 10; i++) {
            RR_AUTORELEASE([[Deallocator alloc] init]);
        }
        NSLog(@"test");
        for (int i = 0; i < 10; i++) {
            RR_AUTORELEASE([[Deallocator alloc] init]);
        }
        
        co_autoreleasePoolPop(ctx);
        
        XCTAssert(state == 0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [e fulfill];
        });
    });
    [self waitForExpectations:@[e] timeout:1000];
}

- (void)testAutoreleasePoolNested{
    co_enableAutorelease = YES;
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    co_launch_onqueue(get_test_queue(), ^{
        state = 0;
        void *ctx = co_autoreleasePoolPush();
        
        coroutine_t *routine = coroutine_self();
        XCTAssert(routine->autoreleasepage != NULL);
        {
            void *ctx1 = co_autoreleasePoolPush();
            for (int i = 0; i < 10; i++) {
                RR_AUTORELEASE([[Deallocator alloc] init]);
            }
            co_autoreleasePoolPop(ctx1);
        }
        
        id val = await([self makeAsynPromise]);
        //TODO: NSLog会导致autorelease崩溃
        NSLog(@"%@", val);
        {
            void *ctx1 = co_autoreleasePoolPush();
            for (int i = 0; i < 10; i++) {
                RR_AUTORELEASE([[Deallocator alloc] init]);
            }
            co_autoreleasePoolPop(ctx1);
        }
        val = await([self makeAsynPromise]);
        //TODO: NSLog会导致autorelease崩溃
        NSLog(@"%@", val);
        
        for (int i = 0; i < 10; i++) {
            RR_AUTORELEASE([[Deallocator alloc] init]);
        }

        co_autoreleasePoolPop(ctx);
        
        XCTAssert(state == 30);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [e fulfill];
        });
    });
    [self waitForExpectations:@[e] timeout:1000];
}

- (void)testAutoreleasePoolNestedUnbanlance{
    co_enableAutorelease = YES;
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    co_launch_onqueue(get_test_queue(), ^{
        state = 0;
        void *ctx = co_autoreleasePoolPush();
        
        coroutine_t *routine = coroutine_self();
        XCTAssert(routine->autoreleasepage != NULL);
        {
            __unused void *ctx1 = co_autoreleasePoolPush();
            for (int i = 0; i < 10; i++) {
                RR_AUTORELEASE([[Deallocator alloc] init]);
            }
//            co_autoreleasePoolPop(ctx1);
        }
        
        id val = await([self makeAsynPromise]);
        //TODO: NSLog会导致autorelease崩溃
        NSLog(@"%@", val);
        {
            void *ctx1 = co_autoreleasePoolPush();
            for (int i = 0; i < 10; i++) {
                RR_AUTORELEASE([[Deallocator alloc] init]);
            }
            co_autoreleasePoolPop(ctx1);
        }
        val = await([self makeAsynPromise]);
        //TODO: NSLog会导致autorelease崩溃
        NSLog(@"%@", val);
        
        for (int i = 0; i < 10; i++) {
            RR_AUTORELEASE([[Deallocator alloc] init]);
        }
        
        co_autoreleasePoolPop(ctx);
        
        XCTAssert(state == 30);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [e fulfill];
        });
    });
    [self waitForExpectations:@[e] timeout:1000];
}

- (void)testAutoreleaseCycle{
    // inflate the refcount side table so it doesn't show up in leak checks
    co_enableAutorelease = YES;
    XCTestExpectation *e = [self expectationWithDescription:@"test"];

    co_launch_onqueue(get_test_queue(), ^{
        state = 0;
        {
            int count = 10000;
            id *objs = (id *)malloc(count*sizeof(id));
            for (int i = 0; i < count; i++) {
                objs[i] = RR_RETAIN([NSObject new]);
            }
            for (int i = 0; i < count; i++) {
                RR_RELEASE(objs[i]);
                RR_RELEASE(objs[i]);
            }
            free(objs);
        }
        
        // inflate NSAutoreleasePool's instance cache
        {
            int count = 32;
            id *objs = (id *)malloc(count * sizeof(id));
            for (int i = 0; i < count; i++) {
                objs[i] = [[NSAutoreleasePool alloc] init];
            }
            for (int i = 0; i < count; i++) {
                [objs[count-i-1] release];
            }
            
            free(objs);
        }
        
        // preheat
        {
            for (int i = 0; i < 100; i++) {
                [self cycle];
            }
            
            [self slow_cycle];
        }
        [e fulfill];
    });
    
    [self waitForExpectations:@[e] timeout:1000];

}


@end
