//
//  NSURLConnection+Coroutine.m
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

#import "NSURLConnection+Coroutine.h"
#import "COKitCommon.h"

@implementation NSURLConnection (COPromise)

+ (COPromise<COTuple2<NSURLResponse *,NSData *> *> *)async_sendAsynchronousRequest:(NSURLRequest *)request{
    return [self async_sendAsynchronousRequest:request queue:[COKitCommon urlconnection_queue]];
}

+ (COPromise<COTuple2<NSURLResponse *,NSData *> *> *)async_sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if (connectionError) {
                reject(connectionError);
            }
            else{
                resolve(co_tuple(response, data));
            }
        }];
    }];
}

@end

@implementation NSURLConnection (Coroutine)

+ (NSData *)co_sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue response:(NSURLResponse *__autoreleasing  _Nullable *)response error:(NSError * _Nullable __autoreleasing *)error{
    SURE_ASYNC
    if ([COCoroutine currentCoroutine]) {
        NSURLResponse *resp = nil;
        NSData *data = nil;
        co_unpack(&resp, &data) = await([self async_sendAsynchronousRequest:request queue:queue]);
        if (error) {
            *error = co_getError();
        }
        if (response) {
            *response = resp;
        }
        return data;
    }
    else{
        @throw [NSException exceptionWithName:@"CoroutineError" reason:@"co_sendAsynchronousRequest must run in coroutine" userInfo:nil];
    }
}

+ (NSData *)co_sendAsynchronousRequest:(NSURLRequest *)request response:(NSURLResponse *__autoreleasing  _Nullable *)response error:(NSError * _Nullable __autoreleasing *)error{
    return [self co_sendAsynchronousRequest:request queue:[COKitCommon urlconnection_queue] response:response error:error];
}

+ (NSData *)co_sendAsynchronousRequest:(NSURLRequest *)request error:(NSError * _Nullable __autoreleasing *)error{
    return [self co_sendAsynchronousRequest:request response:nil error:error];
}

+ (NSData *)co_sendAsynchronousRequest:(NSURLRequest *)request{
    return [self co_sendAsynchronousRequest:request error:nil];
}

@end
