//
//  NSPropertyList+Coroutine.h
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


@interface NSPropertyListSerialization (COPromise)

/* Verify that a specified property list is valid for a given format. Returns YES if the property list is valid.
 */
+ (COPromise<NSNumber*>*)async_propertyList:(id)plist isValidForFormat:(NSPropertyListFormat)format;

/* Create an NSData from a property list. The format can be either NSPropertyListXMLFormat_v1_0 or NSPropertyListBinaryFormat_v1_0. The options parameter is currently unused and should be set to 0. If an error occurs the return value will be nil and the error parameter (if non-NULL) set to an autoreleased NSError describing the problem.
 */
+ (COPromise<NSData*> *)async_dataWithPropertyList:(id)plist format:(NSPropertyListFormat)format options:(NSPropertyListWriteOptions)opt API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

/* Write a property list to an output stream. The stream should be opened and configured. The format can be either NSPropertyListXMLFormat_v1_0 or NSPropertyListBinaryFormat_v1_0. The options parameter is currently unused and should be set to 0. If an error occurs the return value will be 0 and the error parameter (if non-NULL) set to an autoreleased NSError describing the problem. In a successful case, the return value is the number of bytes written to the stream.
 */
+ (COPromise<NSNumber*>*)async_writePropertyList:(id)plist toStream:(NSOutputStream *)stream format:(NSPropertyListFormat)format options:(NSPropertyListWriteOptions)opt API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

/* Create a property list from an NSData. The options can be any of NSPropertyListMutabilityOptions. If the format parameter is non-NULL, it will be filled out with the format that the property list was stored in. If an error occurs the return value will be nil and the error parameter (if non-NULL) set to an autoreleased NSError describing the problem.
 */
+ (COPromise<id>*)async_propertyListWithData:(NSData *)data options:(NSPropertyListReadOptions)opt format:(nullable NSPropertyListFormat *)format API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

/* Create a property list by reading from an NSInputStream. The options can be any of NSPropertyListMutabilityOptions. If the format parameter is non-NULL, it will be filled out with the format that the property list was stored in. If an error occurs the return value will be nil and the error parameter (if non-NULL) set to an autoreleased NSError describing the problem.
 */
+ (COPromise<id>*)async_propertyListWithStream:(NSInputStream *)stream options:(NSPropertyListReadOptions)opt format:(nullable NSPropertyListFormat *)format API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));



@end

@interface NSPropertyListSerialization (Coroutine)

/* Verify that a specified property list is valid for a given format. Returns YES if the property list is valid.
 */
+ (BOOL)co_propertyList:(id)plist isValidForFormat:(NSPropertyListFormat)format CO_ASYNC;

/* Create an NSData from a property list. The format can be either NSPropertyListXMLFormat_v1_0 or NSPropertyListBinaryFormat_v1_0. The options parameter is currently unused and should be set to 0. If an error occurs the return value will be nil and the error parameter (if non-NULL) set to an autoreleased NSError describing the problem.
 */
+ (NSData *)co_dataWithPropertyList:(id)plist format:(NSPropertyListFormat)format options:(NSPropertyListWriteOptions)opt error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

/* Write a property list to an output stream. The stream should be opened and configured. The format can be either NSPropertyListXMLFormat_v1_0 or NSPropertyListBinaryFormat_v1_0. The options parameter is currently unused and should be set to 0. If an error occurs the return value will be 0 and the error parameter (if non-NULL) set to an autoreleased NSError describing the problem. In a successful case, the return value is the number of bytes written to the stream.
 */
+ (BOOL)co_writePropertyList:(id)plist toStream:(NSOutputStream *)stream format:(NSPropertyListFormat)format options:(NSPropertyListWriteOptions)opt error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

/* Create a property list from an NSData. The options can be any of NSPropertyListMutabilityOptions. If the format parameter is non-NULL, it will be filled out with the format that the property list was stored in. If an error occurs the return value will be nil and the error parameter (if non-NULL) set to an autoreleased NSError describing the problem.
 */
+ (id)co_propertyListWithData:(NSData *)data options:(NSPropertyListReadOptions)opt format:(nullable NSPropertyListFormat *)format error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));

/* Create a property list by reading from an NSInputStream. The options can be any of NSPropertyListMutabilityOptions. If the format parameter is non-NULL, it will be filled out with the format that the property list was stored in. If an error occurs the return value will be nil and the error parameter (if non-NULL) set to an autoreleased NSError describing the problem.
 */
+ (id)co_propertyListWithStream:(NSInputStream *)stream options:(NSPropertyListReadOptions)opt format:(nullable NSPropertyListFormat *)format error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));



@end

NS_ASSUME_NONNULL_END
