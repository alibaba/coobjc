//
//  UIVideoEditorController+Coroutine.m
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

#import "UIVideoEditorController+Coroutine.h"
#import <objc/runtime.h>
#import "COKitCommon.h"

static char coPromiseKey;
static char coOriginDelegateKey;

@interface COUIVideoEditorControllerDelegate: NSObject <UIVideoEditorControllerDelegate, UINavigationControllerDelegate>

+ (instancetype)sharedInstance;

@end





@implementation UIVideoEditorController (Coroutine)

- (void) co_set_promise:(COPromise*)promise{
    objc_setAssociatedObject(self, &coPromiseKey, promise, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (COPromise*)co_get_promise{
    return objc_getAssociatedObject(self, &coPromiseKey);
}

- (void) co_set_origin_delegate:(id <UINavigationControllerDelegate, UIVideoEditorControllerDelegate>)delegate{
    objc_setAssociatedObject(self, &coOriginDelegateKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id <UINavigationControllerDelegate, UIVideoEditorControllerDelegate>)co_get_origin_delegate{
    return objc_getAssociatedObject(self, &coOriginDelegateKey);
}


// present from keyWindow.rootViewController
- (COPromise<NSString*>*)co_present{
    return [self co_presentFromController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

// present from viewController
- (COPromise<NSString*>*)co_presentFromController:(UIViewController*)viewController{
    COPromise *promise = [COPromise promise];
    [self co_set_promise:promise];
    [self co_set_origin_delegate:self.delegate];
    self.delegate = [COUIVideoEditorControllerDelegate sharedInstance];
    [viewController presentViewController:self animated:YES completion:^{
        
    }];
    return promise;
}

@end

@implementation COUIVideoEditorControllerDelegate

+ (instancetype)sharedInstance{
    static COUIVideoEditorControllerDelegate *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[COUIVideoEditorControllerDelegate alloc] init];
    });
    return instance;
}

// The editor does not dismiss itself; the client dismisses it in these callbacks.
// The delegate will receive exactly one of the following callbacks, depending whether the user
// confirms or cancels or if the operation fails.
- (void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath // edited video is saved to a path in app's temporary directory
{
    [editor dismissViewControllerAnimated:YES completion:nil];
    id<UIVideoEditorControllerDelegate> delegate = [editor co_get_origin_delegate];
    if([delegate respondsToSelector:@selector(videoEditorController:didSaveEditedVideoToPath:)]){
        [delegate videoEditorController:editor didSaveEditedVideoToPath:editedVideoPath];
    }
    COPromise *promise = [editor co_get_promise];
    [promise fulfill:editedVideoPath];
}
- (void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error{
    [editor dismissViewControllerAnimated:YES completion:nil];
    id<UIVideoEditorControllerDelegate> delegate = [editor co_get_origin_delegate];
    if([delegate respondsToSelector:@selector(videoEditorController:didFailWithError:)]){
        [delegate videoEditorController:editor didFailWithError:error];
    }
    COPromise *promise = [editor co_get_promise];
    [promise reject:error];
}
- (void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor{
    id<UIVideoEditorControllerDelegate> delegate = [editor co_get_origin_delegate];
    if([delegate respondsToSelector:@selector(videoEditorControllerDidCancel:)]){
        [delegate videoEditorControllerDidCancel:editor];
    }
    COPromise *promise = [editor co_get_promise];
    [promise fulfill:nil];
}


@end
