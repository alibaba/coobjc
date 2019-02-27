//
//  NSFileManager+Coroutine.m
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

#import "NSFileManager+Coroutine.h"
#import "COKitCommon.h"

@implementation NSFileManager (Coroutine)

- (BOOL)co_createDirectoryAtURL:(NSURL *)url withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary<NSFileAttributeKey,id> *)attributes error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_createDirectoryAtURL:url withIntermediateDirectories:createIntermediates attributes:attributes]) boolValue];
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
        return [self createDirectoryAtURL:url withIntermediateDirectories:createIntermediates attributes:attributes error:error];
    }
}

- (BOOL)co_createSymbolicLinkAtURL:(NSURL *)url withDestinationURL:(NSURL *)destURL error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_createSymbolicLinkAtURL:url withDestinationURL:destURL]) boolValue];
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
        return [self createSymbolicLinkAtURL:url withDestinationURL:destURL error:error];
    }
}

- (BOOL)co_setAttributes:(NSDictionary<NSFileAttributeKey,id> *)attributes ofItemAtPath:(NSString *)path error:(NSError**)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_setAttributes:attributes ofItemAtPath:path]) boolValue];
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
        return [self setAttributes:attributes ofItemAtPath:path error:error];
    }
}

- (BOOL)co_createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary<NSFileAttributeKey,id> *)attributes error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_createDirectoryAtPath:path withIntermediateDirectories:createIntermediates attributes:attributes]) boolValue];
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
        return [self createDirectoryAtPath:path withIntermediateDirectories:createIntermediates attributes:attributes error:error];
    }
}

- (NSArray<NSString *> *)co_contentsOfDirectoryAtPath:(NSString *)path error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        NSArray *list = await([self async_contentsOfDirectoryAtPath:path]);
        if (error) {
            if (co_getError()) {
                *error = co_getError();
            }
            else{
                *error = nil;
            }
        }
        return list;
    }
    else{
        return [self contentsOfDirectoryAtPath:path error:error];
    }
}

- (NSArray<NSString *> *)co_subpathsOfDirectoryAtPath:(NSString *)path error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        NSArray *list = await([self async_subpathsOfDirectoryAtPath:path]);
        if (error) {
            if (co_getError()) {
                *error = co_getError();
            }
            else{
                *error = nil;
            }
        }
        return list;
    }
    else{
        return [self subpathsOfDirectoryAtPath:path error:error];
    }
}

- (NSDictionary<NSFileAttributeKey,id> *)co_attributesOfItemAtPath:(NSString *)path error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        NSDictionary *attr = await([self async_attributesOfItemAtPath:path]);
        if (error) {
            if (co_getError()) {
                *error = co_getError();
            }
            else{
                *error = nil;
            }
        }
        return attr;
    }
    else{
        return [self attributesOfItemAtPath:path error:error];
    }
}

- (NSDictionary<NSFileAttributeKey,id> *)co_attributesOfFileSystemForPath:(NSString *)path error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        NSDictionary *attr = await([self async_attributesOfFileSystemForPath:path]);
        if (error) {
            if (co_getError()) {
                *error = co_getError();
            }
            else{
                *error = nil;
            }
        }
        return attr;
    }
    else{
        return [self attributesOfFileSystemForPath:path error:error];
    }
}

- (BOOL)co_createSymbolicLinkAtPath:(NSString *)path withDestinationPath:(NSString *)destPath error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_createSymbolicLinkAtPath:path withDestinationPath:destPath]) boolValue];
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
        return [self createSymbolicLinkAtPath:path withDestinationPath:destPath error:error];
    }
}

- (NSString *)co_destinationOfSymbolicLinkAtPath:(NSString *)path error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        NSString *dest = await([self async_destinationOfSymbolicLinkAtPath:path]);
        if (error) {
            if (co_getError()) {
                *error = co_getError();
            }
            else{
                *error = nil;
            }
        }
        return dest;
    }
    else{
        return [self destinationOfSymbolicLinkAtPath:path error:error];
    }
}

- (BOOL)co_copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError**)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_copyItemAtPath:srcPath toPath:dstPath]) boolValue];
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
        return [self copyItemAtPath:srcPath toPath:dstPath error:error];
    }
}

- (BOOL)co_moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_moveItemAtPath:srcPath toPath:dstPath]) boolValue];
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
        return [self moveItemAtPath:srcPath toPath:dstPath error:error];
    }
}

- (BOOL)co_linkItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_linkItemAtPath:srcPath toPath:dstPath]) boolValue];
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
        return [self linkItemAtPath:srcPath toPath:dstPath error:error];
    }
}

- (BOOL)co_removeItemAtPath:(NSString *)path error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_removeItemAtPath:path]) boolValue];
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
        return [self removeItemAtPath:path error:error];
    }
}

