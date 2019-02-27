//
//  COKitCommon.m
//  cokit
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

#import "COKitCommon.h"
#import <coobjc/co_queue.h>

@implementation COKitCommon

// TODO: 并发数量控制,是否应该用 NSOperationQueue.
// TODO: 是否应该用异步io接口 dispatch_io?
+ (dispatch_queue_t)io_queue{
    static dispatch_queue_t q = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        q = dispatch_queue_create("com.cokit.io", DISPATCH_QUEUE_CONCURRENT);
    });
    return q;
}

+ (dispatch_queue_t)image_queue{
    return [self io_queue];
}

+ (dispatch_queue_t)io_write_queue{
    static dispatch_queue_t q = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        q = dispatch_queue_create("com.cokit.io_write", DISPATCH_QUEUE_CONCURRENT);
    });
    return q;
}

+ (dispatch_queue_t)filemanager_queue{
    static dispatch_queue_t q = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        q = dispatch_queue_create("com.cokit.filemanager", DISPATCH_QUEUE_SERIAL);
    });
    return q;
}

+ (NSOperationQueue*)urlconnection_queue{
    static NSOperationQueue *q = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        q = [[NSOperationQueue alloc] init];
        q.maxConcurrentOperationCount = 2;
    });
    return q;
}

+ (dispatch_queue_t)json_queue{
    return [self io_queue];
}

+ (dispatch_queue_t)archieve_queue{
    return [self io_queue];
}

+ (dispatch_queue_t)userDefaults_queue{
    static dispatch_queue_t q = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        q = dispatch_queue_create("com.cokit.userDefaults", DISPATCH_QUEUE_SERIAL);
    });
    return q;
}

+ (void)runBlock:(dispatch_block_t)block
         onQueue:(dispatch_queue_t)queue{
    if (co_get_current_queue() == queue) {
        block();
    }
    else{
        dispatch_async(queue, block);
    }
}

+ (void)runBlockOnBackgroundThread:(dispatch_block_t)block
                   backgroundQueue:(dispatch_queue_t)queue{
    if ([NSThread isMainThread]) {
        dispatch_async(queue, block);
    }
    else{
        block();
    }
}

@end
