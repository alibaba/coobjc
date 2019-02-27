//
//  NSArray+Coroutine.h
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


@interface NSArray<ObjectType> (COPromise)


/* Reads array stored in NSPropertyList format from the specified url.
    The Async Interface that return COPromise, usage:
    api return  promise can use with co_launch and await, like this:
    co_launch(^{
        NSArray *array = await([[NSArray alloc] async_initWithContentsOfURL:url]);
        NSError *error = co_getError();
        if(error){
            NSLog(@"load from url error");
        }
    });
*/
- (nullable COPromise<NSArray<ObjectType>*> *)async_initWithContentsOfURL:(NSURL *)url;

/* Reads array stored in NSPropertyList format from the specified url.
 The Async Interface that return COPromise, usage:
 api return  promise can use with co_launch and await, like this:
 co_launch(^{
     NSArray *array = await([NSArray async_arrayWithContentsOfURL:url]);
     NSError *error = co_getError();
     if(error){
        NSLog(@"load from url error");
     }
 });
 */
+ (nullable COPromise<NSArray<ObjectType>*> *)async_arrayWithContentsOfURL:(NSURL *)url;

/*
     The Async Interface that return COPromise, usage:
     api return  promise can use with co_launch and await, like this:
     co_launch(^{
         NSArray *array = await([NSArray  async_arrayWithContentsOfFile:filePath]);
        NSLog(@"%@", array);
     });
 */
+ (nullable COPromise<NSArray<ObjectType>*> *)async_arrayWithContentsOfFile:(NSString *)path;

/*
     The Async Interface that return COPromise, usage:
     api return  promise can use with co_launch and await, like this:
     co_launch(^{
         NSArray *array = await([[NSArray alloc]  async_initWithContentsOfFile:filePath]);
         NSLog(@"%@", array);
     });
 */
- (nullable COPromise<NSArray<ObjectType>*> *)async_initWithContentsOfFile:(NSString *)path;

/* Serializes this instance to the specified URL in the NSPropertyList format (using NSPropertyListXMLFormat_v1_0). For other formats use NSPropertyListSerialization directly. */
/*
 The Async Interface that return COPromise, usage:
     api return  promise can use with co_launch and await, like this:
     co_launch(^{
         BOOL ret = await([array async_writeToURL:url] boolValue);
         if(!ret){
            NSError *error = co_getError();
            if(error){
                NSLog("%@", error);
            }
         }
     });
 */
- (COPromise<NSNumber*>*)async_writeToURL:(NSURL *)url API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0));


/*
 The Async Interface that return COPromise, usage:
 api return  promise can use with co_launch and await, like this:
 co_launch(^{
     BOOL ret = await([array async_writeToFile:path atomically:YES] boolValue);
     if(!ret){
        NSLog(@"write error");
     }
 });
 */
- (COPromise<NSNumber*>*)async_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;

/*
 The Async Interface that return COPromise, usage:
 api return  promise can use with co_launch and await, like this:
 co_launch(^{
    BOOL ret = await([array async_writeToURL:url atomically:YES] boolValue);
    if(!ret){
        NSLog(@"write error");
    }
 });
 */
- (COPromise<NSNumber*>*)async_writeToURL:(NSURL *)url atomically:(BOOL)atomically;

@end



@interface NSArray<ObjectType> (Coroutine)

/* Reads array stored in NSPropertyList format from the specified url. */
- (nullable NSArray<ObjectType> *)co_initWithContentsOfURL:(NSURL *)url error:(NSError **)error CO_ASYNC;
- (nullable NSArray<ObjectType> *)co_initWithContentsOfURL:(NSURL *)url CO_ASYNC;

/* Reads array stored in NSPropertyList format from the specified url. */
/* The coroutine wrap Interface that return value, usage:
 co_launch(^{
     NSError *error = nil;
     NSArray *array = [NSArray co_arrayWithContentsOfURL:url error:&error];
     if(error){
        NSLog(@"load from url error");
     }
 });
 in the internal of co interface, it will await the async interface for you
 */
