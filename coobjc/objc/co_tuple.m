//
//  co_tuple.m
//  coobjc
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

#import "co_tuple.h"

#if __has_feature(objc_arc)
#define arc_unsafe_unretained __unsafe_unretained
#define arc_autoreleasing __autoreleasing
#define arc_bridge(t, x) ((__bridge t)x)
#else
#define arc_unsafe_unretained
#define arc_autoreleasing
#define arc_bridge(t, x) (x)
#endif

id co_tupleSentinel() {
    static id sentin;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sentin = [[NSObject alloc] init];
    });
    return sentin;
}

#ifdef DEBUG

int co_tuple_dealloc_count = 0;
int co_untuple_dealloc_count = 0;

#endif

void** co_unpackSentinel(){
    static id sentin;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sentin = [[NSObject alloc] init];
    });
    return (void**)&sentin;
}

@implementation COTuple
{
    NSPointerArray* storage;
}


- (NSPointerArray*)_storage {
    return storage;
}
- (void)_setStorage:(NSPointerArray*)newstorage {
    storage = newstorage;
}

- (int)count {
    return (int)storage.count;
}

// Initialization
- (id)init {
    self = [super init];
    if (!self)
        return nil;
    
    storage = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality];
    
    return self;
}
- (id)initWithArray:(NSArray*)arr {
    self = [self init];
    if (!self)
        return nil;
    
    for (id obj in arr) {
        [storage addPointer:arc_bridge(void*, obj)];
    }
    
    return self;
}
- (id)initWithObjects:(id)objects, ... {
    self = [self init];
    if (!self)
        return nil;
    
    va_list ap;
    va_start(ap, objects);
    
    id obj = objects;
    id sentin = co_tupleSentinel();
    while (obj != sentin) {
        [storage addPointer:arc_bridge(void*, obj)];
        obj = va_arg(ap, id);
    }
    va_end(ap);
    
    return self;
}

// Protocolic Obligations
//- (id)copyWithZone:(NSZone *)zone {
//    id newtup = [[[self class] alloc] init];
//    [newtup _setStorage:[[self _storage] copy]];
//    return newtup;
//}
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id arc_unsafe_unretained [])stackbuf count:(NSUInteger)len {
    return [storage countByEnumeratingWithState:state objects:stackbuf count:len];
}

// Getting an object at an index
- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return [self objectAtIndex:(int)idx];
}
- (id)objectAtIndex:(int)idx {
    if (idx < 0 || idx >= (int)[storage count])
        return nil;
    return (__strong id)[storage pointerAtIndex:idx];
}

- (id)first {
    return [self objectAtIndex:0];
}
- (id)second {
    return [self objectAtIndex:1];
}
- (id)third {
    return [self objectAtIndex:2];
}

// Unpacking
- (void)unpack:(id*)pointypointers, ... {
    
    va_list ap;
    va_start(ap, pointypointers);
    
    arc_autoreleasing id* pp = pointypointers;
    int i = 0;
    while (pp != NULL) {
        *pp = [self objectAtIndex:i];
        
        pp = va_arg(ap, arc_autoreleasing id*);
        i++;
    }
    va_end(ap);
    
}

- (void)dealloc
{
    if (storage) {
        [storage release];
        storage = nil;
    }
#ifdef DEBUG
    
    co_tuple_dealloc_count++;
    
#endif
    [super dealloc];
}

@end

@implementation COTupleUnpack{
    NSMutableArray *storage;
}

@synthesize tuple = _tuple;

- (void)setTuple:(COTuple *)tuple{
    NSAssert([tuple isKindOfClass:[COTuple class]], @"tuple must be COTuple");
    if (tuple == NULL) {
        return;
    }
    if (![tuple isKindOfClass:[COTuple class]]) {
        return;
    }
    _tuple = [tuple retain];
    int index = 0;
    for (NSNumber *number in storage) {
        if (index >= [tuple count]) {
            break;
        }
        uintptr_t p = [number unsignedLongValue];
        if (p > 0) {
            __autoreleasing id* pointer = (id*)p;
            
            *pointer = [[tuple objectAtIndex:index] retain];
        }
        
        index++;
    }
#ifdef DEBUG
    for (NSNumber *number in storage) {
        
        uintptr_t p = [number unsignedLongValue];
        if (p > 0) {
            __autoreleasing id* pointer = (id*)p;
            
            NSLog(@"%@", *pointer);
        }
        
    }
#endif
    
}

- (instancetype)initWithPointers:(int)startIndex, ...{
    self = [super init];
    if (self) {
        storage = [[NSMutableArray alloc] init];
        va_list ap;
        va_start(ap, startIndex);
        
        if (startIndex <= 0) {
            startIndex = 0;
        }
        int i = 0;
        id* sentin = (id*)co_unpackSentinel();

        do {
            arc_autoreleasing id* pp = va_arg(ap, arc_autoreleasing id*);
            if (pp == sentin) {
                break;
            }
            if (i >= startIndex) {
                uintptr_t pointer = (uintptr_t)pp;
                [storage addObject:@(pointer)];
            }
            i++;

        } while (1);
        va_end(ap);
    }
    return self;
}

- (void)dealloc{
    [storage removeAllObjects];
    storage = nil;
    if (_tuple) {
        [_tuple release];
        _tuple = nil;
    }
#ifdef DEBUG
    
    co_untuple_dealloc_count++;
    
#endif
    [super dealloc];
}



@end

@implementation COTuple1

@end

@implementation COTuple2

@end

@implementation COTuple3

@end

@implementation COTuple4

@end

@implementation COTuple5

@end

@implementation COTuple6

@end

@implementation COTuple7

@end

@implementation COTuple8

@end


