//
//  UIImage+Coroutine.m
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

#import "UIImage+Coroutine.h"
#import "COKitCommon.h"
#import <coobjc/coobjc.h>

@implementation UIImage (Coroutine)

+ (UIImage *)co_imageNamed:(NSString *)name{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_imageNamed:name]);
    }
    else{
        return [self imageNamed:name];
    }
}

#if __has_include(<UIKit/UITraitCollection.h>)
+ (UIImage *)co_imageNamed:(NSString *)name inBundle:(NSBundle *)bundle compatibleWithTraitCollection:(UITraitCollection *)traitCollection{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_imageNamed:name inBundle:bundle compatibleWithTraitCollection:traitCollection]);
    }
    else{
        return [self imageNamed:name inBundle:bundle compatibleWithTraitCollection:traitCollection];
    }
}
#endif

+ (UIImage *)co_imageWithContentsOfFileNamed:(NSString *)imageName{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_imageWithContentsOfFileNamed:imageName]);
    }
    else{
        return nil;
    }
}

+ (UIImage *)co_imageWithContentsOfFile:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_imageWithContentsOfFile:path]);
    }
    else{
        return [self imageWithContentsOfFile:path];
    }
}

+ (UIImage *)co_imageWithData:(NSData *)data{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_imageWithData:data]);
    }
    else{
        return [self imageWithData:data];
    }
}

+ (UIImage *)co_imageWithData:(NSData *)data scale:(CGFloat)scale{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_imageWithData:data scale:scale]);
    }
    else{
        return [self imageWithData:data scale:scale];
    }
}

- (UIImage *)co_initWithContentsOfFileNamed:(NSString *)imageName{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_initWithContentsOfFileNamed:imageName]);
    }
    return nil;
}

- (UIImage *)co_initWithContentsOfFile:(NSString *)path{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_initWithContentsOfFile:path]);
    }
    else{
        return [self initWithContentsOfFile:path];
    }
}

- (UIImage *)co_initWithData:(NSData *)data{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_initWithData:data]);
    }
    else{
        return [self initWithData:data];
    }
}

- (UIImage *)co_initWithData:(NSData *)data scale:(CGFloat)scale{
    if ([COCoroutine currentCoroutine]) {
        return await([self async_initWithData:data scale:scale]);
    }
    else{
        return [self initWithData:data scale:scale];
    }
}

@end


@implementation UIImage (COPromise)

+ (COPromise<UIImage *>*)async_imageNamed:(NSString *)name      // load from main bundle
{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlock:^{
            UIImage *image = [UIImage imageNamed:name];
            if (image) {
                resolve(image);
            }
            else{
                resolve(nil);
            }
        } onQueue:[COKitCommon image_queue]];
    }];
}
#if __has_include(<UIKit/UITraitCollection.h>)
+ (COPromise<UIImage *>*)async_imageNamed:(NSString *)name inBundle:(nullable NSBundle *)bundle compatibleWithTraitCollection:(nullable UITraitCollection *)traitCollection{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlock:^{
            UIImage *image = [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:traitCollection];
            if (image) {
                resolve(image);
            }
            else{
                resolve(nil);
            }
        } onQueue:[COKitCommon image_queue]];
    }];
}
#endif

+ (COPromise<UIImage *>*)async_imageWithContentsOfFileNamed:(NSString *)imageName{
    return [[self alloc] async_initWithContentsOfFileNamed:imageName];
}



+ (COPromise<UIImage *>*)async_imageWithContentsOfFile:(NSString *)path{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlock:^{
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            if (image) {
                resolve(image);
            }
            else{
                resolve(nil);
            }
        } onQueue:[COKitCommon image_queue]];
    }];
}
+ (COPromise<UIImage *>*)async_imageWithData:(NSData *)data{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlock:^{
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                resolve(image);
            }
            else{
                resolve(nil);
            }
        } onQueue:[COKitCommon image_queue]];
    }];
}
+ (COPromise<UIImage *>*)async_imageWithData:(NSData *)data scale:(CGFloat)scale{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlock:^{
            UIImage *image = [UIImage imageWithData:data scale:scale];
            if (image) {
                resolve(image);
            }
            else{
                resolve(nil);
            }
        } onQueue:[COKitCommon image_queue]];
    }];
}

