//
//  NSArray+Coroutine.m
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

#import "NSArray+Coroutine.h"
#import "COKitCommon.h"
#import <coobjc/coobjc.h>

@implementation NSArray (Coroutine)

+ (NSArray *)co_arrayWithContentsOfURL:(NSURL *)url error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        NSArray *array = await([self async_arrayWithContentsOfURL:url]);
        if (error) {
            if (co_getError()) {
                *error = co_getError();
            }
        }
        return array;
    }
    else{
        if (@available(iOS 11.0, *)) {
            return [self arrayWithContentsOfURL:url error:error];
        }
        return [self arrayWithContentsOfURL:url];
    }
}

+ (NSArray *)co_arrayWithContentsOfURL:(NSURL *)url{
    return [self co_arrayWithContentsOfURL:url error:nil];
}

+ (NSArray *)co_arrayWithContentsOfFile:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        NSArray *array = await([self async_arrayWithContentsOfFile:path]);
        return array;
    }
    else{
        return [self arrayWithContentsOfFile:path];
    }
}

- (NSArray *)co_initWithContentsOfURL:(NSURL *)url error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        NSArray *array = await([self async_initWithContentsOfURL:url]);
        if (error) {
            if (co_getError()) {
                *error = co_getError();
            }
        }
        return array;
    }
    else{
        if (@available(iOS 11.0, *)) {
            return [self initWithContentsOfURL:url error:error];
        }
        return [self initWithContentsOfURL:url];
    }
}

- (NSArray *)co_initWithContentsOfURL:(NSURL *)url{
    return [self co_initWithContentsOfURL:url error:nil];
}

- (NSArray *)co_initWithContentsOfFile:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        NSArray *array = await([self async_initWithContentsOfFile:path]);
        return array;
    }
    else{
        return [self initWithContentsOfFile:path];
    }
}

- (BOOL)co_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile{
    if ([COCoroutine currentCoroutine]) {
        return [await([self async_writeToFile:path atomically:useAuxiliaryFile]) boolValue];
    }
    else{
        return [self writeToFile:path atomically:useAuxiliaryFile];
    }
}

- (BOOL)co_writeToURL:(NSURL *)url error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_writeToURL:url]) boolValue];
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
        return [self writeToURL:url error:error];
    }
}

- (BOOL)co_writeToURL:(NSURL *)url atomically:(BOOL)atomically{
    if ([COCoroutine currentCoroutine]) {
        return [await([self async_writeToURL:url atomically:atomically]) boolValue];
    }
    else{
        return [self writeToURL:url atomically:atomically];
    }
}

@end


@implementation NSArray (COPromise)

+ (COPromise *)async_arrayWithContentsOfURL:(NSURL *)url{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            if (@available(iOS 11.0, *)) {
                NSError *error = nil;
                NSArray *list = [self arrayWithContentsOfURL:url error:&error];
                if (error) {
                    reject(error);
                }
                else{
                    resolve(list);
                }
            }
            else{
                NSArray *list = [self arrayWithContentsOfURL:url];
                resolve(list);
            }
        });
    }];
}

+ (COPromise *)async_arrayWithContentsOfFile:(NSString *)path{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSArray *list = [self arrayWithContentsOfFile:path];
            resolve(list);
        });
    }];
}

- (COPromise *)async_initWithContentsOfURL:(NSURL *)url{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSError *error = nil;
            if (@available(iOS 11.0, *)) {
                NSArray *list = [self initWithContentsOfURL:url error:&error];
                if (error) {
                    reject(error);
                }
                else{
                    resolve(list);
                }
            }
            else{
                NSArray *list = [self initWithContentsOfURL:url];
                resolve(list);
            }
        });
    }];
}

- (COPromise *)async_initWithContentsOfFile:(NSString *)path{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSArray *list = [self initWithContentsOfFile:path];
            resolve(list);
        });
    }];
}

- (COPromise<NSNumber *> *)async_writeToURL:(NSURL *)url{
    COPromise *promise = [COPromise promise];
    dispatch_async([COKitCommon io_write_queue], ^{
        NSError *error = nil;
        BOOL ret = [self writeToURL:url error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    });
    return promise;
}

- (COPromise<NSNumber *> *)async_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile{
    COPromise *promise = [COPromise promise];
    dispatch_async([COKitCommon io_write_queue], ^{
        BOOL ret = [self writeToFile:path atomically:useAuxiliaryFile];
        [promise fulfill:@(ret)];
    });
    return promise;
}

- (COPromise<NSNumber *> *)async_writeToURL:(NSURL *)url atomically:(BOOL)atomically{
    COPromise *promise = [COPromise promise];
    dispatch_async([COKitCommon io_write_queue], ^{
        BOOL ret = [self writeToURL:url atomically:atomically];
        [promise fulfill:@(ret)];
    });
    return promise;
}

@end

@implementation NSMutableArray (Coroutine)

+ (NSMutableArray *)co_arrayWithContentsOfFile:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_arrayWithContentsOfFile:path]);
    }
    else{
        return [self arrayWithContentsOfFile:path];
    }
}

+ (NSMutableArray *)co_arrayWithContentsOfURL:(NSURL *)url{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_arrayWithContentsOfURL:url]);
    }
    else{
        return [self arrayWithContentsOfURL:url];
    }
}

- (NSMutableArray *)co_initWithContentsOfFile:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_initWithContentsOfFile:path]);
    }
    else{
        return [self initWithContentsOfFile:path];
    }
}

- (NSMutableArray *)co_initWithContentsOfURL:(NSURL *)url{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_initWithContentsOfURL:url]);
    }
    else{
        return [self initWithContentsOfURL:url];
    }
}

@end

@implementation NSMutableArray (COPromise)

+ (COPromise *)async_arrayWithContentsOfFile:(NSString *)path{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSArray *list = [self arrayWithContentsOfFile:path];
            resolve(list);
        });
    }];
}

+ (COPromise *)async_arrayWithContentsOfURL:(NSURL *)url{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSArray *list = [self arrayWithContentsOfURL:url];
            resolve(list);
        });
    }];
}

- (COPromise *)async_initWithContentsOfFile:(NSString *)path{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSArray *list = [self initWithContentsOfFile:path];
            resolve(list);
        });
    }];
}

- (COPromise *)async_initWithContentsOfURL:(NSURL *)url{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSArray *list = [self initWithContentsOfURL:url];
            resolve(list);
        });
    }];
}

@end
