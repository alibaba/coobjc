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
void co_generator_yield_prepare(COGenerator *co);
void co_generator_yield_do(COGenerator *co, id _Nonnull promiseOrChan);
void co_generator_yield_value(id value);

/**
 yield with a COPromise
 
 @discussion `yield` means pause the expression execution,
 until Generator(coroutine) call `next`.
 
 @param _promise the COPromise object.
 */
#define yield(_expr) \
{ \
    COGenerator *__co__ = (COGenerator *)[COCoroutine currentCoroutine]; \
    co_generator_yield_prepare(__co__); \
    if (!__co__.isCancelled) { \
        id __promiseOrChan__ = ({ _expr; }); \
        co_generator_yield_do(__co__, __promiseOrChan__); \
    } \
}

/**
 yield with a value.
 
 @param val the value.
 */
#define yield_val(val)  yield(val)


@interface COGenerator : COCoroutine

/**
 When COCoroutine as a Generator, this Channel use to yield a value.
 */
@property(nonatomic, strong, nullable) COChan *yieldChan;

@property(nonatomic, strong, nullable) COChan *valueChan;


/**
 The designed for Generator, used as yield/next.
 
 @return The value yiled by the Generator.
 */
- (id _Nullable )next;

@end

NS_ASSUME_NONNULL_END
