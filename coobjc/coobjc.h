//
//  coobjc.h
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

#import <Foundation/Foundation.h>

#import <cocore/coroutine.h>
#import <cocore/co_csp.h>
#import <cocore/co_autorelease.h>

#import <coobjc/COCoroutine.h>
#import <coobjc/COChan.h>
#import <coobjc/COActor.h>
#import <coobjc/COGenerator.h>
#import <coobjc/co_tuple.h>


/**
 Mark a function with `CO_ASYNC`, which means the function may suspend,
 so the function must calling in a coroutine. You should make `SURE_ASYNC` in function begans.
 */
#define CO_ASYNC

/**
 Assert the current code is running on a coroutine.
 */
#define SURE_ASYNC NSAssert([COCoroutine currentCoroutine], @"co_async method must run in coroutine");

/**
 Create a coroutine, then resume it asynchronous on current queue.

 @param block the code execute in the coroutine
 @return the coroutine instance
 */
NS_INLINE COCoroutine * _Nonnull  co_launch(void(^ _Nonnull block)(void)) {
    COCoroutine *co = [COCoroutine coroutineWithBlock:block onQueue:nil];
    return [co resume];
}

/**
 Create a coroutine, then resume it immediately on current queue.
 
 @param block the code execute in the coroutine
 */
NS_INLINE void co_launch_now(void(^ _Nonnull block)(void)) {
    COCoroutine *co = [COCoroutine coroutineWithBlock:block onQueue:nil];
    [co resumeNow];
}

/**
 Create a coroutine, then resume it asynchronous on current queue.
 
 The stack size is 65536 by default, in case stackSize not enough, you can customize it.
 Max 1M limit.
 
 @param block the code execute in the coroutine
 @return the coroutine instance
 */
NS_INLINE COCoroutine * _Nonnull  co_launch_withStackSize(NSUInteger stackSize, void(^ _Nonnull block)(void)) {
    COCoroutine *co = [COCoroutine coroutineWithBlock:block onQueue:nil stackSize:stackSize];
    return [co resume];
}

/**
 Create a coroutine and resume it asynchronous on the given queue.

 @param block the code execute in the coroutine
 @param queue the queue which coroutine work on it.
 @return the coroutine instance
 */
NS_INLINE COCoroutine * _Nonnull  co_launch_onqueue(dispatch_queue_t _Nullable queue, void(^ _Nonnull block)(void)) {
    COCoroutine *co = [COCoroutine coroutineWithBlock:block onQueue:queue];
    return [co resume];
}


/**
 Create a sequence, make the coroutine be a Generator.

 @param block the sequence task.
 @return the Coroutine
 */
NS_INLINE COGenerator * _Nonnull co_sequence(void(^ _Nonnull block)(void)) {
    COGenerator *co = [COGenerator coroutineWithBlock:block onQueue:nil];
    return co;
}

/**
 Create a sequence, make the coroutine be a Generator.
 The code will run on specified queue.

 @param block the code execute in the coroutine.
 @param queue the queue which coroutine work on it.
 @return the coroutine instance
 */
NS_INLINE COGenerator * _Nonnull  co_sequence_onqueue(dispatch_queue_t _Nullable queue, void(^ _Nonnull block)(void)) {
    COGenerator *co = [COGenerator coroutineWithBlock:block onQueue:queue];
    return co;
}

/**
 Create a actor.
 
 @param block the sequence task.
 @return the Coroutine
 */
NS_INLINE COActor * _Nonnull co_actor(void(^ _Nonnull block)(COActorChan* _Nonnull)) {
    COActor *co = [COActor actorWithBlock:block onQueue:nil];
    return (COActor*)[co resume];
}

/**
 Create a actor and start it asynchronous on the given queue.
 
 @param block the code execute in the coroutine.
 @param queue the queue which coroutine work on it.
 @return the coroutine instance
 */
NS_INLINE COActor * _Nonnull  co_actor_onqueue(dispatch_queue_t _Nullable queue, void(^ _Nonnull block)(COActorChan* _Nonnull)) {
    COActor *co = [COActor actorWithBlock:block onQueue:queue];
    return (COActor*)[co resume];
}


/**
 await

 @param _promiseOrChan the COPromise object, you can also pass a COChan object.
        But we suggest use Promise first.
 @return return the value, nullable. after, you can use co_getError() method to get the error.
 */
NS_INLINE id _Nullable await(id _Nonnull _promiseOrChan) {
    id val = co_await(_promiseOrChan);
    return val;
}


/**
 batch_await
 
 @param _promiseOrChanArray a NSArray of  COPromise object or COChan object.
 @return return the NSArray of values, if value is nil, the element is NSNull.
 */
NS_INLINE NSArray<id> *_Nullable batch_await(NSArray<id> * _Nonnull _promiseOrChanArray) {
    id val = co_batch_await(_promiseOrChanArray);
    return val;
}



/**
 co_delay
 
 @param duration make the current coroutine sleep $duration seconds.
 */
NS_INLINE void co_delay(NSTimeInterval duration) {
    co_await([COTimeChan sleep:duration]);
}


/**
 co_isActive    check current coroutine is active or not, if a coroutine is cancelled, this returns false.
 */
NS_INLINE BOOL co_isActive() {
    return [COCoroutine isActive];
}


/**
 Check current routine is cancelled.
 */
NS_INLINE BOOL co_isCancelled() {
    return [COCoroutine currentCoroutine].isCancelled;
}

