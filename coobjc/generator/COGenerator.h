//
//  COGenerator.h
//  coobjc
//
//  Created by 刘坤 on 2019/3/11.
//  Copyright © 2019 Alibaba lnc. All rights reserved.
//

#import <coobjc/COCoroutine.h>

NS_ASSUME_NONNULL_BEGIN

@class COGenerator;

/**
 This two method implement generator, you should not call this method directly,
 Use  `yield( xxx )`
 */
void co_generator_yield_prepare(COGenerator *co);
void co_generator_yield_do(COGenerator *co, id _Nonnull promiseOrChan);


/**
 The Generator object.
 */
@interface COGenerator : COCoroutine

/**
 The channel for yield.
 */
@property(nonatomic, strong, nullable) COChan *yieldChan;

/**
 The channel for send value to the `next()` caller.
 */
@property(nonatomic, strong, nullable) COChan *valueChan;


/**
 The designed for Generator, used as yield/next.
 
 @return The value yiled by the Generator.
 */
- (id _Nullable )next;

@end

NS_ASSUME_NONNULL_END
