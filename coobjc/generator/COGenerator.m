//
//  COGenerator.m
//  coobjc
//
//  Created by 刘坤 on 2019/3/11.
//  Copyright © 2019 Alibaba lnc. All rights reserved.
//

#import "COGenerator.h"

void co_generator_yield_prepare(COGenerator *co) {
    if (co == nil) {
        @throw [NSException exceptionWithName:COInvalidException
                                       reason:@"Cannot run co_generator_yield out of a coroutine"
                                     userInfo:nil];
    }
    if (![co isKindOfClass:[COGenerator class]]) {
        @throw [NSException exceptionWithName:COInvalidException
                                       reason:@"Yield should use in a generator"
                                     userInfo:nil];
        return;
    }
    if (co.isCancelled) {
        return;
    }
    
    [co.yieldChan send:@1];
}

void co_generator_yield_do(COGenerator *co, id _Nonnull promiseOrChanOrElse) {
    if (co.isCancelled) return;
    id val;
    if ([promiseOrChanOrElse isKindOfClass:[COPromise class]] || [promiseOrChanOrElse isKindOfClass:[COChan class]]) {
        val = co_await(promiseOrChanOrElse);
    } else {
        val = promiseOrChanOrElse;
    }
    if (co.isCancelled) return;
    [co.valueChan send:val];
}


@implementation COGenerator

- (instancetype)initWithBlock:(void (^)(void))block onQueue:(dispatch_queue_t)queue stackSize:(NSUInteger)stackSize {
    self = [super initWithBlock:block onQueue:queue stackSize:stackSize];
    if (self) {
        _yieldChan = [COChan chan];
        _valueChan = [COChan chan];
    }
    return self;
}

- (id)next {
    
    if (!self.isResume) {
        [self resume];
    }
    
    if ([self isCancelled] || [self isFinished]) {
        return nil;
    }
    
    [self.yieldChan receive];
    if (self.isCancelled) {
        return nil;
    }
    return [self.valueChan receive];
}

@end
