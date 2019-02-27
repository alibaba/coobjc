//
//  UIImagePickerController+Coroutine.h
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
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

@interface COImagePickerResult: NSObject

//(UTI, i.e. kUTTypeImage)
@property(nonatomic, copy, readonly) NSString *mediaType;

@property(nonatomic, strong, readonly) UIImage *originalImage;


@property(nonatomic, strong, readonly) UIImage *editedImage;

@property(nonatomic, assign, readonly) CGRect cropRect;

@property(nonatomic, strong, readonly) NSURL *mediaURL;

@property(nonatomic, strong, readonly) NSURL *referenceURL;

@property(nonatomic, copy, readonly) NSDictionary* mediaMetadata;

@property(nonatomic, strong, readonly) PHLivePhoto *livePhoto PHOTOS_AVAILABLE_IOS_TVOS(9_1, 10_0);

@property(nonatomic, strong, readonly) PHAsset *asset;

@property(nonatomic, strong, readonly) NSURL *imageURL;

@end


@interface UIImagePickerController (Coroutine)

// present from keyWindow.rootViewController
- (COPromise<COImagePickerResult *>*) co_present;

// present from viewController
- (COPromise<COImagePickerResult *>*) co_presentFromController:(UIViewController*)viewController;

@end

COPromise<NSNumber*>* co_UIImageWriteToSavedPhotosAlbum(UIImage *image);

COPromise<NSNumber*>* co_UISaveVideoAtPathToSavedPhotosAlbum(NSString *videoPath);
