//
//  NSDictionary+Coroutine.m
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

#import "NSDictionary+Coroutine.h"
#import "COKitCommon.h"

@implementation NSDictionary (COPromise)

/* Serializes this instance to the specified URL in the NSPropertyList format (using NSPropertyListXMLFormat_v1_0). For other formats use NSPropertyListSerialization directly. */
- (COPromise<NSNumber*>*)async_writeToURL:(NSURL *)url API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0)){
    COPromise *promise = [COPromise promise];
    dispatch_async([COKitCommon io_write_queue], ^{
        NSError *error = nil;
        BOOL ret = [self writeToURL:url error:&error];
        if(error){
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    });
    return promise;
}

+ (COPromise *)async_dictionaryWithContentsOfURL:(NSURL *)url{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSDictionary *dict = [self dictionaryWithContentsOfURL:url];
            resolve(dict);
        });
    }];
}
+ (COPromise *)async_dictionaryWithContentsOfFile:(NSString *)path{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSDictionary *dict = [self dictionaryWithContentsOfFile:path];
            resolve(dict);
        });
    }];
}

- (COPromise *)async_initWithContentsOfFile:(NSString *)path{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSDictionary *dict = [self initWithContentsOfFile:path];
            resolve(dict);
        });
    }];
}

- (COPromise *)async_initWithContentsOfURL:(NSURL *)url{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            if ([self respondsToSelector:@selector(initWithContentsOfURL:error:)]) {
                NSError *error = nil;
                if (@available(iOS 11.0, *)) {
                    NSDictionary *dict = [self initWithContentsOfURL:url error:&error];
                    if (error) {
                        reject(error);
                    }
                    else{
                        resolve(dict);
                    }
                } else {
                    resolve(nil);
                }
            }
            else{
                NSDictionary *dict = [self initWithContentsOfURL:url];
                resolve(dict);
            }
            
        });
    }];
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

@implementation NSDictionary (Coroutine)

/* Serializes this instance to the specified URL in the NSPropertyList format (using NSPropertyListXMLFormat_v1_0). For other formats use NSPropertyListSerialization directly. */
- (BOOL)co_writeToURL:(NSURL *)url error:(NSError**)error API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0))
{
    if([COCoroutine currentCoroutine]){
        BOOL ret = [await([self async_writeToURL:url]) boolValue];
        if(error){
            if(co_getError()){
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

+ (NSDictionary *)co_dictionaryWithContentsOfFile:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_dictionaryWithContentsOfFile:path]);
    }
    else{
        return [self dictionaryWithContentsOfFile:path];
    }
}
+ (NSDictionary *)co_dictionaryWithContentsOfURL:(NSURL *)url{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_dictionaryWithContentsOfURL:url]);
    }
    else{
        return [self dictionaryWithContentsOfURL:url];
    }
}
- (NSDictionary *)co_initWithContentsOfFile:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_initWithContentsOfFile:path]);
    }
    else{
        return [self initWithContentsOfFile:path];
    }
}
- (NSDictionary *)co_initWithContentsOfURL:(NSURL *)url{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_initWithContentsOfURL:url]);
    }
    else{
        return [self initWithContentsOfURL:url];
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
- (BOOL)co_writeToURL:(NSURL *)url atomically:(BOOL)atomically // the atomically flag is ignored if url of a type that cannot be written atomically.
{
    if ([COCoroutine currentCoroutine]) {
        return [await([self async_writeToURL:url atomically:atomically]) boolValue];
    }
    else{
        return [self writeToURL:url atomically:atomically];
    }
}

@end

@implementation NSMutableDictionary (COPromise)

+ (COPromise *)async_dictionaryWithContentsOfFile:(NSString *)path{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSMutableDictionary *dict = [self dictionaryWithContentsOfFile:path];
            resolve(dict);
        });
    }];
}

+ (COPromise *)async_dictionaryWithContentsOfURL:(NSURL *)url{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSMutableDictionary *dict = [self dictionaryWithContentsOfURL:url];
            resolve(dict);
        });
    }];
}

- (COPromise *)async_initWithContentsOfFile:(NSString *)path{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSMutableDictionary *dict = [self initWithContentsOfFile:path];
            resolve(dict);
        });
    }];
}

- (COPromise *)async_initWithContentsOfURL:(NSURL *)url{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        dispatch_async([COKitCommon io_queue], ^{
            NSMutableDictionary *dict = [self initWithContentsOfURL:url];
            resolve(dict);
        });
    }];
}

@end

@implementation NSMutableDictionary (Coroutine)

+ (NSMutableDictionary *)co_dictionaryWithContentsOfFile:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_dictionaryWithContentsOfFile:path]);
    }
    else{
        return [self dictionaryWithContentsOfFile:path];
    }
}

+ (NSMutableDictionary *)co_dictionaryWithContentsOfURL:(NSURL *)url{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_dictionaryWithContentsOfURL:url]);
    }
    else{
        return [self dictionaryWithContentsOfURL:url];
    }
}

- (NSMutableDictionary *)co_initWithContentsOfURL:(NSURL *)url{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_initWithContentsOfURL:url]);
    }
    else{
        return [self initWithContentsOfURL:url];
    }
}

- (NSMutableDictionary *)co_initWithContentsOfFile:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_initWithContentsOfFile:path]);
    }
    else{
        return [self initWithContentsOfFile:path];
    }
}

@end

