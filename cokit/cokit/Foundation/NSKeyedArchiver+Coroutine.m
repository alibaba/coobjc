//
//  NSKeyedArchiver+Coroutine.m
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

#import "NSKeyedArchiver+Coroutine.h"
#import "COKitCommon.h"

@implementation NSKeyedArchiver (COPromise)

+ (COPromise<NSData *> *)async_archivedDataWithRootObject:(id)rootObject{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSData *data = [self archivedDataWithRootObject:rootObject];
            resolve(data);
        } backgroundQueue:[COKitCommon archieve_queue]];
    }];
}

+ (COPromise<NSNumber *> *)async_archiveRootObject:(id)rootObject toFile:(NSString *)path{
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlockOnBackgroundThread:^{
        BOOL ret = [self archiveRootObject:rootObject toFile:path];
        [promise fulfill:@(ret)];
    } backgroundQueue:[COKitCommon archieve_queue]];
    return promise;
}


@end

@implementation NSKeyedArchiver (Coroutine)

+ (NSData*)co_archivedDataWithRootObject:(id)rootObject{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_archivedDataWithRootObject:rootObject]);
    }
    else{
        return [self archivedDataWithRootObject:rootObject];
    }
}
+ (BOOL)co_archiveRootObject:(id)rootObject toFile:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        return [await([self async_archiveRootObject:rootObject toFile:path]) boolValue];
    }
    else{
        return [self archiveRootObject:rootObject toFile:path];
    }
}

@end

@implementation NSKeyedUnarchiver (COPromise)

+ (COPromise<id> *)async_unarchiveObjectWithData:(NSData *)data{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            id obj = [self unarchiveObjectWithData:data];
            resolve(obj);
        } backgroundQueue:[COKitCommon archieve_queue]];
    }];
}

+ (COPromise<id> *)async_unarchiveTopLevelObjectWithData:(NSData *)data{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            id obj = [self unarchiveTopLevelObjectWithData:data error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(obj);
            }
        } backgroundQueue:[COKitCommon archieve_queue]];
    }];
}

+ (COPromise<id> *)async_unarchiveObjectWithFile:(NSString *)path{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            id obj = [self unarchiveObjectWithFile:path];
            resolve(obj);
        } backgroundQueue:[COKitCommon archieve_queue]];
    }];
}

@end

@implementation NSKeyedUnarchiver (Coroutine)

+ (id)co_unarchiveObjectWithData:(NSData *)data{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_unarchiveObjectWithData:data]);
    }
    else{
        return [self unarchiveObjectWithData:data];
    }
}

+ (id)co_unarchiveObjectWithFile:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_unarchiveObjectWithFile:path]);
    }
    else{
        return [self unarchiveObjectWithFile:path];
    }
}

+ (id)co_unarchiveTopLevelObjectWithData:(NSData *)data error:(NSError * _Nullable __autoreleasing * _Nullable)error{
    if ([COCoroutine currentCoroutine]) {
        id obj = await([self async_unarchiveTopLevelObjectWithData:data]);
        if (error) {
            *error = co_getError();
        }
        return obj;
    }
    else{
        return [self unarchiveTopLevelObjectWithData:data error:error];
    }
}

@end
