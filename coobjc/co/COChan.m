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
#import <cocore/cocore.h>
#import "COCoroutine.h"
#import "COLock.h"
#import "CODispatch.h"
#import <objc/runtime.h>

static NSString *const kCOChanNilObj = @"kCOChanNilObj";

static void co_chan_custom_resume(coroutine_t *co) {
    [co_get_obj(co) addToScheduler];
}

@interface COChan()
{
    co_channel *_chan;
    dispatch_semaphore_t    _buffLock;
}

@property(nonatomic, assign) int count;
@property(nonatomic, strong) NSMutableArray *buffList;

@end

@implementation COChan

- (void)dealloc {
    // free the remain objects in buffer.
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
        _chan = chancreate(sizeof(int8_t), buffCount, co_chan_custom_resume);
        _buffList = [[NSMutableArray alloc] init];
        COOBJC_LOCK_INIT(_buffLock);
    }
    return self;
}

- (void)send:(id)val {
    [self send:val onCancel:NULL];
}

- (void)send:(id)val onCancel:(COChanOnCancelBlock)cancelBlock {
    
    // send may blocking current process, so must check in a coroutine.
    COCoroutine *co = [COCoroutine currentCoroutine];
    if (!co) {
        NSAssert(false, @"send blocking must call in a coroutine.");
        return;
    }
    
    co.currentChan = self;
    IMP custom_exec = imp_implementationWithBlock(^{
        COOBJC_SCOPELOCK(self->_buffLock);
        [self.buffList addObject:val ?: kCOChanNilObj];
    });
    
    IMP cancel_exec = NULL;
    if (cancelBlock) {
        cancel_exec = imp_implementationWithBlock(^{
            cancelBlock(self);
        });
    }
    // do send
    int8_t v = 1;
    chansend_custom_exec(_chan, &v, custom_exec, cancel_exec);
    imp_removeBlock(custom_exec);
    if (cancel_exec) {
        imp_removeBlock(cancel_exec);
    }
    co.currentChan = nil;
}

- (id)receive {
    return [self receiveWithOnCancel:NULL];
}

- (id)receiveWithOnCancel:(COChanOnCancelBlock)cancelBlock {
    
    COCoroutine *co = [COCoroutine currentCoroutine];
    if (!co) {
        return nil;
    }
    
    co.currentChan = self;
    
    IMP cancel_exec = NULL;
    if (cancelBlock) {
        cancel_exec = imp_implementationWithBlock(^{
            cancelBlock(self);
        });
    }
    
    uint8_t val = 0;
    int ret = chanrecv_custom_exec(_chan, &val, cancel_exec);
    if (cancel_exec) {
        imp_removeBlock(cancel_exec);
    }
    co.currentChan = nil;
    
    if (ret == CHANNEL_ALT_SUCCESS) {
        // success
        do {
            COOBJC_SCOPELOCK(_buffLock);
            NSMutableArray *buffList = self.buffList;
            if (buffList.count > 0) {
                id obj = buffList.firstObject;
                [buffList removeObjectAtIndex:0];
                if (obj == kCOChanNilObj) {
                    obj = nil;
                }
                return obj;
            } else {
                return nil;
            }

        } while(0);
        
    } else {
        // ret not 1, means nothing received or cancelled.
        return nil;
    }
}

- (NSArray *)receiveAll {
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    id obj = [self receive];
    if (!obj) {
        return retArray.copy;
    }
    [retArray addObject:obj == kCOChanNilObj ? [NSNull null] : obj];
    while ([COCoroutine isActive] && (obj = [self receive_nonblock])) {
        [retArray addObject:obj == kCOChanNilObj ? [NSNull null] : obj];
    }
    return retArray.copy;
}

- (NSArray *)receiveWithCount:(NSUInteger)count {
    NSMutableArray *retArray = [[NSMutableArray alloc] initWithCapacity:count];
    id obj = nil;
    NSUInteger currCount = 0;
    while (currCount < count && [COCoroutine isActive] && (obj = [self receive])) {
        [retArray addObject:obj == kCOChanNilObj ? [NSNull null] : obj];
        currCount ++;
    }
    return retArray.copy;
}

- (void)send_nonblock:(id)val {
    
    IMP custom_exec = imp_implementationWithBlock(^{
        COOBJC_SCOPELOCK(self->_buffLock);
        [self.buffList addObject:val ?: kCOChanNilObj];
    });
    int8_t v = 1;
    channbsend_custom_exec(_chan, &v, custom_exec);
    imp_removeBlock(custom_exec);
}

- (id)receive_nonblock {
    
    uint8_t val = 0;
    int ret = channbrecv(_chan, &val);

    if (ret == CHANNEL_ALT_SUCCESS) {
        
        do {
            COOBJC_SCOPELOCK(_buffLock);
            NSMutableArray *buffList = self.buffList;
            if (buffList.count > 0) {
                id obj = buffList.firstObject;
                [buffList removeObjectAtIndex:0];
                if (obj == kCOChanNilObj) {
                    obj = nil;
                }
                return obj;
            } else {
                return nil;
            }
            
        } while(0);
        
    } else {
        // ret not 1, means nothing received.
        return nil;
    }
}

- (void)cancelForCoroutine:(COCoroutine *)co {
    
    chan_cancel_alt_in_co(co.co);
}

@end

@interface COTimeChan()

@property (nonatomic, strong) CODispatchTimer *timer;

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

- (id)receive {
    return [self receiveWithOnCancel:^(COChan * _Nonnull chan) {
        [[(COTimeChan *)chan timer] invalidate];
    }];
}

+ (instancetype)sleep:(NSTimeInterval)duration {
    COTimeChan *chan = [self chanWithDuration:duration];
    
    __weak __typeof(chan) weakChan = chan;
    chan.timer = [[CODispatch currentDispatch] dispatch_timer:^{
        __strong __typeof(chan) chan = weakChan;
        [chan send_nonblock:@1];
    } interval:duration];
    
    return chan;
}

@end
