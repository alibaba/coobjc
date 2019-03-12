//
//  NSData+Coroutine.m
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

#import "NSData+Coroutine.h"
#import "COKitCommon.h"

@implementation NSData (Coroutine)

- (BOOL)co_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile{
    if ([COCoroutine currentCoroutine]) {
        return [await([self async_writeToFile:path atomically:useAuxiliaryFile]) boolValue];
    }
    return [self writeToFile:path atomically:useAuxiliaryFile];
}

- (BOOL)co_writeToFile:(NSString *)path options:(NSDataWritingOptions)writeOptionsMask error:(NSError *__autoreleasing *)errorPtr{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_writeToFile:path options:writeOptionsMask]) boolValue];
        if (errorPtr) {
            if (co_getError()) {
                *errorPtr = co_getError();
            }
            else{
                *errorPtr = nil;
            }
        }
        return ret;
    }
    return [self writeToFile:path atomically:writeOptionsMask];
}

- (BOOL)co_writeToURL:(NSURL *)url atomically:(BOOL)atomically{
    if ([COCoroutine currentCoroutine]) {
        return [await([self async_writeToURL:url atomically:atomically]) boolValue];
    }
    return [self writeToURL:url atomically:atomically];
}

- (BOOL)co_writeToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_writeToURL:url options:writeOptionsMask]) boolValue];
        if (errorPtr) {
            if (co_getError()) {
                *errorPtr = co_getError();
            }
            else{
                *errorPtr = nil;
            }
        }
        return ret;
    }
    return [self writeToURL:url options:writeOptionsMask error:errorPtr];
}

+ (NSData *)co_dataWithContentsOfURL:(NSURL *)url{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_dataWithContentsOfURL:url]);
    }
    return [self dataWithContentsOfURL:url];
}

+ (NSData *)co_dataWithContentsOfFile:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_dataWithContentsOfFile:path]);
    }
    return [self dataWithContentsOfFile:path];
}

+ (NSData *)co_dataWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr{
    if ([COCoroutine currentCoroutine]) {
        NSData *data = await([self async_dataWithContentsOfURL:url options:readOptionsMask]);
        if (errorPtr) {
            if (co_getError()) {
                *errorPtr = co_getError();
            }
            else{
                *errorPtr = nil;
            }
        }
        return data;
    }
    return [self dataWithContentsOfURL:url options:readOptionsMask error:errorPtr];
}

+ (NSData *)co_dataWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError *__autoreleasing *)errorPtr{
    if ([COCoroutine currentCoroutine]) {
        NSData *data = await([self async_dataWithContentsOfFile:path options:readOptionsMask]);
        if (errorPtr) {
            if (co_getError()) {
                *errorPtr = co_getError();
            }
            else{
                *errorPtr = nil;
            }
        }
        return data;
    }
    return [self dataWithContentsOfFile:path options:readOptionsMask error:errorPtr];
}

- (NSData *)co_initWithContentsOfURL:(NSURL *)url{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_initWithContentsOfURL:url]);
    }
    return [self initWithContentsOfURL:url];
}

- (NSData *)co_initWithContentsOfFile:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_initWithContentsOfFile:path]);
    }
    return [self initWithContentsOfFile:path];
}

- (NSData *)co_initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError *__autoreleasing *)errorPtr{
    if ([COCoroutine currentCoroutine]) {
        NSData *data = await([self async_initWithContentsOfURL:url options:readOptionsMask]);
        if (errorPtr) {
            if (co_getError()) {
                *errorPtr = co_getError();
            }
            else{
                *errorPtr = nil;
            }
        }
        return data;
    }
    return [self initWithContentsOfURL:url options:readOptionsMask error:errorPtr];
}

- (NSData *)co_initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError *__autoreleasing *)errorPtr{
    if ([COCoroutine currentCoroutine]) {
        NSData *data = await([self async_initWithContentsOfFile:path options:readOptionsMask]);
        if (errorPtr) {
            if (co_getError()) {
                *errorPtr = co_getError();
            }
            else{
                *errorPtr = nil;
            }
        }
        return data;
    }
    return [self initWithContentsOfFile:path options:readOptionsMask error:errorPtr];
}

@end

@implementation NSData (COPromise)

- (COPromise<NSNumber*>*)async_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile{
    COPromise *promise = [COPromise promise];
    dispatch_async([COKitCommon io_write_queue], ^{
        BOOL ret = [self writeToFile:path atomically:useAuxiliaryFile];
        [promise fulfill:@(ret)];
    });
    return promise;
}
- (COPromise<NSNumber*>*)async_writeToURL:(NSURL *)url atomically:(BOOL)atomically // the atomically flag is ignored if the url is not of a type the supports atomic writes
{
    COPromise *promise = [COPromise promise];
    dispatch_async([COKitCommon io_write_queue], ^{
        BOOL ret = [self writeToURL:url atomically:atomically];
        [promise fulfill:@(ret)];
    });
    return promise;
}
- (COPromise<NSNumber*>*)async_writeToFile:(NSString *)path options:(NSDataWritingOptions)writeOptionsMask{
    COPromise *promise = [COPromise promise];
    dispatch_async([COKitCommon io_write_queue], ^{
        NSError *error = nil;
        BOOL ret = [self writeToFile:path options:writeOptionsMask error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    });
    return promise;
}
- (COPromise<NSNumber*>*)async_writeToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask{
    COPromise *promise = [COPromise promise];
    dispatch_async([COKitCommon io_write_queue], ^{
        NSError *error = nil;
        BOOL ret = [self writeToURL:url options:writeOptionsMask error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    });
    return promise;
}


+ (COPromise<NSData*>*)async_dataWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSError *error = nil;
            NSData *data = [self dataWithContentsOfFile:path options:readOptionsMask error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(data);
            }
        });
    }];
}
+ (COPromise<NSData*>*)async_dataWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSError *error = nil;
            NSData *data = [self dataWithContentsOfURL:url options:readOptionsMask error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(data);
            }
        });
    }];
}
+ (COPromise<NSData*>*)async_dataWithContentsOfFile:(NSString *)path{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSData *data = [self dataWithContentsOfFile:path];
            resolve(data);
        });
    }];
}
+ (COPromise<NSData*>*)async_dataWithContentsOfURL:(NSURL *)url{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSData *data = [self dataWithContentsOfURL:url];
            resolve(data);
        });
    }];
}


- (COPromise<NSData*>*)async_initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSError *error = nil;
            NSData *data = [self initWithContentsOfFile:path options:readOptionsMask error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(data);
            }
        });
    }];
}
- (COPromise<NSData*>*)async_initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSError *error = nil;
            NSData *data = [self initWithContentsOfURL:url options:readOptionsMask error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(data);
            }
        });
    }];
}
- (COPromise<NSData*>*)async_initWithContentsOfFile:(NSString *)path{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSData *data = [self initWithContentsOfFile:path];
            resolve(data);
        });
    }];
}
- (COPromise<NSData*>*)async_initWithContentsOfURL:(NSURL *)url{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSData *data = [self initWithContentsOfURL:url];
            resolve(data);
        });
    }];
}

@end
