//
//  NSDictionary+Coroutine.h
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


@interface NSDictionary<KeyType, ObjectType> (COPromise)

/* Serializes this instance to the specified URL in the NSPropertyList format (using NSPropertyListXMLFormat_v1_0). For other formats use NSPropertyListSerialization directly. */

/*
The Async Interface that return COPromise, usage:
api return  promise can use with co_launch and await, like this:
co_launch(^{
    BOOL ret = [await([dict async_writeToURL:url]) boolValue];
    if(!ret){
        NSLog(@"write to url error, %@", co_getError());
}
});
*/
- (COPromise<NSNumber*>*)async_writeToURL:(NSURL *)url API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0));

- (COPromise<NSNumber*>*)async_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
- (COPromise<NSNumber*>*)async_writeToURL:(NSURL *)url atomically:(BOOL)atomically; // the atomically flag is ignored if url of a type that cannot be written atomically.

/*
 The Async Interface that return COPromise, usage:
 api return  promise can use with co_launch and await, like this:
 co_launch(^{
    NSDictionary* dict = await([NSDictionary async_dictionaryWithContentsOfFile:path]);
    NSDictionary* dict1 = await([NSDictionary async_dictionaryWithContentsOfURL:url]);
    NSDictionary* dict2 = await([[NSDictionary alloc] async_initWithContentsOfFile:path]);
    NSDictionary* dict3 = await([[NSDictionary alloc] async_initWithContentsOfURL:url]);
 });
 */
+ (COPromise<NSDictionary<KeyType, ObjectType>*> *)async_dictionaryWithContentsOfFile:(NSString *)path;
+ (COPromise<NSDictionary<KeyType, ObjectType>*> *)async_dictionaryWithContentsOfURL:(NSURL *)url;
- (COPromise<NSDictionary<KeyType, ObjectType>*> *)async_initWithContentsOfFile:(NSString *)path;
- (COPromise<NSDictionary<KeyType, ObjectType>*> *)async_initWithContentsOfURL:(NSURL *)url;


@end

@interface NSDictionary<KeyType, ObjectType> (Coroutine)


/*
 The coroutine wrap Interface that return value, usage:
 co_launch(^{
     NSError *error = nil;
     BOOL ret = [dict co_writeToURL:url error:&error];
     if(!ret){
        NSLog(@"write error: %@", error);
     }
 });
 */

/* Serializes this instance to the specified URL in the NSPropertyList format (using NSPropertyListXMLFormat_v1_0). For other formats use NSPropertyListSerialization directly. */

- (BOOL)co_writeToURL:(NSURL *)url error:(NSError**)error CO_ASYNC API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0));

- (BOOL)co_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile CO_ASYNC;
- (BOOL)co_writeToURL:(NSURL *)url atomically:(BOOL)atomically CO_ASYNC; // the atomically flag is ignored if url of a type that cannot be written atomically.


/*
 The coroutine wrap Interface that return value, usage:
 co_launch(^{
     NSDictionary *dict = [NSDictionary co_dictionaryWithContentsOfFile:path];
     NSLog(@"dict: %@", dict);
 });
 */
+ (NSDictionary<KeyType, ObjectType> *)co_dictionaryWithContentsOfFile:(NSString *)path CO_ASYNC;
+ (NSDictionary<KeyType, ObjectType> *)co_dictionaryWithContentsOfURL:(NSURL *)url CO_ASYNC;
- (NSDictionary<KeyType, ObjectType> *)co_initWithContentsOfFile:(NSString *)path CO_ASYNC;
- (NSDictionary<KeyType, ObjectType> *)co_initWithContentsOfURL:(NSURL *)url CO_ASYNC;



@end

@interface NSMutableDictionary<KeyType, ObjectType> (COPromise)

+ (COPromise<NSMutableDictionary<KeyType, ObjectType>*> *)async_dictionaryWithContentsOfFile:(NSString *)path;
+ (COPromise<NSMutableDictionary<KeyType, ObjectType>*> *)async_dictionaryWithContentsOfURL:(NSURL *)url;
- (COPromise<NSMutableDictionary<KeyType, ObjectType>*> *)async_initWithContentsOfFile:(NSString *)path;
- (COPromise<NSMutableDictionary<KeyType, ObjectType>*> *)async_initWithContentsOfURL:(NSURL *)url;

@end

@interface NSMutableDictionary<KeyType, ObjectType> (Coroutine)

+ (NSMutableDictionary<KeyType, ObjectType> *)co_dictionaryWithContentsOfFile:(NSString *)path CO_ASYNC;
+ (NSMutableDictionary<KeyType, ObjectType> *)co_dictionaryWithContentsOfURL:(NSURL *)url CO_ASYNC;
- (NSMutableDictionary<KeyType, ObjectType> *)co_initWithContentsOfFile:(NSString *)path CO_ASYNC;
- (NSMutableDictionary<KeyType, ObjectType> *)co_initWithContentsOfURL:(NSURL *)url CO_ASYNC;

@end

NS_ASSUME_NONNULL_END
