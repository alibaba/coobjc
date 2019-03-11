//
//  COPromise.m
//  coobjc
//
//  Copyright © 2018 Alibaba Group Holding Limited All rights reserved.
//  Copyright 2018 Google Inc. All rights reserved.
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
//
//
//    Reference code from: [FBLPromise](https://github.com/google/promises)

#import "COPromise.h"
#import "COChan.h"
#import "COCoroutine.h"
#import "co_queue.h"

typedef NS_ENUM(NSInteger, COPromiseState) {
    COPromiseStatePending = 0,
    COPromiseStateFulfilled,
    COPromiseStateRejected,
};

NSString *const COPromiseErrorDomain = @"COPromiseErrorDomain";

enum {
    COPromiseCancelledError = -2341,
};

typedef void (^COPromiseObserver)(COPromiseState state, id __nullable resolution);

@interface COPromise<Value>()
{
    COPromiseState _state;
    NSMutableArray<COPromiseObserver> *_observers;
    id __nullable _value;
    NSError *__nullable _error;
}

@property (nonatomic, strong) NSLock *lock;

typedef void (^COPromiseOnFulfillBlock)(Value __nullable value);
typedef void (^COPromiseOnRejectBlock)(NSError *error);
typedef id __nullable (^__nullable COPromiseChainedFulfillBlock)(Value __nullable value);
typedef id __nullable (^__nullable COPromiseChainedRejectBlock)(NSError *error);

@end

@implementation COPromise

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (instancetype)initWithContructor:(COPromiseConstructor)constructor queue:(dispatch_queue_t)queue {
    self = [self init];
    if (self) {
        if (constructor) {
            COPromiseFulfill fulfill = ^(id value){
                [self fulfill:value];
            };
            COPromiseReject reject = ^(NSError *error){
                [self reject:error];
            };
            if (queue) {
                dispatch_async(queue, ^{
                    constructor(fulfill, reject);
                });
            } else {
                constructor(fulfill, reject);
            }
        }
    }
    return self;
}

+ (instancetype)promise {
    return [[self alloc] init];
}

+ (instancetype)promise:(COPromiseConstructor)constructor {
    return [[self alloc] initWithContructor:constructor queue:co_get_current_queue()];
}

+ (instancetype)promise:(COPromiseConstructor)constructor onQueue:(dispatch_queue_t)queue {
    return [[self alloc] initWithContructor:constructor queue:queue];
}

- (BOOL)isPending {
    [_lock lock];
    BOOL isPending = _state == COPromiseStatePending;
    [_lock unlock];
    return isPending;
}

- (BOOL)isFulfilled {
    [_lock lock];
    BOOL isFulfilled = _state == COPromiseStateFulfilled;
    [_lock unlock];
    return isFulfilled;
}

- (BOOL)isRejected {
    [_lock lock];
    BOOL isRejected = _state == COPromiseStateRejected;
    [_lock unlock];
    return isRejected;
}

- (nullable id)value {
    [_lock lock];
    id result = _value;
    [_lock unlock];
    return result;
}

- (NSError *__nullable)error {
    [_lock lock];
    NSError *error = _error;
    [_lock unlock];
    return error;
}

- (void)fulfill:(id)value {
    NSArray<COPromiseObserver> * observers = nil;
    COPromiseState state;
    
    [_lock lock];
    if (_state == COPromiseStatePending) {
        _state = COPromiseStateFulfilled;
        state = _state;
        _value = value;
        observers = [_observers copy];
        _observers = nil;
    }
    else{
        [_lock unlock];
        return;
    }
    [_lock unlock];

    if (observers.count > 0) {
        for (COPromiseObserver observer in observers) {
            observer(state, value);
        }
    }
}

- (void)reject:(NSError *)error {
    NSAssert([error isKindOfClass:[NSError class]], @"Invalid error type.");
    NSArray<COPromiseObserver> * observers = nil;
    COPromiseState state;
    [_lock lock];
    if (_state == COPromiseStatePending) {
        _state = COPromiseStateRejected;
        state = _state;
        _error = error;
        observers = [_observers copy];
        _observers = nil;
    }
    else{
        [_lock unlock];
        return;
    }
    [_lock unlock];
    
    for (COPromiseObserver observer in observers) {
        observer(state, error);
    }
}

+ (BOOL)isPromiseCancelled:(NSError *)error {
    if ([error.domain isEqualToString:COPromiseErrorDomain] && error.code == COPromiseCancelledError) {
        return YES;
    } else {
        return NO;
    }
}

- (void)cancel {
    [self reject:[NSError errorWithDomain:COPromiseErrorDomain code:COPromiseCancelledError userInfo:@{NSLocalizedDescriptionKey: @"Promise was cancelled."}]];
}

- (void)onCancel:(COPromiseOnCancelBlock)onCancelBlock {
    if (onCancelBlock) {
        __weak typeof(self) weakSelf = self;
        [self catch:^(NSError * _Nonnull error) {
            if ([COPromise isPromiseCancelled:error]) {
                onCancelBlock(weakSelf);
            }
        }];
    }
}

#pragma mark - then

