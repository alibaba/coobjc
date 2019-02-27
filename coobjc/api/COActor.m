//
//  COActor.m
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

#import "COActor.h"

@implementation COActor
@synthesize messageChan = _messageChan;


- (COActorChan *)messageChan {
    if (!_messageChan) {
        _messageChan = [COActorChan expandableChan];
    }
    return _messageChan;
}

- (COActorCompletable *)sendMessage:(id)message {
    
    COActorCompletable *completable = [COActorCompletable promise];
    dispatch_async(self.queue, ^{
        COActorMessage *actorMessage = [[COActorMessage alloc] initWithType:message completable:completable];
        [self.messageChan send_nonblock:actorMessage];
    });
    return completable;
}



+ (instancetype)actorWithBlock:(COActorExecutor)block onQueue:(dispatch_queue_t _Nullable)queue {
    COActor *actor = [self coroutineWithBlock:^{
        
    } onQueue:queue];
    [actor setExector:block];
    return actor;
}

- (void)execute {
    if (_exector) {
        _exector(self.messageChan);
    }
}


@end
