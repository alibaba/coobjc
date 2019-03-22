//
//  co_queue.c
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

#include "co_queue.h"
#import <pthread/pthread.h>
#import <mach/mach.h>


dispatch_queue_t co_get_current_queue() {
    if ([NSThread isMainThread]) {
        return dispatch_get_main_queue();
    }
    thread_identifier_info_data_t tiid;
    thread_t thread = mach_thread_self();
    mach_msg_type_number_t cnt = THREAD_IDENTIFIER_INFO_COUNT;
    kern_return_t kr = thread_info(thread,
                                   THREAD_IDENTIFIER_INFO, (thread_info_t)&tiid, &cnt);
    if (kr == KERN_SUCCESS) {
        ptrdiff_t thread_queue_offset = (ptrdiff_t)(tiid.dispatch_qaddr - thread);
        
        if (thread_queue_offset == 0) {
            return nil;
        }
        else{
            __unsafe_unretained dispatch_queue_t *qptr = (__unsafe_unretained dispatch_queue_t *)(void*)(thread + thread_queue_offset);
            return *qptr;
        }
    }
    return NULL;
}

BOOL co_is_current_queue_equal(dispatch_queue_t q){
    if ([NSThread isMainThread]) {
        return dispatch_get_main_queue() == q;
    }
    thread_identifier_info_data_t tiid;
    thread_t thread = mach_thread_self();
    mach_msg_type_number_t cnt = THREAD_IDENTIFIER_INFO_COUNT;
    kern_return_t kr = thread_info(thread,
                                   THREAD_IDENTIFIER_INFO, (thread_info_t)&tiid, &cnt);
    if (kr == KERN_SUCCESS) {
        ptrdiff_t thread_queue_offset = (ptrdiff_t)(tiid.dispatch_qaddr - thread);
        
        if (thread_queue_offset == 0) {
            return NO;
        }
        else{
            void *qptr = *((void**)(void*)(thread + thread_queue_offset));
            void *originptr = (__bridge void*)q;
            return originptr == qptr;
        }
    }
    return NO;
}