- (BOOL)co_copyItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_copyItemAtURL:srcURL toURL:dstURL]) boolValue];
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
        return [self copyItemAtURL:srcURL toURL:dstURL error:error];
    }
}

- (BOOL)co_moveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_moveItemAtURL:srcURL toURL:dstURL]) boolValue];
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
        return [self moveItemAtURL:srcURL toURL:dstURL error:error];
    }
}

- (BOOL)co_linkItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_linkItemAtURL:srcURL toURL:dstURL]) boolValue];
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
        return [self linkItemAtURL:srcURL toURL:dstURL error:error];
    }
}

- (BOOL)co_removeItemAtURL:(NSURL *)URL error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_removeItemAtURL:URL]) boolValue];
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
        return [self removeItemAtURL:URL error:error];
    }
}

- (BOOL)co_trashItemAtURL:(NSURL *)url resultingItemURL:(NSURL *__autoreleasing  _Nullable *)outResultingURL error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_trashItemAtURL:url resultingItemURL:outResultingURL]) boolValue];
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
        return [self trashItemAtURL:url resultingItemURL:outResultingURL error:error];
    }
}

- (BOOL)co_fileExistsAtPath:(NSString *)path isDirectory:(BOOL * _Nullable)isDirectory{
    if ([COCoroutine currentCoroutine]) {
        id ret, isDir;
        co_unpack(&ret, &isDir) = await([self async_fileExistsAtPath:path]);
        if (isDirectory) {
            *isDirectory = [isDir boolValue];
        }
        return [ret boolValue];
    }
    else{
        return [self fileExistsAtPath:path isDirectory:isDirectory];
    }
}

- (BOOL)co_isReadableFileAtPath:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        return [await([self async_isReadableFileAtPath:path]) boolValue];
    }
    else{
        return [self isReadableFileAtPath:path];
    }
}

- (BOOL)co_isWritableFileAtPath:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        return [await([self async_isWritableFileAtPath:path]) boolValue];
    }
    else{
        return [self isWritableFileAtPath:path];
    }
}

- (BOOL)co_isDeletableFileAtPath:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        return [await([self async_isDeletableFileAtPath:path]) boolValue];
    }
    else{
        return [self isDeletableFileAtPath:path];
    }
}

- (BOOL)co_isExecutableFileAtPath:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        return [await([self async_isExecutableFileAtPath:path]) boolValue];
    }
    else{
        return [self isExecutableFileAtPath:path];
    }
}

- (BOOL)co_contentsEqualAtPath:(NSString *)path1 andPath:(NSString *)path2{
    if ([COCoroutine currentCoroutine]) {
        return [await([self async_contentsEqualAtPath:path1 andPath:path2]) boolValue];
    }
    else{
        return [self contentsEqualAtPath:path1 andPath:path2];
    }
}

- (NSArray<NSString *> *)co_subpathsAtPath:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_subpathsAtPath:path]);
    }
    else{
        return [self subpathsAtPath:path];
    }
}

- (NSData *)co_contentsAtPath:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_contentsAtPath:path]);
    }
    else{
        return [self contentsAtPath:path];
    }
}

- (BOOL)co_createFileAtPath:(NSString *)path contents:(NSData *)data attributes:(NSDictionary<NSFileAttributeKey,id> *)attr{
    if([COCoroutine currentCoroutine]){
        return [await([self async_createFileAtPath:path contents:data attributes:attr]) boolValue];
    }
    else{
        return [self createFileAtPath:path contents:data attributes:attr];
    }
}

- (BOOL)co_replaceItemAtURL:(NSURL *)originalItemURL withItemAtURL:(NSURL *)newItemURL backupItemName:(NSString *)backupItemName options:(NSFileManagerItemReplacementOptions)options resultingItemURL:(NSURL *__autoreleasing  _Nullable *)resultingURL error:(NSError * _Nullable __autoreleasing *)error{
    if ([COCoroutine currentCoroutine]) {
        BOOL ret = [await([self async_replaceItemAtURL:originalItemURL withItemAtURL:newItemURL backupItemName:backupItemName options:options resultingItemURL:resultingURL]) boolValue];
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
        return [self replaceItemAtURL:originalItemURL withItemAtURL:newItemURL backupItemName:backupItemName options:options resultingItemURL:resultingURL error:error];
    }
}

@end

@implementation NSFileManager (COPromise)

- (COPromise<NSNumber *> *)async_createDirectoryAtURL:(NSURL *)url withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary<NSFileAttributeKey,id> *)attributes{
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlockOnBackgroundThread:^{
        NSError *error = nil;
        BOOL ret = [self createDirectoryAtURL:url withIntermediateDirectories:createIntermediates attributes:attributes error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    } backgroundQueue:[COKitCommon filemanager_queue]];
    return promise;
}

