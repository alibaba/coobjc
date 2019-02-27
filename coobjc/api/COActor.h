//
//  COActor.h
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
#import <coobjc/COCoroutine.h>
#import <coobjc/COActorMessage.h>
#import <coobjc/COActorChan.h>
#import <coobjc/COActorCompletable.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^COActorExecutor)(COActorChan *);

/**
 This is implementation of Actor model
 */
@interface COActor : COCoroutine

/**
 The block of actor.
 */
@property(nonatomic, copy) COActorExecutor exector;

/**
 The channel of the actor
 */
@property(nonatomic, readonly) COActorChan *messageChan;


/**
 Send a message to the Actor.

 @param message any oc object
 @return An awaitable Channel.
 */
- (COActorCompletable *)sendMessage:(id)message;


/**
 Actor create method

 @param block execute code block
 @param queue the dispatch_queue_t this actor run.
 @return The actor instance.
 */
+ (instancetype)actorWithBlock:(COActorExecutor)block onQueue:(dispatch_queue_t _Nullable)queue;

@end

NS_ASSUME_NONNULL_END
