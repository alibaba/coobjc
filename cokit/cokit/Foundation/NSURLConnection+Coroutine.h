//
//  NSURLConnection+Coroutine.h
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

NS_ASSUME_NONNULL_BEGIN


@interface NSURLConnection (COPromise)

/*
 if any of the methods below report an error, you can call co_getError() to get the NSError object
 */

/*!
 @method       sendAsynchronousRequest:queue:completionHandler:
 
 @abstract
 Performs an asynchronous load of the given
 request. When the request has completed or failed,
 the block will be executed from the context of the
 specified NSOperationQueue.
 
 @discussion
 This is a convenience routine that allows for
 asynchronous loading of an url based resource.  If
 the resource load is successful, the data parameter
 to the callback will contain the resource data and
 the error parameter will be nil.  If the resource
 load fails, the data parameter will be nil and the
 error will contain information about the failure.
 
 @param
 request   The request to load. Note that the request is
 deep-copied as part of the initialization
 process. Changes made to the request argument after
 this method returns do not affect the request that
 is used for the loading process.
 
 @param
 queue     An NSOperationQueue upon which    the handler block will
 be dispatched.
 */
+ (COPromise<COTuple2<NSURLResponse*, NSData*>*>*)async_sendAsynchronousRequest:(NSURLRequest*) request
                          queue:(NSOperationQueue*) queue;

+ (COPromise<COTuple2<NSURLResponse*, NSData*>*>*)async_sendAsynchronousRequest:(NSURLRequest*) request;

@end

@interface NSURLConnection (Coroutine)

/*
 if any of the methods below report an error, you can call co_getError() to get the NSError object
 */

/*!
 @method       sendAsynchronousRequest:queue:completionHandler:
 
 @abstract
 Performs an asynchronous load of the given
 request. When the request has completed or failed,
 the block will be executed from the context of the
 specified NSOperationQueue.
 
 @discussion
 This is a convenience routine that allows for
 asynchronous loading of an url based resource.  If
 the resource load is successful, the data parameter
 to the callback will contain the resource data and
 the error parameter will be nil.  If the resource
 load fails, the data parameter will be nil and the
 error will contain information about the failure.
 
 @param
 request   The request to load. Note that the request is
 deep-copied as part of the initialization
 process. Changes made to the request argument after
 this method returns do not affect the request that
 is used for the loading process.
 
 @param
 queue     An NSOperationQueue upon which    the handler block will
 be dispatched.
 */
+ (NSData*)co_sendAsynchronousRequest:(NSURLRequest*) request
                                queue:(NSOperationQueue*) queue
                             response:(NSURLResponse*_Nullable * _Nullable)response
                                error:(NSError**)error CO_ASYNC;

+ (NSData*)co_sendAsynchronousRequest:(NSURLRequest*) request response:(NSURLResponse*_Nullable * _Nullable)response error:(NSError**)error CO_ASYNC;

+ (NSData*)co_sendAsynchronousRequest:(NSURLRequest*) request error:(NSError**)error CO_ASYNC;

+ (NSData*)co_sendAsynchronousRequest:(NSURLRequest*) request CO_ASYNC;



@end

NS_ASSUME_NONNULL_END
