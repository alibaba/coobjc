//
//  NSBundle+Coroutine.m
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

#import "NSBundle+Coroutine.h"
#import "COKitCommon.h"
#import <coobjc/coobjc.h>

@implementation NSBundle (COPromise)

- (COPromise<NSNumber *> *)async_load{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSError *error = nil;
            BOOL ret = [self loadAndReturnError:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(@(ret));
            }
        });
    }];
}

@end

@implementation NSBundle (Coroutine)

- (BOOL)co_loadAndReturnError:(NSError **)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_load]) boolValue];
        if (error) {
            if (co_getError()) {
                *error = co_getError();
            }
            else{
                *error = nil;
            }
        }
        return ret;
    }
    else{
        return [self loadAndReturnError:error];
    }
}

@end