- (COPromise<UIImage *> *)async_initWithContentsOfFileNamed:(NSString *)imageName{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlock:^{
            if (imageName.length <= 0) {
                resolve(nil);
                return;
            }
            NSArray *list = [imageName componentsSeparatedByString:@"."];
            
            NSString *type = nil;
            NSString *suffix = nil;
            NSString *fileName = list.firstObject;
            if (list.count >= 2) {
                type = list.lastObject;
            }
            if ([fileName hasPrefix:@"@2x"]) {
                suffix = @"@2x";
                fileName = [fileName stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
            }
            if ([fileName hasPrefix:@"@3x"]) {
                suffix = @"@3x";
                fileName = [fileName stringByReplacingOccurrencesOfString:@"@3x" withString:@""];
            }
            NSArray *typeList = @[@"png", @"jpg"];
            NSArray *suffixList = @[@"", @"@2x", @"@3x"];
            if (type.length > 0) {
                typeList = @[type];
            }
            if (suffix.length > 0) {
                suffixList = @[@"", suffix];
            }
            
            NSString *filePath = nil;
            
            for (NSString *s in suffixList) {
                for (NSString *t in typeList) {
                    NSString *f = [NSString stringWithFormat:@"%@%@", fileName, s];
                    filePath = [[NSBundle mainBundle] pathForResource:f ofType:t];
                    if (filePath) {
                        break;
                    }
                }
                if (filePath) {
                    break;
                }
            }
            UIImage *image = [self initWithContentsOfFile:filePath];
            if (image) {
                resolve(image);
            }
            else{
                resolve(nil);
            }
        } onQueue:[COKitCommon image_queue]];
    }];
}

- (COPromise<UIImage *>*)async_initWithContentsOfFile:(NSString *)path{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlock:^{
            UIImage *image = [self initWithContentsOfFile:path];
            if (image) {
                resolve(image);
            }
            else{
                resolve(nil);
            }
        } onQueue:[COKitCommon image_queue]];
    }];
}
- (COPromise<UIImage *>*)async_initWithData:(NSData *)data{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlock:^{
            UIImage *image = [self initWithData:data];
            if (image) {
                resolve(image);
            }
            else{
                resolve(nil);
            }
        } onQueue:[COKitCommon image_queue]];
    }];
}
- (COPromise<UIImage *>*)async_initWithData:(NSData *)data scale:(CGFloat)scale{
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlock:^{
            UIImage *image = [self initWithData:data scale:scale];
            if (image) {
                resolve(image);
            }
            else{
                resolve(nil);
            }
        } onQueue:[COKitCommon image_queue]];
    }];
}

@end

COPromise<NSData *>* async_UIImagePNGRepresentation(UIImage * __nonnull image){
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlock:^{
            NSData *data = UIImagePNGRepresentation(image);
            if (data) {
                resolve(data);
            }
            else{
                resolve(nil);
            }
        } onQueue:[COKitCommon image_queue]];
    }];
}
COPromise<NSData *>* async_UIImageJPEGRepresentation(UIImage * __nonnull image, CGFloat compressionQuality){
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        [COKitCommon runBlock:^{
            NSData *data = UIImageJPEGRepresentation(image, compressionQuality);
            if (data) {
                resolve(data);
            }
            else{
                resolve(nil);
            }
        } onQueue:[COKitCommon image_queue]];
    }];
}

NSData * co_UIImagePNGRepresentation(UIImage * __nonnull image)                               // return image as PNG. May return nil if image has no CGImageRef or invalid bitmap format
{
    if ([COCoroutine currentCoroutine]) {
        return await(async_UIImagePNGRepresentation(image));
    }
    else{
        return UIImagePNGRepresentation(image);
    }
}
NSData * co_UIImageJPEGRepresentation(UIImage * __nonnull image, CGFloat compressionQuality)  // return image as JPEG. May return nil if image has no CGImageRef or invalid bitmap format. compression is 0(most)..1(least)
{
    if ([COCoroutine currentCoroutine]) {
        return await(async_UIImageJPEGRepresentation(image, compressionQuality));
    }
    else{
        return UIImageJPEGRepresentation(image, compressionQuality);
    }
}
