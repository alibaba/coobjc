//
//  COChan.h
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

NS_ASSUME_NONNULL_BEGIN

/**
 The channel object.
 
 Channel is a implementation of Process/Channel, which defined in CSP(Communicating
 Sequential Processes).
 */
@interface COChan<Value> : NSObject

typedef void (^COChanOnCancelBlock)(COChan *chan);

/**
 Create a Channel object, default buffcount is 0.

 @see `chanWithBuffCount:`
 
 @return the Channel object
 */
+ (instancetype)chan;

/**
 Create a Channel object, and you can set the buffcount.

 @param buffCount the max buffer count of the channel.
 @return the Channel object
 */
+ (instancetype)chanWithBuffCount:(int32_t)buffCount;

/**
 Create a expandable Channel.  the buffer count is expandable, which means,
 `send:` will not blocking current process. And, val send to channel will not abandon.
 The buffer count being set to -1.

 @return the Channel object
 */
+ (instancetype)expandableChan;

/**
 Send a value to the Channel.
 
 @discussion This method may blocking the current process, when there's no one receives and buffer is full.
 So, this method requires calling in a coroutine.
 
 @param val the value send to Channel.
 */
- (void)send:(Value _Nullable )val;

/**
 Receive a value from the Channel, blocking.
 
 @discussion This method may blocking the current process, until some one send value to the Channel.
 
 @return the value received from the channel
 */
- (Value _Nullable )receive;

/**
 Send a value to the Channel, non blocking.

 @discussion 1. If someone is receiving, send it.
             2. If no one receiving, but buffer not full, store in the buffer.
             3. If no one receiving, and buffer is full, discard value.
 
 @param val the value send to Channel.
 */
- (void)send_nonblock:(Value _Nullable )val;

/**
 Receive a value from the Channel, non blocking.

 @discussion 1. If buffer has data, receive a value from buffer.
             2. If buffer is empty, and someone is sending, receive it.
             3. If buffer is empty, and on one sending. return nil.
 
 @return the value object received.
 */
- (Value _Nullable)receive_nonblock;

/**
 Blocking receive all values in the channel.
 
 1. If no values in channel, blocking waiting for one.
 2. If has values in channel, returning all values.
 3. If did send nil, the received value in array will be [NSNull null],
 so you need check the returning value type in array, important!!!
 
 @return the values received.
 */
- (NSArray<Value> * _Nonnull)receiveAll;

/**
 Blocking receive count values in the channel.
 
 1. It will continue blocking the current coroutine, until receive count objects.
 2. If did send nil, the received value in array will be [NSNull null],
 so you need check the returning value type in array, important!!!
 
 @return the values received.
 */
- (NSArray<Value> * _Nonnull)receiveWithCount:(NSUInteger)count;

/**
 Cancel the Channel.
 
 @discussion Why we provide this api?
 
 Sometimes, we need cancel a operation, such as a Network Connection. So, a coroutine is cancellable.
 But Channel may blocking the coroutine, so we need cancel the Channel when cancel a coroutine.
 */
- (void)cancel;

/**
 tell us is the channel is cancelled.

 @return isCancelled.
 */
- (BOOL)isCancelled;

/**
 Set a callback block when the Channel is cancel.

 @param onCancelBlock the cancel callback block.
 */
- (void)onCancel:(COChanOnCancelBlock _Nullable )onCancelBlock;

@end

/**
 An implementation Channel for `co_sleep`
 */
@interface COTimeChan: COChan

+ (instancetype)sleep:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
