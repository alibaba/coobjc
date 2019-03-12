//
//  NSData+Coroutine.h
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
#import <coobjc/coobjc.h>

@interface NSData (COPromise)

/*
 The Async Interface that return COPromise, usage:
 api return  promise can use with co_launch and await, like this:
 co_launch(^{
     BOOL ret = [await([data async_writeToFile:path atomically:YES]) boolValue];
     if(!ret){
        NSLog(@"write to file error");
 }
 });
 */
- (COPromise<NSNumber*>*)async_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
/*
 The Async Interface that return COPromise, usage:
 api return  promise can use with co_launch and await, like this:
 co_launch(^{
     BOOL ret = [await([data async_writeToURL:url atomically:YES]) boolValue];
     if(!ret){
        NSLog(@"write to url error");
 }
 });
 */
- (COPromise<NSNumber*>*)async_writeToURL:(NSURL *)url atomically:(BOOL)atomically; // the atomically flag is ignored if the url is not of a type the supports atomic writes

/*
 The Async Interface that return COPromise, usage:
 api return  promise can use with co_launch and await, like this:
 co_launch(^{
     BOOL ret = [await([data async_writeToFile:path options:0]) boolValue];
     if(!ret){
        NSLog(@"write to file error %@", co_getError());
 }
 });
 */
- (COPromise<NSNumber*>*)async_writeToFile:(NSString *)path options:(NSDataWritingOptions)writeOptionsMask;
/*
 The Async Interface that return COPromise, usage:
 api return  promise can use with co_launch and await, like this:
 co_launch(^{
     BOOL ret = [await([data async_writeToURL:url options:0]) boolValue];
     if(!ret){
        NSLog(@"write to url error %@", co_getError());
     }
 });
 */
- (COPromise<NSNumber*>*)async_writeToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask;


/*
 The Async Interface that return COPromise, usage:
 api return  promise can use with co_launch and await, like this:
 co_launch(^{
     NSData* data = await([NSData async_dataWithContentsOfFile:path options:0]);
    if(!data && co_getError()){
        NSLog(@"load error %@", co_getError());
    }
 });
 */
+ (COPromise<NSData*>*)async_dataWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask;
/*
 The Async Interface that return COPromise, usage:
 api return  promise can use with co_launch and await, like this:
 co_launch(^{
     NSData* data = await([NSData async_dataWithContentsOfURL:url options:0]);
     if(!data && co_getError()){
        NSLog(@"load error %@", co_getError());
     }
 });
 */
+ (COPromise<NSData*>*)async_dataWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask;

/*
 The Async Interface that return COPromise, usage:
 api return  promise can use with co_launch and await, like this:
 co_launch(^{
     NSData* data = await([NSData async_dataWithContentsOfFile:path]);
     if(!data){
     NSLog(@"load error");
 }
 });
 */
+ (COPromise<NSData*>*)async_dataWithContentsOfFile:(NSString *)path;
/*
 The Async Interface that return COPromise, usage:
 api return  promise can use with co_launch and await, like this:
 co_launch(^{
     NSData* data = await([NSData async_dataWithContentsOfURL:url]);
     if(!data){
        NSLog(@"load error");
     }
 });
 */
+ (COPromise<NSData*>*)async_dataWithContentsOfURL:(NSURL *)url;

/*
 The Async Interface that return COPromise, usage:
 api return  promise can use with co_launch and await, like this:
 co_launch(^{
     NSData* data = await([[NSData alloc] async_initWithContentsOfFile:path options:0]);
     if(!data){
        NSLog(@"load error: %@", co_getError());
     }
 });
 */
- (COPromise<NSData*>*)async_initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask;
/*
 The Async Interface that return COPromise, usage:
 api return  promise can use with co_launch and await, like this:
 co_launch(^{
     NSData* data = await([[NSData alloc] async_initWithContentsOfURL:url options:0]);
     if(!data){
        NSLog(@"load error: %@", co_getError());
     }
 });
 */
- (COPromise<NSData*>*)async_initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask;
/*
 The Async Interface that return COPromise, usage:
 api return  promise can use with co_launch and await, like this:
 co_launch(^{
     NSData* data = await([[NSData alloc] async_initWithContentsOfFile:path]);
     if(!data){
        NSLog(@"load error");
     }
 });
 */
- (COPromise<NSData*>*)async_initWithContentsOfFile:(NSString *)path;

