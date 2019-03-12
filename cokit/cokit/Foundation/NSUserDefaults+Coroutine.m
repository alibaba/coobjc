//
//  NSUserDefaults+Coroutine.m
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

#import "NSUserDefaults+Coroutine.h"
#import "COKitCommon.h"

@implementation NSUserDefaults (COPromise)

- (COPromise<id> *)async_objectForKey:(NSString *)defaultName{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlock:^{
            id value = [self objectForKey:defaultName];
            resolve(value);
        } onQueue:[COKitCommon userDefaults_queue]];
    }];
}

- (COPromise *)async_setObject:(id)value forKey:(NSString *)defaultName{
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlock:^{
        [self setObject:value forKey:defaultName];
        [promise fulfill:nil];
    } onQueue:[COKitCommon userDefaults_queue]];
    return promise;
}

- (COPromise *)async_removeObjectForKey:(NSString *)defaultName{
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlock:^{
        [self removeObjectForKey:defaultName];
        [promise fulfill:nil];
    } onQueue:[COKitCommon userDefaults_queue]];
    return promise;
}

- (COPromise<NSString *> *)async_stringForKey:(NSString *)defaultName{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlock:^{
            id value = [self stringForKey:defaultName];
            resolve(value);
        } onQueue:[COKitCommon userDefaults_queue]];
    }];
}

- (COPromise<NSArray *> *)async_arrayForKey:(NSString *)defaultName{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlock:^{
            id value = [self arrayForKey:defaultName];
            resolve(value);
        } onQueue:[COKitCommon userDefaults_queue]];
    }];
}

- (COPromise<NSDictionary<NSString *,id> *> *)async_dictionaryForKey:(NSString *)defaultName{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlock:^{
            id value = [self dictionaryForKey:defaultName];
            resolve(value);
        } onQueue:[COKitCommon userDefaults_queue]];
    }];
}

- (COPromise<NSData *> *)async_dataForKey:(NSString *)defaultName{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlock:^{
            id value = [self dataForKey:defaultName];
            resolve(value);
        } onQueue:[COKitCommon userDefaults_queue]];
    }];
}

- (COPromise<NSArray<NSString *> *> *)async_stringArrayForKey:(NSString *)defaultName{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlock:^{
            id value = [self stringArrayForKey:defaultName];
            resolve(value);
        } onQueue:[COKitCommon userDefaults_queue]];
    }];
}

- (COPromise<NSURL *> *)async_URLForKey:(NSString *)defaultName{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlock:^{
            id value = [self URLForKey:defaultName];
            resolve(value);
        } onQueue:[COKitCommon userDefaults_queue]];
    }];
}

- (COPromise *)async_setInteger:(NSInteger)value forKey:(NSString *)defaultName{
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlock:^{
        [self setInteger:value forKey:defaultName];
        [promise fulfill:nil];
    } onQueue:[COKitCommon userDefaults_queue]];
    return promise;
}

- (COPromise *)async_setFloat:(float)value forKey:(NSString *)defaultName{
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlock:^{
        [self setFloat:value forKey:defaultName];
        [promise fulfill:nil];
    } onQueue:[COKitCommon userDefaults_queue]];
    return promise;
}

- (COPromise *)async_setDouble:(double)value forKey:(NSString *)defaultName{
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlock:^{
        [self setDouble:value forKey:defaultName];
        [promise fulfill:nil];
    } onQueue:[COKitCommon userDefaults_queue]];
    return promise;
}

- (COPromise *)async_setBool:(BOOL)value forKey:(NSString *)defaultName{
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlock:^{
        [self setBool:value forKey:defaultName];
        [promise fulfill:nil];
    } onQueue:[COKitCommon userDefaults_queue]];
    return promise;
}

- (COPromise *)async_setURL:(NSURL *)url forKey:(NSString *)defaultName{
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlock:^{
        [self setURL:url forKey:defaultName];
        [promise fulfill:nil];
    } onQueue:[COKitCommon userDefaults_queue]];
    return promise;
}

- (COPromise<NSNumber *> *)async_synchronize{
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlock:^{
        [promise fulfill:@([self synchronize])];
    } onQueue:[COKitCommon userDefaults_queue]];
    return promise;
}

@end

@implementation NSUserDefaults (Coroutine)

- (id)co_objectForKey:(NSString *)defaultName{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_objectForKey:defaultName]);
    }
    else{
        return [self objectForKey:defaultName];
    }
}

- (void)co_setObject:(id)value forKey:(NSString *)defaultName{
    if ([COCoroutine currentCoroutine]) {
        await([self async_setObject:value forKey:defaultName]);
    }
    else{
        [self setObject:value forKey:defaultName];
    }
}

