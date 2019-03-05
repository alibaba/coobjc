//
//  COChan.m
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

#import "COChan.h"
#import "coroutine.h"
#import "co_csp.h"
#import "COCoroutine.h"
#import "co_queue.h"

static void co_chan_custom_resume(coroutine_t *co) {
    [co_get_obj(co) addToScheduler];
}

@interface COChan()
{
    co_channel *_chan;
    BOOL _cancelled;
}

@property(nonatomic, assign) int count;
@property(nonatomic, copy) COChanOnCancelBlock cancelBlock;

@end

@implementation COChan

- (void)dealloc {
    // free the remain objects in buffer.
    if (_chan->buffer.count > 0) {
        for (int i = 0; i < _chan->buffer.count; i++) {
            void *cacheVal = (void *)(_chan->buffer.arr + i * _chan->buffer.elemsize);
            __unused id val = (__bridge_transfer id)cacheVal;
        }
    }
    if (_chan) {
        chanfree(_chan);
    }
}

+ (instancetype)chan {
    COChan *chan = [[self alloc] initWithBuffCount:0];
    return chan;
}

+ (instancetype)chanWithBuffCount:(int32_t)buffCount {
    COChan *chan = [[self alloc] initWithBuffCount:buffCount];
    return chan;
}

+ (instancetype _Nonnull )expandableChan {
    COChan *chan = [[self alloc] initWithBuffCount:-1];
    return chan;
}

- (instancetype)initWithBuffCount:(int32_t)buffCount {
    self = [super init];
    if (self) {
        _chan = chancreate(sizeof(void *), buffCount, co_chan_custom_resume);
        _cancelled = NO;
    }
    return self;
}

- (void)send:(id)val {
    
    // send may blocking current process, so must check in a coroutine.
    COCoroutine *co = [COCoroutine currentCoroutine];
    if (!co) {
        NSAssert(false, @"send blocking must call in a coroutine.");
        return;
    }
    
    co.currentChan = self;
    chansendp(_chan, (__bridge_retained void *)val);
    co.currentChan = nil;
}

- (id)receive {
    
    COCoroutine *co = [COCoroutine currentCoroutine];
    if (!co) {
        return nil;
    }
    co.currentChan = self;
//    co.lastError = nil;
    
    void *ret = chanrecvp(_chan);
    
    co.currentChan = nil;
    if (ret == NULL) {
        return nil;
    } else {
        id val = (__bridge_transfer id)ret;
        if ([self isCancelled]) {
            return nil;
        } else {
            return val;
        }
    }
}

- (void)send_nonblock:(id)val {
    
    channbsendp(_chan, (__bridge_retained void *)val);
}

- (id)receive_nonblock {
    
    COCoroutine *co = [COCoroutine currentCoroutine];
    co.lastError = nil;
    
    void *ret = NULL;
    __unused int st = channbrecv(_chan, (void *)&ret);

    if (ret == NULL) {
        return nil;
    } else {

        id val = (__bridge_transfer id)ret;
        if ([self isCancelled]) {
            return nil;
        } else {
            return val;
        }
    }
}

- (void)cancel {
    
    if (self.isCancelled) {
        return;
    }
    
    _cancelled = YES;
    
    if (self.cancelBlock) {
        self.cancelBlock(self);
    }
    
    // releaseing blocking channels.
    int blockingSend = 0, blockingReceive = 0;
    if (changetblocking(_chan, &blockingSend, &blockingReceive)) {
        
        if (blockingSend > 0) {
            while (blockingSend) {
                void *ret = NULL;
                __unused int st = channbrecv(_chan, (void *)&ret);
                __unused id val = (__bridge_transfer id)ret;
                blockingSend--;
            }
        } else if (blockingReceive > 0) {
            while (blockingReceive) {
                id val = nil;
                channbsendp(_chan, (__bridge_retained void *)val);
                blockingReceive--;
            }
        }
    } 
}

- (BOOL)isCancelled {
    return _cancelled;
}

- (void)onCancel:(COChanOnCancelBlock)onCancelBlock {
    self.cancelBlock = onCancelBlock;
}

@end


@implementation COTimeChan
{
    BOOL _isDone;
}

+ (instancetype)chanWithDuration:(NSTimeInterval)duration {
    COTimeChan *chan = [[COTimeChan alloc] initWithBuffCount:0];
    return chan;
}

- (void)send_nonblock:(id)val {
    if (_isDone) {
        return;
    }
    _isDone = YES;
    [super send_nonblock:val];
}

+ (instancetype)sleep:(NSTimeInterval)duration {
    COTimeChan *chan = [self chanWithDuration:duration];
    
    dispatch_queue_t queue = co_get_current_queue();
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_source_cancel(timer);
        [chan send_nonblock:@1];
    });
    
    [chan onCancel:^(COChan * _Nonnull chan) {
        dispatch_source_cancel(timer);
    }];
    
    dispatch_resume(timer);
    
    
    return chan;
}

@end
