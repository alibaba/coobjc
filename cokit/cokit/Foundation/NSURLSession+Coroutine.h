//
//  NSURLSession+Coroutine.h
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
#import <coobjc/co_tuple.h>
#import <coobjc/coobjc.h>


NS_ASSUME_NONNULL_BEGIN

@interface NSURLSession (COPromise)

/*
 if any of the methods below report an error, you can call async_getError() to get the NSError object
 */

/*
 * data task convenience methods.  These methods create tasks that
 * bypass the normal delegate calls for response and data delivery,
 * and provide a simple cancelable asynchronous interface to receiving
 * data.  Errors will be returned in the NSURLErrorDomain,
 * see <Foundation/NSURLError.h>.  The delegate, if any, will still be
 * called for authentication challenges.
 */
- (COPromise<COTuple2<NSData*, NSURLResponse*>*>*)async_dataTaskWithRequest:(NSURLRequest *)request;

- (COPromise<COTuple2<NSData*, NSURLResponse*>*>*)async_dataTaskWithURL:(NSURL *)url;

/*
 * upload convenience method.
 */
- (COPromise<COTuple2<NSData*, NSURLResponse*>*>*)async_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL;
- (COPromise<COTuple2<NSData*, NSURLResponse*>*>*)async_uploadTaskWithRequest:(NSURLRequest *)request fromData:(nullable NSData *)bodyData;

/*
 * download task convenience methods.  When a download successfully
 * completes, the NSURL will point to a file that must be read or
 * copied during the invocation of the completion routine.  The file
 * will be removed automatically.
 */
- (COPromise<COTuple2<NSURL*, NSURLResponse*>*>*)async_downloadTaskWithRequest:(NSURLRequest *)request;
- (COPromise<COTuple2<NSURL*, NSURLResponse*>*>*)async_downloadTaskWithURL:(NSURL *)url;
- (COPromise<COTuple2<NSURL*, NSURLResponse*>*>*)async_downloadTaskWithResumeData:(NSData *)resumeData;

@end

@interface NSURLSession (Coroutine)

/*
 if any of the methods below report an error, you can call async_getError() to get the NSError object
 */

/*
 * data task convenience methods.  These methods create tasks that
 * bypass the normal delegate calls for response and data delivery,
 * and provide a simple cancelable asynchronous interface to receiving
 * data.  Errors will be returned in the NSURLErrorDomain,
 * see <Foundation/NSURLError.h>.  The delegate, if any, will still be
 * called for authentication challenges.
 */
- (NSData*)co_dataTaskWithRequest:(NSURLRequest *)request response:(NSURLResponse*_Nullable*_Nullable)response error:(NSError**)error CO_ASYNC;

- (NSData*)co_dataTaskWithURL:(NSURL *)url response:(NSURLResponse*_Nullable*_Nullable)response error:(NSError**)error CO_ASYNC;

/*
 * upload convenience method.
 */
- (NSData*)co_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL response:(NSURLResponse*_Nullable*_Nullable)response error:(NSError**)error CO_ASYNC;
- (NSData*)co_uploadTaskWithRequest:(NSURLRequest *)request fromData:(nullable NSData *)bodyData response:(NSURLResponse*_Nullable*_Nullable)response error:(NSError**)error CO_ASYNC;

/*
 * download task convenience methods.  When a download successfully
 * completes, the NSURL will point to a file that must be read or
 * copied during the invocation of the completion routine.  The file
 * will be removed automatically.
 */
- (NSURL*)co_downloadTaskWithRequest:(NSURLRequest *)request response:(NSURLResponse*_Nullable*_Nullable)response error:(NSError**)error CO_ASYNC;
- (NSURL*)co_downloadTaskWithURL:(NSURL *)url response:(NSURLResponse*_Nullable*_Nullable)response error:(NSError**)error CO_ASYNC;
- (NSURL*)co_downloadTaskWithResumeData:(NSData *)resumeData response:(NSURLResponse*_Nullable*_Nullable)response error:(NSError**)error CO_ASYNC;

@end

NS_ASSUME_NONNULL_END