- (void)observeWithFulfill:(COPromiseOnFulfillBlock)onFulfill reject:(COPromiseOnRejectBlock)onReject {
    if (!onFulfill && !onReject) {
        return;
    }
    COPromiseState state = COPromiseStatePending;
    id value = nil;
    NSError *error = nil;
    [_lock lock];
    
    switch (_state) {
        case COPromiseStatePending: {
            if (!_observers) {
                _observers = [[NSMutableArray alloc] init];
            }
            [_observers addObject:^(COPromiseState state, id __nullable resolution) {
                switch (state) {
                    case COPromiseStatePending:
                        break;
                    case COPromiseStateFulfilled:
                        if (onFulfill) {
                            onFulfill(resolution);
                        }
                        break;
                    case COPromiseStateRejected:
                        if (onReject) {
                            onReject(resolution);
                        }
                        break;
                }
            }];
            break;
        }
        case COPromiseStateFulfilled: {
            state = COPromiseStateFulfilled;
            value = _value;
            break;
        }
        case COPromiseStateRejected: {
            state = COPromiseStateRejected;
            error = _error;
            break;
        }
        default:
            break;
    }
    [_lock unlock];
    
    if (state == COPromiseStateFulfilled) {
        if (onFulfill) {
            onFulfill(value);
        }
    }
    else if(state == COPromiseStateRejected){
        if (onReject) {
            onReject(error);
        }
    }
}


- (COPromise *)chainedPromiseWithFulfill:(COPromiseChainedFulfillBlock)chainedFulfill
                            chainedReject:(COPromiseChainedRejectBlock)chainedReject {
    
    COPromise *promise = [COPromise promise];
    __auto_type resolver = ^(id __nullable value, BOOL isReject) {
        if ([value isKindOfClass:[COPromise class]]) {
            [(COPromise *)value observeWithFulfill:^(id  _Nullable value) {
                [promise fulfill:value];
            } reject:^(NSError *error) {
                [promise reject:value];
            }];
        } else {
            if (isReject) {
                [promise reject:value];
            } else {
                [promise fulfill:value];
            }
        }
    };
    
    [self observeWithFulfill:^(id  _Nullable value) {
        value = chainedFulfill ? chainedFulfill(value) : value;
        resolver(value, NO);
    } reject:^(NSError *error) {
        id value = chainedReject ? chainedReject(error) : error;
        resolver(value, YES);
    }];
    
    return promise;
}

- (COPromise *)then:(COPromiseThenWorkBlock)work {
    return [self chainedPromiseWithFulfill:work chainedReject:nil];
}

- (COPromise *)catch:(COPromiseCatchWorkBlock)reject {
    return [self chainedPromiseWithFulfill:nil chainedReject:^id _Nullable(NSError *error) {
        if (reject) {
            reject(error);
        }
        return error;
    }];
}
    
@end

@interface COProgressValue : NSObject

@property (nonatomic, assign) float progress;

@end

@implementation COProgressValue

- (void)dealloc{
    NSLog(@"test");
}

@end

@interface COProgressPromise (){
    unsigned long enum_state;
}

@property (nonatomic, strong) NSProgress *progress;
@property (nonatomic, strong) COPromise *internalPromise;
@property (nonatomic, strong) id lastValue;

@end

static void *COProgressObserverContext = &COProgressObserverContext;

@implementation COProgressPromise

- (instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)fulfill:(id)value{
    [self.internalPromise fulfill:nil];
    [super fulfill:value];
}

- (void)reject:(NSError *)error{
    [self.internalPromise fulfill:nil];
    [super reject:error];
}

- (COProgressValue*)_nextProgressValue{
    if (![self isPending]) {
        return nil;
    }
    [self.lock lock];
    self.internalPromise = [COPromise promise];
    [self.lock unlock];
    COProgressValue* result = co_await(self.internalPromise);
    self.internalPromise = [COPromise promise];
    return result;
}

- (void)setupWithProgress:(NSProgress*)progress{
    NSProgress *oldProgress = nil;
    [self.lock lock];
    if (self.progress) {
        oldProgress = self.progress;
    }
    self.progress = progress;
    [self.lock unlock];
    if (oldProgress) {
        [oldProgress removeObserver:self
                      forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                         context:COProgressObserverContext];
    }
    if (progress) {
        [progress addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                      options:NSKeyValueObservingOptionInitial
                      context:COProgressObserverContext];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (context == COProgressObserverContext)
    {
        NSProgress *progress = object;
        COProgressValue *value = [[COProgressValue alloc] init];
        value.progress = progress.fractionCompleted;
        [self.lock lock];
        COPromise *promise = self.internalPromise;
        [self.lock unlock];
        [promise fulfill:value];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:context];
    }
}

- (float)next {
    COProgressValue *value = [self _nextProgressValue];
    return value.progress;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained _Nullable [_Nonnull])buffer count:(NSUInteger)len {
    
    if (state->state == 0) {
        state->mutationsPtr = &enum_state;
        state->state = enum_state;
    }
    
    NSUInteger count = 0;
    state->itemsPtr = buffer;
    COProgressValue* value= [self _nextProgressValue];
    if (value) {
        self.lastValue = @(value.progress);
        buffer[0] = self.lastValue;
        count++;
    }
    
    return count;
}

- (void)dealloc{
    NSProgress *oldProgress = nil;
    [self.lock lock];
    if (self.progress) {
        oldProgress = self.progress;
    }
    self.progress = nil;
    self.internalPromise = nil;
    [self.lock unlock];
    if (oldProgress) {
        [oldProgress removeObserver:self
                         forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                            context:COProgressObserverContext];
    }
}

@end
