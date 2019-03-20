//
//  co_queue.h
//  coobjc
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

#ifndef co_queue_h
#define co_queue_h

#include <stdio.h>
#import <Foundation/Foundation.h>

/**
 Get the current dispatch_queue_t.
 This is a replacement of `dispatch_get_current_queue()`, since which is deprecated.
 This method may return nil.

 @return The current dispatch_queue.
 */
dispatch_queue_t co_get_current_queue(void);

/**
 check the current queue is equal to q.
 
 @return YES if the current queue is equal to q, NO ifthe current queue is not equal to q
 */
BOOL co_is_current_queue_equal(dispatch_queue_t q);

#endif /* co_queue_h */
