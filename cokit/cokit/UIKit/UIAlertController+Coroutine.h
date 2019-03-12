//
//  UIAlertController+Coroutine.h
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
#import <coobjc/coobjc.h>

NS_ASSUME_NONNULL_BEGIN


@interface UIAlertController (Coroutine)

// build an UIAlertView style controller
+ (instancetype)co_alertWithTitle:(nullable NSString*)title
                          message:(nullable NSString*)message
                cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

// build an UIActionSheet style controller
+ (instancetype)co_actionSheetWithTitle:(nullable NSString*)title
                      cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                 destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle
                      otherButtonTitles:(nullable NSString *)otherButtonTitles, ...;

// present from keyWindow rootViewController
- (COPromise<NSString*>*)co_present;

// present from viewController
- (COPromise<NSString*>*)co_presentFromController:(UIViewController*)viewController;


@end

NS_ASSUME_NONNULL_END
