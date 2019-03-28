//
//  CODispatch.h
//  cocore
//
//  Created by 彭 玉堂 on 2019/3/28.
//  Copyright © 2019 Alibaba lnc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CODispatchTimer : NSObject

@property (nonatomic, strong) dispatch_block_t block;

- (void)invalidate;

@end




NS_ASSUME_NONNULL_BEGIN

@interface CODispatch : NSObject

+ (instancetype)currentDispatch;

- (BOOL)isCurrentDispatch;

- (void)dispatch_block:(dispatch_block_t)block;

- (void)dispatch_async_block:(dispatch_block_t)block;


- (CODispatchTimer*)dispatch_timer:(dispatch_block_t)block
                          interval:(NSTimeInterval)interval;

- (BOOL)isEqualToDipatch:(CODispatch*)dispatch;

@end

NS_ASSUME_NONNULL_END