- (COPromise<NSNumber *> *)async_createSymbolicLinkAtURL:(NSURL *)url withDestinationURL:(NSURL *)destURL{
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlockOnBackgroundThread:^{
        NSError *error = nil;
        BOOL ret = [self createSymbolicLinkAtURL:url withDestinationURL:destURL error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    } backgroundQueue:[COKitCommon filemanager_queue]];
    return promise;
}

- (COPromise<NSNumber *> *)async_setAttributes:(NSDictionary<NSFileAttributeKey,id> *)attributes ofItemAtPath:(NSString *)path{
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlockOnBackgroundThread:^{
        NSError *error = nil;
        BOOL ret = [self setAttributes:attributes ofItemAtPath:path error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    } backgroundQueue:[COKitCommon filemanager_queue]];
    return promise;
}

- (COPromise<NSNumber *> *)async_createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary<NSFileAttributeKey,id> *)attributes{
    
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlockOnBackgroundThread:^{
        NSError *error = nil;
        BOOL ret = [self createDirectoryAtPath:path withIntermediateDirectories:createIntermediates attributes:attributes error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    } backgroundQueue:[COKitCommon filemanager_queue]];
    return promise;
}

- (COPromise<NSArray<NSString *> *> *)async_contentsOfDirectoryAtPath:(NSString *)path{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            NSArray *list = [self contentsOfDirectoryAtPath:path error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(list);
            }
        } backgroundQueue:[COKitCommon filemanager_queue]];
    }];
}

- (COPromise<NSArray<NSString *> *> *)async_subpathsOfDirectoryAtPath:(NSString *)path{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            NSArray *list = [self subpathsOfDirectoryAtPath:path error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(list);
            }
        } backgroundQueue:[COKitCommon filemanager_queue]];
    }];
}

- (COPromise<NSDictionary<NSFileAttributeKey,id> *> *)async_attributesOfItemAtPath:(NSString *)path{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            NSDictionary *dict = [self attributesOfItemAtPath:path error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(dict);
            }
        } backgroundQueue:[COKitCommon filemanager_queue]];
    }];
}

- (COPromise<NSDictionary<NSFileAttributeKey,id> *> *)async_attributesOfFileSystemForPath:(NSString *)path{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            NSDictionary *dict = [self attributesOfFileSystemForPath:path error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(dict);
            }
        } backgroundQueue:[COKitCommon filemanager_queue]];
    }];
}

- (COPromise<NSNumber *> *)async_createSymbolicLinkAtPath:(NSString *)path withDestinationPath:(NSString *)destPath{
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlockOnBackgroundThread:^{
        NSError *error = nil;
        BOOL ret = [self createSymbolicLinkAtPath:path withDestinationPath:destPath error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    } backgroundQueue:[COKitCommon filemanager_queue]];
    return promise;
}

- (COPromise<NSString *> *)async_destinationOfSymbolicLinkAtPath:(NSString *)path{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSError *error = nil;
            NSString* destPath = [self destinationOfSymbolicLinkAtPath:path error:&error];
            if (error) {
                reject(error);
            }
            else{
                resolve(destPath);
            }
        } backgroundQueue:[COKitCommon filemanager_queue]];
    }];
}

- (COPromise<NSNumber *> *)async_copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath{
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlockOnBackgroundThread:^{
        NSError *error = nil;
        BOOL ret = [self copyItemAtPath:srcPath toPath:dstPath error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    } backgroundQueue:[COKitCommon filemanager_queue]];
    return promise;
}

- (COPromise<NSNumber *> *)async_moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath{
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlockOnBackgroundThread:^{
        NSError *error = nil;
        BOOL ret = [self moveItemAtPath:srcPath toPath:dstPath error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    } backgroundQueue:[COKitCommon filemanager_queue]];
    return promise;
}

- (COPromise<NSNumber *> *)async_linkItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath{
    
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlockOnBackgroundThread:^{
        NSError *error = nil;
        BOOL ret = [self linkItemAtPath:srcPath toPath:dstPath error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    } backgroundQueue:[COKitCommon filemanager_queue]];
    return promise;
}

- (COPromise<NSNumber *> *)async_removeItemAtPath:(NSString *)path{
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlockOnBackgroundThread:^{
        NSError *error = nil;
        BOOL ret = [self removeItemAtPath:path error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    } backgroundQueue:[COKitCommon filemanager_queue]];
    return promise;
}

- (COPromise<NSNumber *> *)async_copyItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL{
    
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlockOnBackgroundThread:^{
        NSError *error = nil;
        BOOL ret = [self copyItemAtURL:srcURL toURL:dstURL error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    } backgroundQueue:[COKitCommon filemanager_queue]];
    return promise;
}

