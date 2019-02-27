//
//  COPromise.h
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


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 COPromise is a implementation of promise.
 */
@interface COPromise<Value> : NSObject

/**
 Define the worker type
 */
typedef id __nullable (^COPromiseThenWorkBlock)(Value __nullable value);

/**
 Define the catch block type
 */
typedef void (^COPromiseCatchWorkBlock)(NSError *error);

/**
 Define the on cancel callback block type
 */
typedef void (^COPromiseOnCancelBlock)(COPromise *promise);

/**
 Define the resolve prototype
 */
typedef void (^COPromiseFullfill)(id _Nullable );

/**
 Define the reject prototype
 */
typedef void (^COPromiseReject)(NSError *);

/**
 Define the constructor's prototype
 */
typedef void (^COPromiseConstructor)(COPromiseFullfill fullfill, COPromiseReject reject);

/**
 Tell the promise is pending or not.
 */
@property(nonatomic, readonly) BOOL isPending;

/**
 Tell the promise is fulfilled or not.
 */
@property(nonatomic, readonly) BOOL isFulfilled;

/**
 Tell the promise is rejected or not.
 */
@property(nonatomic, readonly) BOOL isRejected;

/**
 If fulfilled, value store into this property.
 */
@property(nonatomic, readonly, nullable) Value value;

/**
 If reject, error store into this property
 */
@property(nonatomic, readonly, nullable) NSError *error;


/**
 Create a promise without constructor. Which means, you should control when the job begins.

 @return The `COPromise` instance
 */
+ (instancetype)promise;


/**
 Create a promise with constructor. the job begans when someone observing on it.

 @param constructor the constructor block.
 @return The `COPromise` instance
 */
+ (instancetype)promise:(COPromiseConstructor)constructor;

/**
 Create a promise with constructor. the job begans when someone observing on it.
 
 @param constructor the constructor block.
 @param queue the dispatch_queue_t that the job run.
 @return The `COPromise` instance
 */
+ (instancetype)promise:(COPromiseConstructor)constructor onQueue:(dispatch_queue_t _Nullable )queue;


/**
 Fulfill the promise with a return value.

 @param value the value fulfilled.
 */
- (void)fulfill:(nullable Value)value;

/**
 Reject the promise with a error

 @param error the error.
 */
- (void)reject:(NSError * _Nullable)error;

/**
 Cancel the job.
 
 @discussion If you want a `COPromise` be cancellable, you must make the job cancel in `onCancel:`.
 */
- (void)cancel;


/**
 Set the onCancelBlock.

 @param onCancelBlock will execute on the promise cancelled.
 */
- (void)onCancel:(COPromiseOnCancelBlock _Nullable )onCancelBlock;

/**
 Chained observe the promise fulfilled.

 @param work the observer worker.
 @return The chained promise instance.
 */
- (COPromise *)then:(COPromiseThenWorkBlock)work;

/**
 Observe the promises rejected.

 @param reject the reject dealing worker.
 @return The chained promise instance.
 */
- (COPromise *)catch:(COPromiseCatchWorkBlock)reject;

@end

NS_ASSUME_NONNULL_END
