//
//  NSKeyedArchiver+Coroutine.h
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

#import <Foundation/Foundation.h>
#import <coobjc/COPromise.h>
#import <coobjc/coobjc.h>

NS_ASSUME_NONNULL_BEGIN


@interface NSKeyedArchiver (COPromise)

+ (COPromise<NSData*>*)async_archivedDataWithRootObject:(id)rootObject;
+ (COPromise<NSNumber*>*)async_archiveRootObject:(id)rootObject toFile:(NSString *)path;

@end

@interface NSKeyedArchiver (Coroutine)

+ (NSData*)co_archivedDataWithRootObject:(id)rootObject CO_ASYNC;
+ (BOOL)co_archiveRootObject:(id)rootObject toFile:(NSString *)path CO_ASYNC;

@end

@interface NSKeyedUnarchiver (COPromise)

+ (COPromise<id>*)async_unarchiveObjectWithData:(NSData *)data;
+ (COPromise<id>*)async_unarchiveTopLevelObjectWithData:(NSData *)data API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0)) NS_SWIFT_UNAVAILABLE("Use 'unarchiveTopLevelObjectWithData(_:) throws' instead");
+ (COPromise<id>*)async_unarchiveObjectWithFile:(NSString *)path;

@end

@interface NSKeyedUnarchiver (Coroutine)

+ (id)co_unarchiveObjectWithData:(NSData *)data CO_ASYNC;
+ (id)co_unarchiveTopLevelObjectWithData:(NSData *)data error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.11), ios(9.0), watchos(2.0), tvos(9.0)) NS_SWIFT_UNAVAILABLE("Use 'unarchiveTopLevelObjectWithData(_:) throws' instead");
+ (id)co_unarchiveObjectWithFile:(NSString *)path CO_ASYNC;

@end

NS_ASSUME_NONNULL_END
