//
//  NSString+Coroutine.h
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

@interface NSString (COPromise)

/* These use the specified encoding.  If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
- (COPromise<NSString*>*)async_initWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc;
- (COPromise<NSString*>*)async_initWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc;
+ (COPromise<NSString*>*)async_stringWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc;
+ (COPromise<NSString*>*)async_stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc;


/* These try to determine the encoding, and return the encoding which was used.  Note that these methods might get "smarter" in subsequent releases of the system, and use additional techniques for recognizing encodings. If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
- (COPromise<COTuple2<NSString*, NSNumber*>*>*)async_initWithContentsOfURL:(NSURL *)url;
- (COPromise<COTuple2<NSString*, NSNumber*>*>*)async_initWithContentsOfFile:(NSString *)path;
+ (COPromise<COTuple2<NSString*, NSNumber*>*>*)async_stringWithContentsOfURL:(NSURL *)url;
+ (COPromise<COTuple2<NSString*, NSNumber*>*>*)async_stringWithContentsOfFile:(NSString *)path;


/* Write to specified url or path using the specified encoding.  The optional error return is to indicate file system or encoding errors.
 */
- (COPromise<NSNumber*>*)async_writeToURL:(NSURL *)url atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc;
- (COPromise<NSNumber*>*)async_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc;


- (COPromise<id>*)async_stringToJSONObject;

@end

@interface NSString (Coroutine)

/* These use the specified encoding.  If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
- (NSString*)co_initWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError**)error CO_ASYNC;
- (NSString*)co_initWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError**)error CO_ASYNC;
+ (NSString*)co_stringWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError**)error CO_ASYNC;
+ (NSString*)co_stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError**)error CO_ASYNC;


/* These try to determine the encoding, and return the encoding which was used.  Note that these methods might get "smarter" in subsequent releases of the system, and use additional techniques for recognizing encodings. If nil is returned, the optional error return indicates problem that was encountered (for instance, file system or encoding errors).
 */
- (NSString*)co_initWithContentsOfURL:(NSURL *)url usedEncoding:(nullable NSStringEncoding *)enc error:(NSError**)error CO_ASYNC;
- (NSString*)co_initWithContentsOfFile:(NSString *)path usedEncoding:(nullable NSStringEncoding *)enc error:(NSError**)error CO_ASYNC;
+ (NSString*)co_stringWithContentsOfURL:(NSURL *)url usedEncoding:(nullable NSStringEncoding *)enc error:(NSError**)error CO_ASYNC;
+ (NSString*)co_stringWithContentsOfFile:(NSString *)path usedEncoding:(nullable NSStringEncoding *)enc error:(NSError**)error CO_ASYNC;


/* Write to specified url or path using the specified encoding.  The optional error return is to indicate file system or encoding errors.
 */
- (BOOL)co_writeToURL:(NSURL *)url atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError**)error;
- (BOOL)co_writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError**)error;

- (id)co_stringToJSONObject;


@end

NS_ASSUME_NONNULL_END
