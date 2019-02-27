//
//  NSJSONSerialization+Coroutine.m
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

#import "NSJSONSerialization+Coroutine.h"
#import "COKitCommon.h"

@implementation NSJSONSerialization (COPromise)

+ (COPromise<NSNumber *> *)async_isValidJSONObject:(id)obj{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            BOOL ret = [self isValidJSONObject:obj];
            resolve(@(ret));
        } backgroundQueue:[COKitCommon json_queue]];
    }];
}

+ (COPromise<NSData *> *)async_dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            NSData* data = [self dataWithJSONObject:obj options:opt error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(data);
            }
        } backgroundQueue:[COKitCommon json_queue]];
    }];
}

+ (COPromise<id> *)async_JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            id obj = [self JSONObjectWithData:data options:opt error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(obj);
            }
        } backgroundQueue:[COKitCommon json_queue]];
    }];
}

+ (COPromise<NSNumber *> *)async_writeJSONObject:(id)obj toStream:(NSOutputStream *)stream options:(NSJSONWritingOptions)opt{
    COPromise *promise = [COPromise promise];
    
    [COKitCommon runBlockOnBackgroundThread:^{
        NSError *error = nil;
        BOOL ret = [self writeJSONObject:obj toStream:stream options:opt error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    } backgroundQueue:[COKitCommon json_queue]];
    return promise;
}

+ (COPromise<id> *)async_JSONObjectWithStream:(NSInputStream *)stream options:(NSJSONReadingOptions)opt{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            id obj = [self JSONObjectWithStream:stream options:opt error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(obj);
            }
        } backgroundQueue:[COKitCommon json_queue]];
    }];
}

@end

@implementation NSJSONSerialization (Coroutine)

/* Returns YES if the given object can be converted to JSON data, NO otherwise. The object must have the following properties:
 - Top level object is an NSArray or NSDictionary
 - All objects are NSString, NSNumber, NSArray, NSDictionary, or NSNull
 - All dictionary keys are NSStrings
 - NSNumbers are not NaN or infinity
 Other rules may apply. Calling this method or attempting a conversion are the definitive ways to tell if a given object can be converted to JSON data.
 */
+ (BOOL)co_isValidJSONObject:(id)obj CO_ASYNC
{
    if ([COCoroutine currentCoroutine]) {
        return [await([self async_isValidJSONObject:obj]) boolValue];
    }
    else{
        return [self isValidJSONObject:obj];
    }
}

/* Generate JSON data from a Foundation object. If the object will not produce valid JSON then an exception will be thrown. Setting the NSJSONWritingPrettyPrinted option will generate JSON with whitespace designed to make the output more readable. If that option is not set, the most compact possible JSON will be generated. If an error occurs, the error parameter will be set and the return value will be nil. The resulting data is a encoded in UTF-8.
 */
+ (NSData *)co_dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError**)error CO_ASYNC
{
    if ([COCoroutine currentCoroutine]) {
        NSData *data = await([self async_dataWithJSONObject:obj options:opt]);
        if (error) {
            *error = co_getError();
        }
        return data;
    }
    else{
        return [self dataWithJSONObject:obj options:opt error:error];
    }
}

/* Create a Foundation object from JSON data. Set the NSJSONReadingAllowFragments option if the parser should allow top-level objects that are not an NSArray or NSDictionary. Setting the NSJSONReadingMutableContainers option will make the parser generate mutable NSArrays and NSDictionaries. Setting the NSJSONReadingMutableLeaves option will make the parser generate mutable NSString objects. If an error occurs during the parse, then the error parameter will be set and the result will be nil.
 The data must be in one of the 5 supported encodings listed in the JSON specification: UTF-8, UTF-16LE, UTF-16BE, UTF-32LE, UTF-32BE. The data may or may not have a BOM. The most efficient encoding to use for parsing is UTF-8, so if you have a choice in encoding the data passed to this method, use UTF-8.
 */
+ (id)co_JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError**)error CO_ASYNC
{
    if ([COCoroutine currentCoroutine]) {
        id obj = await([self async_JSONObjectWithData:data options:opt]);
        if (error) {
            *error = co_getError();
        }
        return obj;
    }
    else{
        return [self JSONObjectWithData:data options:opt error:error];
    }
}

/* Write JSON data into a stream. The stream should be opened and configured. The return value is the number of bytes written to the stream, or 0 on error. All other behavior of this method is the same as the dataWithJSONObject:options:error: method.
 */
+ (BOOL)co_writeJSONObject:(id)obj toStream:(NSOutputStream *)stream options:(NSJSONWritingOptions)opt error:(NSError**)error CO_ASYNC
{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_writeJSONObject:obj toStream:stream options:opt]) boolValue];
        if (error) {
            *error = co_getError();
        }
        return ret;
    }
    else{
        return [self writeJSONObject:obj toStream:stream options:opt error:error];
    }
}

/* Create a JSON object from JSON data stream. The stream should be opened and configured. All other behavior of this method is the same as the JSONObjectWithData:options:error: method.
 */
+ (id)co_JSONObjectWithStream:(NSInputStream *)stream options:(NSJSONReadingOptions)opt error:(NSError**)error CO_ASYNC
{
    if ([COCoroutine currentCoroutine]) {
        id obj = await([self async_JSONObjectWithStream:stream options:opt]);
        if (error) {
            *error = co_getError();
        }
        return obj;
    }
    else{
        return [self JSONObjectWithStream:stream options:opt error:error];
    }
}

@end
