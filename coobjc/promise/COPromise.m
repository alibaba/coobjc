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

typedef NS_ENUM(NSInteger, COPromiseState) {
    COPromiseStatePending = 0,
    COPromiseStateFulfilled,
    COPromiseStateRejected,
};

typedef void (^COPromiseObserver)(COPromiseState state, id __nullable resolution);

@interface COPromise<Value>()
{
    COPromiseState _state;
    NSMutableArray<COPromiseObserver> *_observers;
    id __nullable _value;
    NSError *__nullable _error;
    COPromiseConstructor _constructor;
}

typedef void (^COPromiseOnFulfillBlock)(Value __nullable value);
typedef void (^COPromiseOnRejectBlock)(NSError *error);
typedef id __nullable (^__nullable COPromiseChainedFulfillBlock)(Value __nullable value);
typedef id __nullable (^__nullable COPromiseChainedRejectBlock)(NSError *error);

@end

@implementation COPromise

- (instancetype)initWithContructor:(COPromiseConstructor)constructor {
    self = [super init];
    if (self) {
        _constructor = constructor;
    }
    return self;
}

+ (instancetype)promise {
    return [[self alloc] init];
}

+ (instancetype)promise:(COPromiseConstructor)constructor {
    return [[self alloc] initWithContructor:constructor];
}

+ (instancetype)promise:(COPromiseConstructor)constructor onQueue:(dispatch_queue_t)queue {
    if (queue) {
        return [[self alloc] initWithContructor:^(COPromiseFullfill fullfill, COPromiseReject reject) {
            dispatch_async(queue, ^{
                constructor(fullfill, reject);
            });
        }];
    }
    else{
        return [[self alloc] initWithContructor:constructor];
    }
}

- (BOOL)isPending {
    @synchronized(self) {
        return _state == COPromiseStatePending;
    }
}

- (BOOL)isFulfilled {
    @synchronized(self) {
        return _state == COPromiseStateFulfilled;
    }
}

- (BOOL)isRejected {
    @synchronized(self) {
        return _state == COPromiseStateRejected;
    }
}

- (nullable id)value {
    @synchronized(self) {
        return _value;
    }
}

- (NSError *__nullable)error {
    @synchronized(self) {
        return _error;
    }
}

- (void)fulfill:(id)value {
    NSArray<COPromiseObserver> * observers = nil;
    COPromiseState state;
    @synchronized(self) {
        if (_state == COPromiseStatePending) {
            _state = COPromiseStateFulfilled;
            state = _state;
            _value = value;
            observers = [_observers copy];
            _observers = nil;
            _constructor = nil;
        }
        else{
            return;
        }
    }
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
    @synchronized(self) {
        if (_state == COPromiseStatePending) {
            _state = COPromiseStateRejected;
            state = _state;
            _error = error;
            observers = [_observers copy];
            _observers = nil;
            _constructor = nil;
        }
        else{
            return;
        }
    }
    for (COPromiseObserver observer in observers) {
        observer(state, error);
    }
}

- (void)cancel {
    [self reject:[NSError errorWithDomain:@"COPromiseErrorDomain" code:-2341 userInfo:@{NSLocalizedDescriptionKey: @"Promise was cancelled."}]];
}

- (void)onCancel:(COPromiseOnCancelBlock)onCancelBlock {
    if (onCancelBlock) {
        __weak typeof(self) weakSelf = self;
        [self catch:^(NSError * _Nonnull error) {
            if ([error.domain isEqualToString:@"COPromiseErrorDomain"] && error.code == -2341) {
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
    @synchronized (self) {
        
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
                value = self.value;
                break;
            }
            case COPromiseStateRejected: {
                state = COPromiseStateRejected;
                error = self.error;
                break;
            }
            default:
                break;
        }
    }
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
    if (_constructor) {
        COPromiseFullfill fullfill = ^(id value){
            [self fulfill:value];
        };
        COPromiseReject reject = ^(NSError *error){
            [self reject:error];
        };
        _constructor(fullfill, reject);
    }
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
