//
//  NSURLSession+Coroutine.m
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

#import "NSURLSession+Coroutine.h"

@implementation NSURLSession (COPromise)

/*
 * data task convenience methods.  These methods create tasks that
 * bypass the normal delegate calls for response and data delivery,
 * and provide a simple cancelable asynchronous interface to receiving
 * data.  Errors will be returned in the NSURLErrorDomain,
 * see <Foundation/NSURLError.h>.  The delegate, if any, will still be
 * called for authentication challenges.
 */
- (COPromise<COTuple2<NSData*, NSURLResponse*>*>*)async_dataTaskWithRequest:(NSURLRequest *)request{
    COPromise *promise = [COPromise promise];
    
    NSURLSessionDataTask *task = [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:co_tuple(data, response)];
        }
    }];
    
    [promise onCancel:^(COPromise * _Nonnull promise) {
        [task cancel];
    }];
    
    [task resume];
    
    return promise;
}

- (COPromise<COTuple2<NSData*, NSURLResponse*>*>*)async_dataTaskWithURL:(NSURL *)url{
    COPromise *promise = [COPromise promise];
    
    NSURLSessionDataTask *task = [self dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:co_tuple(data, response)];
        }
    }];
    
    [promise onCancel:^(COPromise * _Nonnull promise) {
        [task cancel];
    }];
    
    [task resume];
    
    return promise;
}

/*
 * upload convenience method.
 */
- (COPromise<COTuple2<NSData*, NSURLResponse*>*>*)async_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL{
    COPromise *promise = [COPromise promise];
    
    NSURLSessionUploadTask *task = [self uploadTaskWithRequest:request fromFile:fileURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:co_tuple(data, response)];
        }
    }];
    
    [promise onCancel:^(COPromise * _Nonnull promise) {
        [task cancel];
    }];
    
    [task resume];
    
    return promise;
}
- (COPromise<COTuple2<NSData*, NSURLResponse*>*>*)async_uploadTaskWithRequest:(NSURLRequest *)request fromData:(nullable NSData *)bodyData{
    COPromise *promise = [COPromise promise];
    
    NSURLSessionUploadTask *task = [self uploadTaskWithRequest:request fromData:bodyData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:co_tuple(data, response)];
        }
    }];
    
    [promise onCancel:^(COPromise * _Nonnull promise) {
        [task cancel];
    }];
    
    [task resume];
    
    return promise;
}

/*
 * download task convenience methods.  When a download successfully
 * completes, the NSURL will point to a file that must be read or
 * copied during the invocation of the completion routine.  The file
 * will be removed automatically.
 */
- (COPromise<COTuple2<NSURL*, NSURLResponse*>*>*)async_downloadTaskWithRequest:(NSURLRequest *)request{
    COPromise *promise = [COPromise promise];
    
    NSURLSessionDownloadTask *task = [self downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:co_tuple(location, response)];
        }
    }];
    
    [promise onCancel:^(COPromise * _Nonnull promise) {
        [task cancel];
    }];
    
    [task resume];
    
    return promise;
}
- (COPromise<COTuple2<NSURL*, NSURLResponse*>*>*)async_downloadTaskWithURL:(NSURL *)url{
    COPromise *promise = [COPromise promise];
    
    NSURLSessionDownloadTask *task = [self downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:co_tuple(location, response)];
        }
    }];
    
    [promise onCancel:^(COPromise * _Nonnull promise) {
        [task cancel];
    }];
    
    [task resume];
    
    return promise;
}
- (COPromise<COTuple2<NSURL*, NSURLResponse*>*>*)async_downloadTaskWithResumeData:(NSData *)resumeData{
    COPromise *promise = [COPromise promise];
    
    NSURLSessionDownloadTask *task = [self downloadTaskWithResumeData:resumeData completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:co_tuple(location, response)];
        }
    }];
    
    [promise onCancel:^(COPromise * _Nonnull promise) {
        [task cancel];
    }];
    
    [task resume];
    
    return promise;
}


@end

@implementation NSURLSession (Coroutine)

- (NSData *)co_dataTaskWithRequest:(NSURLRequest *)request response:(NSURLResponse *__autoreleasing  _Nullable *)response error:(NSError * _Nullable __autoreleasing *)error{
    SURE_ASYNC
    NSData *data = nil;
    NSURLResponse *resp = nil;
    co_unpack(&data, &resp) = await([self async_dataTaskWithRequest:request]);
    if (error) {
        *error = co_getError();
    }
    if (response) {
        *response = resp;
    }
    return data;
}

- (NSData *)co_dataTaskWithURL:(NSURL *)url response:(NSURLResponse *__autoreleasing  _Nullable *)response error:(NSError * _Nullable __autoreleasing *)error{
    SURE_ASYNC
    NSData *data = nil;
    NSURLResponse *resp = nil;
    co_unpack(&data, &resp) = await([self async_dataTaskWithURL:url]);
    if (error) {
        *error = co_getError();
    }
    if (response) {
        *response = resp;
    }
    return data;
}

- (NSData *)co_uploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)bodyData response:(NSURLResponse *__autoreleasing  _Nullable *)response error:(NSError * _Nullable __autoreleasing *)error{
    SURE_ASYNC
    NSData *data = nil;
    NSURLResponse *resp = nil;
    co_unpack(&data, &resp) = await([self async_uploadTaskWithRequest:request fromData:bodyData]);
    if (error) {
        *error = co_getError();
    }
    if (response) {
        *response = resp;
    }
    return data;
}

- (NSData *)co_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL response:(NSURLResponse *__autoreleasing  _Nullable *)response error:(NSError * _Nullable __autoreleasing *)error{
    SURE_ASYNC
    NSData *data = nil;
    NSURLResponse *resp = nil;
    co_unpack(&data, &resp) = await([self async_uploadTaskWithRequest:request fromFile:fileURL]);
    if (error) {
        *error = co_getError();
    }
    if (response) {
        *response = resp;
    }
    return data;
}

- (NSURL *)co_downloadTaskWithURL:(NSURL *)url response:(NSURLResponse *__autoreleasing  _Nullable *)response error:(NSError * _Nullable __autoreleasing *)error{
    SURE_ASYNC
    NSURL *fileURL = nil;
    NSURLResponse *resp = nil;
    co_unpack(&fileURL, &resp) = await([self async_downloadTaskWithURL:url]);
    if (error) {
        *error = co_getError();
    }
    if (response) {
        *response = resp;
    }
    return fileURL;
}

- (NSURL *)co_downloadTaskWithRequest:(NSURLRequest *)request response:(NSURLResponse *__autoreleasing  _Nullable *)response error:(NSError * _Nullable __autoreleasing *)error{
    SURE_ASYNC
    NSURL *fileURL = nil;
    NSURLResponse *resp = nil;
    co_unpack(&fileURL, &resp) = await([self async_downloadTaskWithRequest:request]);
    if (error) {
        *error = co_getError();
    }
    if (response) {
        *response = resp;
    }
    return fileURL;
}

- (NSURL *)co_downloadTaskWithResumeData:(NSData *)resumeData response:(NSURLResponse *__autoreleasing  _Nullable *)response error:(NSError * _Nullable __autoreleasing *)error{
    SURE_ASYNC
    NSURL *fileURL = nil;
    NSURLResponse *resp = nil;
    co_unpack(&fileURL, &resp) = await([self async_downloadTaskWithResumeData:resumeData]);
    if (error) {
        *error = co_getError();
    }
    if (response) {
        *response = resp;
    }
    return fileURL;
}

@end
