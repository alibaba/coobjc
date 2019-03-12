//
//  NSString+Coroutine.m
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

#import "NSString+Coroutine.h"
#import <COKitCommon.h>

@implementation NSString (COPromise)

/* These use the specified encoding.  If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
- (COPromise<NSString*>*)async_initWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            NSString* str = [self initWithContentsOfURL:url encoding:enc error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(str);
            }
        } backgroundQueue:[COKitCommon io_queue]];
    }];
}
- (COPromise<NSString*>*)async_initWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            NSString* str = [self initWithContentsOfFile:path encoding:enc error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(str);
            }
        } backgroundQueue:[COKitCommon io_queue]];
    }];
}
+ (COPromise<NSString*>*)async_stringWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            NSString* str = [self stringWithContentsOfURL:url encoding:enc error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(str);
            }
        } backgroundQueue:[COKitCommon io_queue]];
    }];
}
+ (COPromise<NSString*>*)async_stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            NSString* str = [self stringWithContentsOfFile:path encoding:enc error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(str);
            }
        } backgroundQueue:[COKitCommon io_queue]];
    }];
}


/* These try to determine the encoding, and return the encoding which was used.  Note that these methods might get "smarter" in subsequent releases of the system, and use additional techniques for recognizing encodings. If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
- (COPromise<COTuple2<NSString*, NSNumber*>*>*)async_initWithContentsOfURL:(NSURL *)url{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            NSStringEncoding encoding = 0;
            NSString* str = [self initWithContentsOfURL:url usedEncoding:&encoding error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(co_tuple(str, @(encoding)));
            }
        } backgroundQueue:[COKitCommon io_queue]];
    }];
}
- (COPromise<COTuple2<NSString*, NSNumber*>*>*)async_initWithContentsOfFile:(NSString *)path{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            NSStringEncoding encoding = 0;
            NSString* str = [self initWithContentsOfFile:path usedEncoding:&encoding error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(co_tuple(str, @(encoding)));
            }
        } backgroundQueue:[COKitCommon io_queue]];
    }];
}
+ (COPromise<COTuple2<NSString*, NSNumber*>*>*)async_stringWithContentsOfURL:(NSURL *)url{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            NSStringEncoding encoding = 0;
            NSString* str = [self stringWithContentsOfURL:url usedEncoding:&encoding error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(co_tuple(str, @(encoding)));
            }
        } backgroundQueue:[COKitCommon io_queue]];
    }];
}
+ (COPromise<COTuple2<NSString*, NSNumber*>*>*)async_stringWithContentsOfFile:(NSString *)path{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            NSStringEncoding encoding = 0;
            NSString* str = [self stringWithContentsOfFile:path usedEncoding:&encoding error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(co_tuple(str, @(encoding)));
            }
        } backgroundQueue:[COKitCommon io_queue]];
    }];
}


/* Write to specified url or path using the specified encoding.  The optional error return is to indicate file system or encoding errors.
 */
- (COPromise<NSNumber*>*)async_writeToURL:(NSURL *)url atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc{
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlockOnBackgroundThread:^{
        NSError *error = nil;
        BOOL ret = [self writeToURL:url atomically:useAuxiliaryFile encoding:enc error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    } backgroundQueue:[COKitCommon io_queue]];
    return promise;
}
- (COPromise<NSNumber*>*)async_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc{
    
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlockOnBackgroundThread:^{
        NSError *error = nil;
        BOOL ret = [self writeToFile:path atomically:useAuxiliaryFile encoding:enc error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    } backgroundQueue:[COKitCommon io_queue]];
    return promise;
}

- (COPromise<id>*)async_stringToJSONObject{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            @try{
                NSError *jsonError = nil;
                id jsonObject = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&jsonError];
                if (!jsonError) {
                    resolve(jsonObject);
                }
                else{
                    reject(jsonError);
                }
            }
            @catch(NSException *e){
                reject([NSError errorWithDomain:@"jsonError" code:-1 userInfo:nil]);
            }
        } backgroundQueue:[COKitCommon json_queue]];
    }];
}

