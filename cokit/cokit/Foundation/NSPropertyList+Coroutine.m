//
//  NSPropertyList+Coroutine.m
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

#import "NSPropertyList+Coroutine.h"
#import "COKitCommon.h"

@implementation NSPropertyListSerialization (COPromise)

+ (COPromise<NSNumber *> *)async_propertyList:(id)plist isValidForFormat:(NSPropertyListFormat)format{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            BOOL ret = [self propertyList:plist isValidForFormat:format];
            resolve(@(ret));
        } backgroundQueue:[COKitCommon io_queue]];
    }];
}

+ (COPromise<NSData *> *)async_dataWithPropertyList:(id)plist format:(NSPropertyListFormat)format options:(NSPropertyListWriteOptions)opt{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            NSData *data = [self dataWithPropertyList:plist format:format options:opt error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(data);
            }
        } backgroundQueue:[COKitCommon io_queue]];
    }];
}

+ (COPromise<NSNumber *> *)async_writePropertyList:(id)plist toStream:(NSOutputStream *)stream format:(NSPropertyListFormat)format options:(NSPropertyListWriteOptions)opt{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            NSInteger ret = [self writePropertyList:plist toStream:stream format:format options:opt error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(@(ret));
            }
        } backgroundQueue:[COKitCommon io_queue]];
    }];
}

+ (COPromise<id> *)async_propertyListWithData:(NSData *)data options:(NSPropertyListReadOptions)opt format:(NSPropertyListFormat *)format{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            id obj = [self propertyListWithData:data options:opt format:format error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(obj);
            }
        } backgroundQueue:[COKitCommon io_queue]];
    }];
}

+ (COPromise<id> *)async_propertyListWithStream:(NSInputStream *)stream options:(NSPropertyListReadOptions)opt format:(NSPropertyListFormat *)format{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            id obj = [self propertyListWithStream:stream options:opt format:format error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(obj);
            }
        } backgroundQueue:[COKitCommon io_queue]];
    }];
}

@end

@implementation NSPropertyListSerialization (Coroutine)

+ (BOOL)co_propertyList:(id)plist isValidForFormat:(NSPropertyListFormat)format{
    if ([COCoroutine currentCoroutine]) {
        return [await([self async_propertyList:plist isValidForFormat:format]) boolValue];
    }
    else{
        return [self propertyList:plist isValidForFormat:format];
    }
}

+ (NSData *)co_dataWithPropertyList:(id)plist format:(NSPropertyListFormat)format options:(NSPropertyListWriteOptions)opt error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        NSData *data = await([self async_dataWithPropertyList:plist format:format options:opt]);
        if (error) {
            *error = co_getError();
        }
        return data;
    }
    else{
        return [self dataWithPropertyList:plist format:format options:opt error:error];
    }
}

+ (BOOL)co_writePropertyList:(id)plist toStream:(NSOutputStream *)stream format:(NSPropertyListFormat)format options:(NSPropertyListWriteOptions)opt error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_writePropertyList:plist toStream:stream format:format options:opt]) boolValue];
        if (error) {
            *error = co_getError();
        }
        return ret;
    }
    else{
        return [self writePropertyList:plist toStream:stream format:format options:opt error:error];
    }
}

+ (id)co_propertyListWithData:(NSData *)data options:(NSPropertyListReadOptions)opt format:(NSPropertyListFormat *)format error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        id obj = await([self async_propertyListWithData:data options:opt format:format]);
        if (error) {
            *error = co_getError();
        }
        return obj;
    }
    else{
        return [self propertyListWithData:data options:opt format:format error:error];
    }
}

+ (id)co_propertyListWithStream:(NSInputStream *)stream options:(NSPropertyListReadOptions)opt format:(NSPropertyListFormat *)format error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        id obj = await([self async_propertyListWithStream:stream options:opt format:format]);
        if (error) {
            *error = co_getError();
        }
        return obj;
    }
    else{
        return [self propertyListWithStream:stream options:opt format:format error:error];
    }
}

@end
