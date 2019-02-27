//
//  AlertDemoViewController.m
//  coKitExamples
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

#import "AlertDemoViewController.h"
#import <cokit/UIAlertController+Coroutine.h>
#import <coobjc/coobjc.h>

@interface AlertDemoViewController ()

@end

@implementation AlertDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"alert demo";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showSimpleAlert:(id)sender{
    co_launch(^{
        NSString *title = NSLocalizedString(@"A Short Title Is Best", nil);
        NSString *message = NSLocalizedString(@"A message should be a short, complete sentence.", nil);
        NSString *cancelButtonTitle = NSLocalizedString(@"OK", nil);
        UIAlertController *alertController = [UIAlertController co_alertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles: nil];
        
        NSString *result = await([alertController co_presentFromController:self]);
        NSLog(@"The simple alert's cancel action occured.");
    });
}

- (IBAction)showOkayCancelAlert:(id)sender {
    co_launch(^{
        NSString *title = NSLocalizedString(@"A Short Title Is Best", nil);
        NSString *message = NSLocalizedString(@"A message should be a short, complete sentence.", nil);
        NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
        NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
        
        
        UIAlertController *alertController = [UIAlertController co_alertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles: otherButtonTitle, nil];
        
        NSString *result = await([alertController co_presentFromController:self]);
        
        
        NSLog(@"The %@ alert's action occured.", result);
    });
}
- (IBAction)showOtherAlert:(id)sender {
    co_launch(^{
        NSString *title = NSLocalizedString(@"A Short Title Is Best", nil);
        NSString *message = NSLocalizedString(@"A message should be a short, complete sentence.", nil);
        NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
        NSString *otherButtonTitleOne = NSLocalizedString(@"Choice One", nil);
        NSString *otherButtonTitleTwo = NSLocalizedString(@"Choice Two", nil);
        
        UIAlertController *alertController = [UIAlertController co_alertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles: otherButtonTitleOne, otherButtonTitleTwo, nil];
        
        NSString *result = await([alertController co_presentFromController:self]);
        
        
        NSLog(@"The %@ alert's action occured.", result);
    });
}
- (IBAction)showTextEntryAlert:(id)sender {
    co_launch(^{
        NSString *title = NSLocalizedString(@"A Short Title Is Best", nil);
        NSString *message = NSLocalizedString(@"A message should be a short, complete sentence.", nil);
        NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
        NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
        
        UIAlertController *alertController = [UIAlertController co_alertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles: otherButtonTitle, nil];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
        }];
        
        NSString *result = await([alertController co_presentFromController:self]);
        
        
        NSLog(@"The %@ alert's action occured.", result);
    });
}
- (IBAction)showOkayCancelActionSheet:(id)sender {
    co_launch(^{
        NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
        NSString *destructiveButtonTitle = NSLocalizedString(@"OK", nil);
        
        UIAlertController *alertController = [UIAlertController co_actionSheetWithTitle:@"test" cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:@"testbutton", nil];
        
        NSString *result = await([alertController co_presentFromController:self]);
        
        
        NSLog(@"The %@ alert's action occured.", result);
    });
}
- (IBAction)showOtherActionSheet:(id)sender {
    co_launch(^{
        NSString *destructiveButtonTitle = NSLocalizedString(@"Destructive Choice", nil);
        NSString *otherButtonTitle = NSLocalizedString(@"Safe Choice", nil);
        UIAlertController *alertController = [UIAlertController co_actionSheetWithTitle:nil cancelButtonTitle:nil destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitle, nil];
        
        NSString *result = await([alertController co_presentFromController:self]);
        
        
        NSLog(@"The %@ alert's action occured.", result);
    });
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