@end

@implementation NSString (Coroutine)

- (NSString *)co_initWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        NSString *result = await([self async_initWithContentsOfURL:url encoding:enc]);
        if (error) {
            *error = co_getError();
        }
        return result;
    }
    else{
        return [self initWithContentsOfURL:url encoding:enc error:error];
    }
}

- (NSString *)co_initWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        NSString *result = await([self async_initWithContentsOfFile:path encoding:enc]);
        if (error) {
            *error = co_getError();
        }
        return result;
    }
    else{
        return [self initWithContentsOfFile:path encoding:enc error:error];
    }
}

+ (NSString *)co_stringWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        NSString *result = await([self async_stringWithContentsOfURL:url encoding:enc]);
        if (error) {
            *error = co_getError();
        }
        return result;
    }
    else{
        return [self stringWithContentsOfURL:url encoding:enc error:error];
    }
}

+ (NSString *)co_stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        NSString *result = await([self async_stringWithContentsOfFile:path encoding:enc]);
        if (error) {
            *error = co_getError();
        }
        return result;
    }
    else{
        return [self stringWithContentsOfFile:path encoding:enc error:error];
    }
}

- (NSString *)co_initWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding *)enc error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        NSString *result = nil;
        id encoding;
        co_unpack(&result, &encoding) = await([self async_initWithContentsOfURL:url]);
        if (error) {
            *error = co_getError();
        }
        if (enc) {
            *enc = [encoding unsignedIntegerValue];
        }
        return result;
    }
    else{
        return [self initWithContentsOfURL:url usedEncoding:enc error:error];
    }
}

- (NSString *)co_initWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        NSString *result = nil;
        id encoding;
        co_unpack(&result, &encoding) = await([self async_initWithContentsOfFile:path]);
        if (error) {
            *error = co_getError();
        }
        if (enc) {
            *enc = [encoding unsignedIntegerValue];
        }
        return result;
    }
    else{
        return [self initWithContentsOfFile:path usedEncoding:enc error:error];
    }
}

+ (NSString *)co_stringWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding *)enc error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        NSString *result = nil;
        id encoding;
        co_unpack(&result, &encoding) = await([self async_stringWithContentsOfURL:url]);
        if (error) {
            *error = co_getError();
        }
        if (enc) {
            *enc = [encoding unsignedIntegerValue];
        }
        return result;
    }
    else{
        return [self stringWithContentsOfURL:url usedEncoding:enc error:error];
    }
}

+ (NSString *)co_stringWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        NSString *result = nil;
        id encoding;
        co_unpack(&result, &encoding) = await([self async_stringWithContentsOfFile:path]);
        if (error) {
            *error = co_getError();
        }
        if (enc) {
            *enc = [encoding unsignedIntegerValue];
        }
        return result;
    }
    else{
        return [self stringWithContentsOfFile:path usedEncoding:enc error:error];
    }
}

- (BOOL)co_writeToURL:(NSURL *)url atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_writeToURL:url atomically:useAuxiliaryFile encoding:enc]) boolValue];
        if (error) {
            *error = co_getError();
        }
        return ret;
    }
    else{
        return [self writeToURL:url atomically:useAuxiliaryFile encoding:enc error:error];
    }
}

- (BOOL)co_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_writeToFile:path atomically:useAuxiliaryFile encoding:enc]) boolValue];
        if (error) {
            *error = co_getError();
        }
        return ret;
    }
    else{
        return [self writeToFile:path atomically:useAuxiliaryFile encoding:enc error:error];
    }
}

- (id)co_stringToJSONObject{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_stringToJSONObject]);
    }
    else{
        @try{
            NSError *jsonError = nil;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&jsonError];
            if (!jsonError) {
                return jsonObject;
            }
            else{
                return nil;
            }
        }
        @catch(NSException *e){
            return nil;
        }
    }
}

@end
