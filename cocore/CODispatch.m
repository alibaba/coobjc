//
//  CODispatch.m
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

#import "CODispatch.h"
#import "co_queue.h"

@interface CODispatcHandler : NSObject

+ (instancetype)sharedInstance;

- (void)handleBlock:(dispatch_block_t)block;

@end

@implementation CODispatcHandler

+ (instancetype)sharedInstance{
    static CODispatcHandler *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CODispatcHandler alloc] init];
    });
    return instance;
}

- (void)handleBlock:(dispatch_block_t)block{
    if (block) {
        block();
    }
}

- (void)handleTimer:(CODispatchTimer*)timer{
    
}

@end

@interface CODispatchTimer ()

@property (nonatomic, strong) dispatch_source_t source;
@property (nonatomic, strong) NSTimer *timer;

@end


@implementation CODispatchTimer

- (void)invalidate{
    if (_source) {
        dispatch_source_cancel(_source);
        _source = nil;
    }
    else if(_timer){
        [_timer invalidate];
        _timer = nil;
    }
}

@end

@interface CODispatch ()

@property (nonatomic, strong) NSThread *thread;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation CODispatch

+ (instancetype)dispatchWithQueue:(dispatch_queue_t)q{
    CODispatch *dispatch = [[CODispatch alloc] init];
    dispatch.queue = q;
    return dispatch;
}

+ (instancetype)currentDispatch{
    CODispatch *dispatch = [[CODispatch alloc] init];
    dispatch_queue_t q = co_get_current_queue();
    if (q) {
        dispatch.queue = q;
    }
    else{
        static dispatch_queue_t q = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            q = dispatch_queue_create("com.coobjc.defaultqueue", NULL);
        });
        dispatch.queue = q;
    }
    return dispatch;
}

- (BOOL)isCurrentDispatch{
    if (_queue) {
        return co_is_current_queue_equal(_queue);
    }
    if (_thread) {
        return [NSThread currentThread] == _thread;
    }
    return NO;
}

- (void)dispatch_async_block:(dispatch_block_t)block{
    if (_queue) {
        dispatch_async(_queue, block);
    }
    else{
        if (_thread) {
            [[CODispatcHandler sharedInstance] performSelector:@selector(handleBlock:) onThread:_thread withObject:[block copy] waitUntilDone:NO];
        }
    }
}

- (void)dispatch_block:(dispatch_block_t)block{
    if (_queue) {
        if (co_is_current_queue_equal(_queue)) {
            block();
        }
        else{
            dispatch_async(_queue, block);
        }
    }
    else{
        if (_thread) {
            if ([NSThread currentThread] == _thread) {
                block();
            }
            else{
                [[CODispatcHandler sharedInstance] performSelector:@selector(handleBlock:) onThread:_thread withObject:[block copy] waitUntilDone:NO];
            }
        }
    }
}

- (CODispatchTimer*)dispatch_timer:(dispatch_block_t)block
                          interval:(NSTimeInterval)interval{
    CODispatchTimer *dispatchTimer = [[CODispatchTimer alloc] init];
    dispatchTimer.block = block;
    if (_queue) {
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
        dispatch_source_set_event_handler(timer, ^{
            dispatch_source_cancel(timer);
            block();
        });
        dispatch_resume(timer);
        dispatchTimer.source = timer;
    }
    else if([NSRunLoop currentRunLoop]){
        NSTimer *timer = [NSTimer timerWithTimeInterval:interval target:[CODispatcHandler sharedInstance] selector:@selector(handleTimer:) userInfo:dispatchTimer repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        dispatchTimer.timer = timer;
    }
    else{
        return nil;
    }
    return dispatchTimer;
}

- (BOOL)isEqualToDipatch:(CODispatch*)dispatch{
    if (_queue && _queue == dispatch.queue) {
        return YES;
    }
    if (_thread && _thread == dispatch.thread) {
        return YES;
    }
    return NO;
}


@end
