//
//  CODispatch.h
//  cocore
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

@interface CODispatchTimer : NSObject

@property (nonatomic, strong) dispatch_block_t block;

- (void)invalidate;

@end




NS_ASSUME_NONNULL_BEGIN

@interface CODispatch : NSObject

+ (instancetype)dispatchWithQueue:(dispatch_queue_t)q;

+ (instancetype)currentDispatch;

- (BOOL)isCurrentDispatch;

- (void)dispatch_block:(dispatch_block_t)block;

- (void)dispatch_async_block:(dispatch_block_t)block;


- (CODispatchTimer*)dispatch_timer:(dispatch_block_t)block
                          interval:(NSTimeInterval)interval;

- (BOOL)isEqualToDipatch:(CODispatch*)dispatch;

@end

NS_ASSUME_NONNULL_END