/*
 The Async Interface that return COPromise, usage:
 api return  promise can use with co_launch and await, like this:
 co_launch(^{
     NSData* data = await([[NSData alloc] async_initWithContentsOfURL:url]);
     if(!data){
        NSLog(@"load error");
     }
 });
 */
- (COPromise<NSData*>*)async_initWithContentsOfURL:(NSURL *)url;


@end

@interface NSData (Coroutine)

/*
 The coroutine wrap Interface that return value, usage:
 co_launch(^{
     BOOL ret = [data co_writeToFile:path atomically:YES];
     if(!ret){
        NSLog(@"write to file error");
     }
 });
 */
- (BOOL)co_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile CO_ASYNC;
/*
 The coroutine wrap Interface that return value, usage:
 co_launch(^{
     BOOL ret = [data co_writeToURL:url atomically:YES];
     if(!ret){
        NSLog(@"write to file error");
     }
 });
 */
- (BOOL)co_writeToURL:(NSURL *)url atomically:(BOOL)atomically CO_ASYNC; // the atomically flag is ignored if the url is not of a type the supports atomic writes

/*
 The coroutine wrap Interface that return value, usage:
 co_launch(^{
     NSError *error = nil;
     BOOL ret = [data co_writeToFile:path options:0 error:&error];
     if(!ret){
        NSLog(@"write to file error %@", error);
     }
 });
 */
- (BOOL)co_writeToFile:(NSString *)path options:(NSDataWritingOptions)writeOptionsMask  error:(NSError **)errorPtr CO_ASYNC;
/*
 The coroutine wrap Interface that return value, usage:
 co_launch(^{
     NSError *error = nil;
     BOOL ret = [data co_writeToURL:url options:0 error:&error];
     if(!ret){
        NSLog(@"write to file error %@", error);
     }
 });
 */
- (BOOL)co_writeToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr CO_ASYNC;

/*
 The coroutine wrap Interface that return value, usage:
 co_launch(^{
     NSError *error = nil;
     NSData* data = [NSData co_dataWithContentsOfFile:path options:0 error:&error];
     if(!data){
        NSLog(@"load error: %@", error);
     }
 });
 */
+ (NSData*)co_dataWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr CO_ASYNC;
/*
 The coroutine wrap Interface that return value, usage:
 co_launch(^{
 NSError *error = nil;
     NSData* data = [NSData co_dataWithContentsOfURL:url options:0 error:&error];
     if(!data){
        NSLog(@"load error: %@", error);
     }
 });
 */
+ (NSData*)co_dataWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr CO_ASYNC;
/*
 The coroutine wrap Interface that return value, usage:
 co_launch(^{
     NSData* data = [NSData co_dataWithContentsOfFile:path];
     if(!data){
        NSLog(@"load error");
     }
 });
 */
+ (NSData*)co_dataWithContentsOfFile:(NSString *)path CO_ASYNC;
/*
 The coroutine wrap Interface that return value, usage:
 co_launch(^{
     NSData* data = [NSData co_dataWithContentsOfURL:url];
     if(!data){
        NSLog(@"load error");
     }
 });
 */
+ (NSData*)co_dataWithContentsOfURL:(NSURL *)url CO_ASYNC;

/*
 The coroutine wrap Interface that return value, usage:
 co_launch(^{
     NSError *error = nil;
     NSData* data = [[NSData alloc] co_initWithContentsOfFile:path options:0 error:&error];
     if(!data){
        NSLog(@"load error: %@", error);
     }
 });
 */
- (NSData*)co_initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr CO_ASYNC;
/*
 The coroutine wrap Interface that return value, usage:
 co_launch(^{
     NSError *error = nil;
     NSData* data = [[NSData alloc] co_initWithContentsOfURL:url options:0 error:&error];
     if(!data){
        NSLog(@"load error: %@", error);
     }
 });
 */
- (NSData*)co_initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr CO_ASYNC;
/*
 The coroutine wrap Interface that return value, usage:
 co_launch(^{
     NSData* data = [[NSData alloc] co_initWithContentsOfFile:path];
     if(!data){
        NSLog(@"load error");
     }
 });
 */
- (NSData*)co_initWithContentsOfFile:(NSString *)path CO_ASYNC;
/*
 The coroutine wrap Interface that return value, usage:
 co_launch(^{
     NSData* data = [[NSData alloc] co_initWithContentsOfURL:url];
     if(!data){
        NSLog(@"load error");
     }
 });
 */
- (NSData*)co_initWithContentsOfURL:(NSURL *)url CO_ASYNC;


@end
