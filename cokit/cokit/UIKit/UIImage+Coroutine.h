//
//  UIImage+Coroutine.h
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

#import <UIKit/UIKit.h>
#import <coobjc/COPromise.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (COPromise)

+ (COPromise<UIImage *>*)async_imageNamed:(NSString *)name;      // load from main bundle
#if __has_include(<UIKit/UITraitCollection.h>)
+ (COPromise<UIImage *>*)async_imageNamed:(NSString *)name inBundle:(nullable NSBundle *)bundle compatibleWithTraitCollection:(nullable UITraitCollection *)traitCollection NS_AVAILABLE_IOS(8_0);
#endif

+ (COPromise<UIImage *>*)async_imageWithContentsOfFile:(NSString *)path;
+ (COPromise<UIImage *>*)async_imageWithData:(NSData *)data;
+ (COPromise<UIImage *>*)async_imageWithData:(NSData *)data scale:(CGFloat)scale NS_AVAILABLE_IOS(6_0);

- (COPromise<UIImage *>*)async_initWithContentsOfFile:(NSString *)path;
- (COPromise<UIImage *>*)async_initWithData:(NSData *)data;
- (COPromise<UIImage *>*)async_initWithData:(NSData *)data scale:(CGFloat)scale NS_AVAILABLE_IOS(6_0);

@end

@interface UIImage (Coroutine)

+ (UIImage *)co_imageNamed:(NSString *)name;      // load from main bundle
#if __has_include(<UIKit/UITraitCollection.h>)
+ (UIImage *)co_imageNamed:(NSString *)name inBundle:(nullable NSBundle *)bundle compatibleWithTraitCollection:(nullable UITraitCollection *)traitCollection NS_AVAILABLE_IOS(8_0);
#endif

+ (UIImage *)co_imageWithContentsOfFile:(NSString *)path;
+ (UIImage *)co_imageWithData:(NSData *)data;
+ (UIImage *)co_imageWithData:(NSData *)data scale:(CGFloat)scale NS_AVAILABLE_IOS(6_0);

- (UIImage *)co_initWithContentsOfFile:(NSString *)path;
- (UIImage *)co_initWithData:(NSData *)data;
- (UIImage *)co_initWithData:(NSData *)data scale:(CGFloat)scale NS_AVAILABLE_IOS(6_0);

@end

COPromise<NSData *>* async_UIImagePNGRepresentation(UIImage * __nonnull image);                               // return image as PNG. May return nil if image has no CGImageRef or invalid bitmap format
COPromise<NSData *>* async_UIImageJPEGRepresentation(UIImage * __nonnull image, CGFloat compressionQuality);  // return image as JPEG. May return nil if image has no CGImageRef or invalid bitmap format. compression is 0(most)..1(least)


NSData * co_UIImagePNGRepresentation(UIImage * __nonnull image);                               // return image as PNG. May return nil if image has no CGImageRef or invalid bitmap format
NSData * co_UIImageJPEGRepresentation(UIImage * __nonnull image, CGFloat compressionQuality);  // return image as JPEG. May return nil if image has no CGImageRef or invalid bitmap format. compression is 0(most)..1(least)

NS_ASSUME_NONNULL_END
