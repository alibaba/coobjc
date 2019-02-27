//
//  COKitCommon.h
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

// cokit common interface
@interface COKitCommon : NSObject

// common io queue for read from disk
+ (dispatch_queue_t)io_queue;

+ (dispatch_queue_t)image_queue;


// common io queue for write to disk
+ (dispatch_queue_t)io_write_queue;

// common queue for NSFileManager operation
+ (dispatch_queue_t)filemanager_queue;

// common queue for json operation
+ (dispatch_queue_t)json_queue;

// common queue for NSKeyedArchieve or NSKeyedUnArchieve Operation
+ (dispatch_queue_t)archieve_queue;

// common queue for NSURLConnection operation
+ (NSOperationQueue*)urlconnection_queue;

// common queue for NSUserDefaults operation
+ (dispatch_queue_t)userDefaults_queue;

// run block on queue
+ (void)runBlock:(dispatch_block_t)block
         onQueue:(dispatch_queue_t)queue;

// run block on current background queue or on the specify queue
+ (void)runBlockOnBackgroundThread:(dispatch_block_t)block
                   backgroundQueue:(dispatch_queue_t)queue;

@end
