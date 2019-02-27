//
//  UIImagePickerController+Coroutine.m
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

#import "UIImagePickerController+Coroutine.h"
#import <objc/runtime.h>
#import "COKitCommon.h"

static char coPromiseKey;
static char coOriginDelegateKey;

@interface COUIImagePickerControllerDelegate: NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

+ (instancetype)sharedInstance;

@end


@interface COImagePickerResult ()

@property (nonatomic, copy) NSDictionary *dict;

- (instancetype)initWithInfo:(NSDictionary*)info;

@end




@implementation UIImagePickerController (Coroutine)

- (void) co_set_promise:(COPromise*)promise{
    objc_setAssociatedObject(self, &coPromiseKey, promise, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (COPromise*)co_get_promise{
    return objc_getAssociatedObject(self, &coPromiseKey);
}

- (void) co_set_origin_delegate:(id <UINavigationControllerDelegate, UIImagePickerControllerDelegate>)delegate{
    objc_setAssociatedObject(self, &coOriginDelegateKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id <UINavigationControllerDelegate, UIImagePickerControllerDelegate>)co_get_origin_delegate{
    return objc_getAssociatedObject(self, &coOriginDelegateKey);
}

// present from keyWindow.rootViewController
- (COPromise<COImagePickerResult *>*) co_present{
    return [self co_presentFromController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

// present from viewController
- (COPromise<COImagePickerResult *>*) co_presentFromController:(UIViewController*)viewController{
    COPromise *promise = [COPromise promise];
    [self co_set_promise:promise];
    [self co_set_origin_delegate:self.delegate];
    self.delegate = [COUIImagePickerControllerDelegate sharedInstance];
    [viewController presentViewController:self animated:YES completion:^{
        
    }];
    return promise;
}

@end


@implementation COUIImagePickerControllerDelegate

+ (instancetype)sharedInstance{
    static COUIImagePickerControllerDelegate *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[COUIImagePickerControllerDelegate alloc] init];
    });
    return instance;
}

// The picker does not dismiss itself; the client dismisses it in these callbacks.
// The delegate will receive one or the other, but not both, depending whether the user
// confirms or cancels.

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    id<UIImagePickerControllerDelegate> delegate = [picker co_get_origin_delegate];
    if([delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)]){
        [delegate imagePickerController:picker didFinishPickingMediaWithInfo:info];
    }
    
    COPromise *promise = [picker co_get_promise];
    [promise fulfill:[[COImagePickerResult alloc] initWithInfo:info]];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];

    id<UIImagePickerControllerDelegate> delegate = [picker co_get_origin_delegate];
    if([delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]){
        [delegate imagePickerControllerDidCancel:picker];
    }
    
    COPromise *promise = [picker co_get_promise];
    [promise fulfill:nil];
}

// Called when the navigation controller shows a new top view controller via a push, pop or setting of the view controller stack.
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    UIImagePickerController *picker = (UIImagePickerController*)navigationController;
    id<UINavigationControllerDelegate> delegate = [picker co_get_origin_delegate];
    if([delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]){
        [delegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    UIImagePickerController *picker = (UIImagePickerController*)navigationController;
    id<UINavigationControllerDelegate> delegate = [picker co_get_origin_delegate];
    if([delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]){
        [delegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}

//- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
//    UIImagePickerController *picker = (UIImagePickerController*)navigationController;
//    id<UINavigationControllerDelegate> delegate = [picker co_get_origin_delegate];
//    if([delegate respondsToSelector:@selector(navigationControllerSupportedInterfaceOrientations:)]){
//        return [delegate navigationControllerSupportedInterfaceOrientations:navigationController];
//    }
//    else{
//        return UIInterfaceOrientationMaskAll;
//    }
//}
//- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController {
//    UIImagePickerController *picker = (UIImagePickerController*)navigationController;
//    id<UINavigationControllerDelegate> delegate = [picker co_get_origin_delegate];
//    if([delegate respondsToSelector:@selector(navigationControllerPreferredInterfaceOrientationForPresentation:)]){
//        return [delegate navigationControllerPreferredInterfaceOrientationForPresentation:navigationController];
//    }
//    else{
//        return UIInterfaceOrientationUnknown;
//    }
//}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController NS_AVAILABLE_IOS(7_0){
    UIImagePickerController *picker = (UIImagePickerController*)navigationController;
    id<UINavigationControllerDelegate> delegate = [picker co_get_origin_delegate];
    if([delegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]){
        return [delegate navigationController:navigationController interactionControllerForAnimationController:animationController];
    }
    else{
        return nil;
    }
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC  NS_AVAILABLE_IOS(7_0){
    UIImagePickerController *picker = (UIImagePickerController*)navigationController;
    id<UINavigationControllerDelegate> delegate = [picker co_get_origin_delegate];
    if([delegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]){
        return [delegate navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
    }
    else{
        return nil;
    }
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    COPromise *promise = (__bridge COPromise *)(contextInfo);
    if(promise){
        if(error){
            [promise reject:error];
        }
        else{
            [promise fulfill:@(YES)];
        }
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    COPromise *promise = (__bridge COPromise *)(contextInfo);
    if(promise){
        if(error){
            [promise reject:error];
        }
        else{
            [promise fulfill:@(YES)];
        }
    }
}


@end

@implementation COImagePickerResult

- (instancetype)initWithInfo:(NSDictionary*)info{
    self = [super init];
    if (self) {
        _dict = info;
    }
    return self;
}

- (NSString *)mediaType{
    return _dict[UIImagePickerControllerMediaType];
}

- (UIImage *)originalImage{
    return _dict[UIImagePickerControllerOriginalImage];
}

- (UIImage *)editedImage{
    return _dict[UIImagePickerControllerEditedImage];
}

- (CGRect)cropRect{
    return [_dict[UIImagePickerControllerCropRect] CGRectValue];
}

- (NSURL *)mediaURL{
    return _dict[UIImagePickerControllerMediaURL];
}

- (NSURL *)referenceURL{
    return _dict[UIImagePickerControllerReferenceURL];
}

- (NSDictionary *)mediaMetadata{
    return _dict[UIImagePickerControllerMediaMetadata];
}

- (PHLivePhoto *)livePhoto{
    return _dict[UIImagePickerControllerLivePhoto];
}

- (PHAsset *)asset{
    if (@available(iOS 11.0, *)) {
        return _dict[UIImagePickerControllerPHAsset];
    } else {
        // Fallback on earlier versions
        return nil;
    }
}

- (NSURL *)imageURL{
    if (@available(iOS 11.0, *)) {
        return _dict[UIImagePickerControllerImageURL];
    } else {
        // Fallback on earlier versions
        return nil;
    }
}

@end

COPromise<NSNumber*>* co_UIImageWriteToSavedPhotosAlbum(UIImage *image){
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlock:^{
        UIImageWriteToSavedPhotosAlbum(image, [COUIImagePickerControllerDelegate sharedInstance], @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void * _Nullable)(promise));
    } onQueue:[COKitCommon io_write_queue]];
    return promise;
}

COPromise<NSNumber*>* co_UISaveVideoAtPathToSavedPhotosAlbum(NSString *videoPath){
    COPromise *promise = [COPromise promise];
    [COKitCommon runBlock:^{
        UISaveVideoAtPathToSavedPhotosAlbum(videoPath, [COUIImagePickerControllerDelegate sharedInstance], @selector(video:didFinishSavingWithError:contextInfo:), (__bridge void * _Nullable)(promise));
    } onQueue:[COKitCommon io_write_queue]];
    return promise;
}