- (COPromise<NSNumber *> *)async_moveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL{
    
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlockOnBackgroundThread:^{
        NSError *error = nil;
        BOOL ret = [self moveItemAtURL:srcURL toURL:dstURL error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    } backgroundQueue:[COKitCommon filemanager_queue]];
    return promise;
}

- (COPromise<NSNumber *> *)async_linkItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL{
    
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlockOnBackgroundThread:^{
        NSError *error = nil;
        BOOL ret = [self linkItemAtURL:srcURL toURL:dstURL error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    } backgroundQueue:[COKitCommon filemanager_queue]];
    return promise;
}

- (COPromise<NSNumber *> *)async_removeItemAtURL:(NSURL *)URL{
    
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlockOnBackgroundThread:^{
        NSError *error = nil;
        BOOL ret = [self removeItemAtURL:URL error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    } backgroundQueue:[COKitCommon filemanager_queue]];
    return promise;
}

- (COPromise<NSNumber *> *)async_trashItemAtURL:(NSURL *)url resultingItemURL:(NSURL *__autoreleasing  _Nullable *)outResultingURL{
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlockOnBackgroundThread:^{
        NSError *error = nil;
        BOOL ret = [self trashItemAtURL:url resultingItemURL:outResultingURL error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    } backgroundQueue:[COKitCommon filemanager_queue]];
    return promise;
}

- (COPromise<COTuple2<NSNumber *,NSNumber *> *> *)async_fileExistsAtPath:(NSString *)path{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            BOOL isDirectory = NO;
            BOOL ret = [self fileExistsAtPath:path isDirectory:&isDirectory];
            resolve(co_tuple(@(ret), @(isDirectory)));
        } backgroundQueue:[COKitCommon filemanager_queue]];
    }];
}

- (COPromise<NSNumber *> *)async_isReadableFileAtPath:(NSString *)path{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            BOOL ret = [self isReadableFileAtPath:path];
            resolve(@(ret));
        } backgroundQueue:[COKitCommon filemanager_queue]];
    }];
}

- (COPromise<NSNumber *> *)async_isWritableFileAtPath:(NSString *)path{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            BOOL ret = [self isWritableFileAtPath:path];
            resolve(@(ret));
        } backgroundQueue:[COKitCommon filemanager_queue]];
    }];
}

- (COPromise<NSNumber *> *)async_isExecutableFileAtPath:(NSString *)path{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            BOOL ret = [self isExecutableFileAtPath:path];
            resolve(@(ret));
        } backgroundQueue:[COKitCommon filemanager_queue]];
    }];
}

- (COPromise<NSNumber *> *)async_isDeletableFileAtPath:(NSString *)path{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            BOOL ret = [self isDeletableFileAtPath:path];
            resolve(@(ret));
        } backgroundQueue:[COKitCommon filemanager_queue]];
    }];
}

- (COPromise<NSNumber *> *)async_contentsEqualAtPath:(NSString *)path1 andPath:(NSString *)path2{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            BOOL ret = [self contentsEqualAtPath:path1 andPath:path2];
            resolve(@(ret));
        } backgroundQueue:[COKitCommon filemanager_queue]];
    }];
}

- (COPromise<NSArray<NSString *> *> *)async_subpathsAtPath:(NSString *)path{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSArray *list = [self subpathsAtPath:path];
            resolve(list);
        } backgroundQueue:[COKitCommon filemanager_queue]];
    }];
}

- (COPromise<NSData *> *)async_contentsAtPath:(NSString *)path{
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlockOnBackgroundThread:^{
            NSData* data = [self contentsAtPath:path];
            resolve(data);
        } backgroundQueue:[COKitCommon filemanager_queue]];
    }];
}

- (COPromise<NSNumber *> *)async_createFileAtPath:(NSString *)path contents:(NSData *)data attributes:(NSDictionary<NSFileAttributeKey,id> *)attr{
    
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlockOnBackgroundThread:^{
        BOOL ret = [self createFileAtPath:path contents:data attributes:attr];
        [promise fulfill:@(ret)];
    } backgroundQueue:[COKitCommon filemanager_queue]];
    return promise;
}

- (COPromise<NSNumber *> *)async_replaceItemAtURL:(NSURL *)originalItemURL withItemAtURL:(NSURL *)newItemURL backupItemName:(NSString *)backupItemName options:(NSFileManagerItemReplacementOptions)options resultingItemURL:(NSURL *__autoreleasing  _Nullable *)resultingURL{
    
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlockOnBackgroundThread:^{
        NSError *error = nil;
        BOOL ret = [self replaceItemAtURL:originalItemURL withItemAtURL:newItemURL backupItemName:backupItemName options:options resultingItemURL:resultingURL error:&error];
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:@(ret)];
        }
    } backgroundQueue:[COKitCommon filemanager_queue]];
    return promise;
}

@end
