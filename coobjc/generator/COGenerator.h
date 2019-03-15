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
 This method can get the param setted by nextWithParam,
 gen = co_generator(^{
     id param = co_getYieldParam();
     yield(handleParam(param));
     //param will be @(1), it was the value passed by nextWithValue
 });
 
 co_launch(^{
    id value = [gen nextWithValue:@(1)];
 });
 */
id _Nullable co_getYieldParam(void);

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


/**
 The designed for Generator, used as yield/nextWithParam.
 @param param is the value will pass to yield, can use like this
 gen = co_generator(^{
    id param = co_getYieldParam();
    yield(handleParam(param));
    //param will be @(1), it was the value passed by nextWithValue
 });
 
 co_launch(^{
    id value = [gen nextWithValue:@(1)];
 });
 
 @return The value yiled by the Generator.
 */
- (id _Nullable )nextWithParam:(id)param;

@end

NS_ASSUME_NONNULL_END
