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

static NSString *const kCOChanNilObj = @"kCOChanNilObj";

static void co_chan_custom_resume(coroutine_t *co) {
    [co_get_obj(co) addToScheduler];
}

@interface COChan()
{
    co_channel *_chan;
    BOOL _cancelled;
    dispatch_semaphore_t    _buffLock;
}

@property(nonatomic, assign) int count;
@property(nonatomic, copy) COChanOnCancelBlock cancelBlock;
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
        _cancelled = NO;
        _buffList = [[NSMutableArray alloc] init];
        COOBJC_LOCK_INIT(_buffLock);
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
    do {
        COOBJC_SCOPELOCK(_buffLock);
        [self.buffList addObject:val ?: kCOChanNilObj];
    } while(0);
    chansendi8(_chan, 1);
    co.currentChan = nil;
}

- (id)receive {
    
    COCoroutine *co = [COCoroutine currentCoroutine];
    if (!co) {
        return nil;
    }
    
    co.currentChan = self;
    int8_t ret = chanrecvi8(_chan);
    co.currentChan = nil;
    
    if (ret == 1) {
        
        do {
            COOBJC_SCOPELOCK(_buffLock);
            NSMutableArray *buffList = self.buffList;
            if (buffList.count > 0) {
                id obj = buffList.firstObject;
                [buffList removeObjectAtIndex:0];
                if (obj == kCOChanNilObj || [self isCancelled]) {
                    obj = nil;
                }
                return obj;
            } else {
                return nil;
            }

        } while(0);
        
    } else {
        // ret not 1, means cancelled.
        return nil;
    }
}

- (void)send_nonblock:(id)val {
    
    do {
        COOBJC_SCOPELOCK(_buffLock);
        [self.buffList addObject:val ?: kCOChanNilObj];
    } while(0);
    
    channbsendi8(_chan, 1);
}

- (id)receive_nonblock {
    
    int8_t ret = channbrecvi8(_chan);
    
    if (ret == 1) {
        
        do {
            COOBJC_SCOPELOCK(_buffLock);
            NSMutableArray *buffList = self.buffList;
            if (buffList.count > 0) {
                id obj = buffList.firstObject;
                [buffList removeObjectAtIndex:0];
                if (obj == kCOChanNilObj || [self isCancelled]) {
                    obj = nil;
                }
                return obj;
            } else {
                return nil;
            }
            
        } while(0);
        
    } else {
        // ret not 1, means cancelled.
        return nil;
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
                channbrecvi8(_chan);
                blockingSend--;
            }
        } else if (blockingReceive > 0) {
            while (blockingReceive) {
                channbsendi8(_chan, 0);
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
    
    CODispatchTimer *timer = [[CODispatch currentDispatch] dispatch_timer:^{
        [chan send_nonblock:@1];
    } interval:duration];
    
    [chan onCancel:^(COChan * _Nonnull chan) {
        //dispatch_source_cancel(timer);
        [timer invalidate];
    }];
    
    
    return chan;
}

@end