+ (nullable NSArray<ObjectType> *)co_arrayWithContentsOfURL:(NSURL *)url error:(NSError **)error CO_ASYNC;

/* The coroutine wrap Interface that return value, usage:
 co_launch(^{
    NSArray *array = [NSArray co_arrayWithContentsOfURL:url];
    NSLog(@"list: %@", array);
 });
 in the internal of co interface, it will await the async interface for you
 */
+ (nullable NSArray<ObjectType> *)co_arrayWithContentsOfURL:(NSURL *)url CO_ASYNC;

/* The coroutine wrap Interface that return value, usage:
 co_launch(^{
     NSArray *array = [NSArray co_arrayWithContentsOfFile:path];
     NSLog(@"list: %@", array);
 });
 in the internal of co interface, it will await the async interface for you
 */
+ (nullable NSArray<ObjectType> *)co_arrayWithContentsOfFile:(NSString *)path CO_ASYNC;
/* The coroutine wrap Interface that return value, usage:
 co_launch(^{
     NSArray *array = [[NSArray alloc] co_initWithContentsOfFile:path];
     NSLog(@"list: %@", array);
 });
 in the internal of co interface, it will await the async interface for you
 */
- (nullable NSArray<ObjectType> *)co_initWithContentsOfFile:(NSString *)path CO_ASYNC;

/* Serializes this instance to the specified URL in the NSPropertyList format (using NSPropertyListXMLFormat_v1_0). For other formats use NSPropertyListSerialization directly. */
/* The coroutine wrap Interface that return value, usage:
 co_launch(^{
    NSError *error = nil;
    BOOL ret = [array co_writeToURL:url error:&error];
    if(error){NSLog(@"error: %@", error);}
 });
 in the internal of co interface, it will await the async interface for you
 */
- (BOOL)co_writeToURL:(NSURL *)url error:(NSError **)error CO_ASYNC API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0));

/* The coroutine wrap Interface that return value, usage:
 co_launch(^{
     BOOL ret = [array co_writeToFile:path atomically:NO];
     if(!ret){NSLog(@"write error");}
 });
 in the internal of co interface, it will await the async interface for you
 */
- (BOOL)co_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile CO_ASYNC;
/* The coroutine wrap Interface that return value, usage:
 co_launch(^{
     BOOL ret = [array co_writeToURL:url atomically:NO];
     if(!ret){NSLog(@"write error");}
 });
 in the internal of co interface, it will await the async interface for you
 */
- (BOOL)co_writeToURL:(NSURL *)url atomically:(BOOL)atomically CO_ASYNC;

@end

@interface NSMutableArray<ObjectType> (COPromise)

+ (nullable COPromise<NSMutableArray<ObjectType>*> *)async_arrayWithContentsOfFile:(NSString *)path;
+ (nullable COPromise<NSMutableArray<ObjectType>*> *)async_arrayWithContentsOfURL:(NSURL *)url;
- (nullable COPromise<NSMutableArray<ObjectType>*> *)async_initWithContentsOfFile:(NSString *)path;
- (nullable COPromise<NSMutableArray<ObjectType>*> *)async_initWithContentsOfURL:(NSURL *)url;

@end

@interface NSMutableArray<ObjectType> (Coroutine)

+ (nullable NSMutableArray<ObjectType> *)co_arrayWithContentsOfFile:(NSString *)path CO_ASYNC;
+ (nullable NSMutableArray<ObjectType> *)co_arrayWithContentsOfURL:(NSURL *)url CO_ASYNC;
- (nullable NSMutableArray<ObjectType> *)co_initWithContentsOfFile:(NSString *)path CO_ASYNC;
- (nullable NSMutableArray<ObjectType> *)co_initWithContentsOfURL:(NSURL *)url CO_ASYNC;

@end

NS_ASSUME_NONNULL_END

