//
//  NSBundle+Coroutine.h
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
#import <coobjc/coobjc.h>

@interface NSBundle (COPromise)

// the coroutine wrap of loadAndReturnError method
// usage:
//co_launch(^{
//    BOOL ret = [await([bundle async_load]) boolValue];
//    if(!ret){
//        NSError *error = co_getError();
//        NSLog(@"load error: %@", error);
//    }
//});
- (COPromise<NSNumber*>*)async_load;

@end

@interface NSBundle (Coroutine)

// the coroutine wrap of loadAndReturnError method
// usage:
//co_launch(^{
//    NSError *error = nil;
//    BOOL ret = [bundle co_loadAndReturnError:&error];
//    if(!ret){
//
//        NSLog(@"load error: %@", error);
//    }
//});
- (BOOL)co_loadAndReturnError:(NSError **)error CO_ASYNC;

@end