- (void)co_removeObjectForKey:(NSString *)defaultName{
    if ([COCoroutine currentCoroutine]) {
        await([self async_removeObjectForKey:defaultName]);
    }
    else{
        [self removeObjectForKey:defaultName];
    }
}

- (NSString *)co_stringForKey:(NSString *)defaultName{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_stringForKey:defaultName]);
    }
    else{
        return [self stringForKey:defaultName];
    }
}

- (NSArray *)co_arrayForKey:(NSString *)defaultName{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_arrayForKey:defaultName]);
    }
    else{
        return [self arrayForKey:defaultName];
    }
}

- (NSDictionary<NSString *,id> *)co_dictionaryForKey:(NSString *)defaultName{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_dictionaryForKey:defaultName]);
    }
    else{
        return [self dictionaryForKey:defaultName];
    }
}

- (NSData *)co_dataForKey:(NSString *)defaultName{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_dataForKey:defaultName]);
    }
    else{
        return [self dataForKey:defaultName];
    }
}

- (NSArray<NSString *> *)co_stringArrayForKey:(NSString *)defaultName{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_stringArrayForKey:defaultName]);
    }
    else{
        return [self stringArrayForKey:defaultName];
    }
}

- (NSInteger)co_integerForKey:(NSString *)defaultName{
    if ([COCoroutine currentCoroutine]) {
        COPromise *promise = [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
            [COKitCommon runBlock:^{
                NSInteger value = [self integerForKey:defaultName];
                resolve(@(value));
            } onQueue:[COKitCommon userDefaults_queue]];
        }];
        return [await(promise) integerValue];
    }
    else{
        return [self integerForKey:defaultName];
    }
}

- (float)co_floatForKey:(NSString *)defaultName{
    if ([COCoroutine currentCoroutine]) {
        COPromise *promise = [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
            [COKitCommon runBlock:^{
                float value = [self floatForKey:defaultName];
                resolve(@(value));
            } onQueue:[COKitCommon userDefaults_queue]];
        }];
        return [await(promise) floatValue];
    }
    else{
        return [self floatForKey:defaultName];
    }
}

- (double)co_doubleForKey:(NSString *)defaultName{
    if ([COCoroutine currentCoroutine]) {
        COPromise *promise = [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
            [COKitCommon runBlock:^{
                double value = [self doubleForKey:defaultName];
                resolve(@(value));
            } onQueue:[COKitCommon userDefaults_queue]];
        }];
        return [await(promise) doubleValue];
    }
    else{
        return [self doubleForKey:defaultName];
    }
}

- (BOOL)co_boolForKey:(NSString *)defaultName{
    if ([COCoroutine currentCoroutine]) {
        COPromise *promise = [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
            [COKitCommon runBlock:^{
                BOOL value = [self boolForKey:defaultName];
                resolve(@(value));
            } onQueue:[COKitCommon userDefaults_queue]];
        }];
        return [await(promise) boolValue];
    }
    else{
        return [self boolForKey:defaultName];
    }
}

- (NSURL *)co_URLForKey:(NSString *)defaultName{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_URLForKey:defaultName]);
    }
    else{
        return [self URLForKey:defaultName];
    }
}

- (void)co_setInteger:(NSInteger)value forKey:(NSString *)defaultName{
    if ([COCoroutine currentCoroutine]) {
        await([self async_setInteger:value forKey:defaultName]);
    }
    else{
        [self setInteger:value forKey:defaultName];
    }
}

- (void)co_setDouble:(double)value forKey:(NSString *)defaultName{
    if ([COCoroutine currentCoroutine]) {
        await([self async_setDouble:value forKey:defaultName]);
    }
    else{
        [self setDouble:value forKey:defaultName];
    }
}

- (void)co_setFloat:(float)value forKey:(NSString *)defaultName{
    if ([COCoroutine currentCoroutine]) {
        await([self async_setFloat:value forKey:defaultName]);
    }
    else{
        [self setFloat:value forKey:defaultName];
    }
}

- (void)co_setBool:(BOOL)value forKey:(NSString *)defaultName{
    if ([COCoroutine currentCoroutine]) {
        await([self async_setBool:value forKey:defaultName]);
    }
    else{
        [self setBool:value forKey:defaultName];
    }
}

- (void)co_setURL:(NSURL *)url forKey:(NSString *)defaultName{
    if ([COCoroutine currentCoroutine]) {
        await([self async_setURL:url forKey:defaultName]);
    }
    else{
        [self setURL:url forKey:defaultName];
    }
}

- (BOOL)co_synchronize{
    if ([COCoroutine currentCoroutine]) {
        return [await([self async_synchronize]) boolValue];
    }
    else{
        return [self synchronize];
    }
}

@end
