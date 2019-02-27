//
//  UIAlertController+Coroutine.m
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

#import "UIAlertController+Coroutine.h"
#import <objc/runtime.h>

static char coPromiseKey;


@implementation UIAlertController (Coroutine)

- (void) co_set_promise:(COPromise*)promise{
    objc_setAssociatedObject(self, &coPromiseKey, promise, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (COPromise*)co_get_promise{
    return objc_getAssociatedObject(self, &coPromiseKey);
}

// build an UIAlertView style controller
+ (instancetype)co_alertWithTitle:(NSString*)title
                          message:(NSString*)message
                cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ...{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    COPromise *promise = [COPromise promise];
    
    if(cancelButtonTitle.length > 0){
        [controller addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [promise fulfill:action.title];
        }]];
    }
    
    if(otherButtonTitles.length > 0){
        [controller addAction:[UIAlertAction actionWithTitle:otherButtonTitles style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [promise fulfill:action.title];
        }]];
    }
    
    
    if (otherButtonTitles) {
        va_list args;
        va_start(args, otherButtonTitles);
        while (YES)
        {
            NSString *title = va_arg(args, NSString *);
            if (title == nil) {
                break;
            }
            
            [controller addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [promise fulfill:action.title];
            }]];
        }
        va_end(args);
    }
    

    
    [controller co_set_promise:promise];

    return controller;
}

// build an UIActionSheet style controller
+ (instancetype)co_actionSheetWithTitle:(NSString*)title
                      cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                 destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle
                      otherButtonTitles:(nullable NSString *)otherButtonTitles, ...{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    COPromise *promise = [COPromise promise];
    
    if(cancelButtonTitle.length > 0){
        [controller addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [promise fulfill:action.title];
        }]];
    }
    
    if(destructiveButtonTitle.length > 0){
        [controller addAction:[UIAlertAction actionWithTitle:destructiveButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [promise fulfill:action.title];
        }]];
    }
    
    if(otherButtonTitles.length > 0){
        [controller addAction:[UIAlertAction actionWithTitle:otherButtonTitles style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [promise fulfill:action.title];
        }]];
    }
    
    va_list args;
    va_start(args, otherButtonTitles);
    while (YES)
    {
        NSString *title = va_arg(args, NSString *);
        if (title == nil) {
            break;
        }
        
        [controller addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [promise fulfill:action.title];
        }]];
    }
    va_end(args);
    
    [controller co_set_promise:promise];
    
    return controller;
}

// present from keyWindow rootViewController
- (COPromise<NSString*>*)co_present{
    
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:self animated:YES completion:^{
        
    }];
    
    return [self co_get_promise];
}

// present from viewController
- (COPromise<NSString*>*)co_presentFromController:(UIViewController*)viewController{
    [viewController presentViewController:self animated:YES completion:^{
        
    }];
    return [self co_get_promise];
}

@end
