//
//  co_queuedebugging_support.c
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

#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <mach-o/dyld.h>
#include <mach-o/loader.h>
#include <mach-o/nlist.h>
#include <execinfo.h>
#include "coroutine.h"
#import <Foundation/Foundation.h>
#include <mach/vm_types.h>
#import "cofishhook.h"
#include <sys/sysctl.h>


#if defined(__i386__) || defined(__x86_64__) || defined(__arm__) || defined(__arm64__)
#define FP_LINK_OFFSET 1
#else
#error ********** Unimplemented architecture
#endif

#if defined(__x86_64__)
#define    ISALIGNED(a)    ((((uintptr_t)(a)) & 0xf) == 0)
#elif defined(__i386__)
#define    ISALIGNED(a)    ((((uintptr_t)(a)) & 0xf) == 8)
#elif defined(__arm__) || defined(__arm64__)
#define    ISALIGNED(a)    ((((uintptr_t)(a)) & 0x1) == 0)
#endif

static void
_co_thread_stack_pcs(vm_address_t *buffer, unsigned max, unsigned *nb,
                  unsigned skip, void *startfp)
{
    void *frame, *next;
    
    *nb = 0;
    
    frame = __builtin_frame_address(0);
    if(!ISALIGNED(frame))
        return;
    while ((startfp && startfp >= *(void **)frame) || skip--) {
        next = *(void **)frame;
        if(!ISALIGNED(next) || next <= frame)
            return;
        frame = next;
    }
    while (max--) {
        void *retaddr = (void *)*(vm_address_t *)
        (((void **)frame) + FP_LINK_OFFSET);
        if (retaddr == 0) {
            return;
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wint-conversion"
        buffer[*nb] = retaddr;
#pragma clang diagnostic pop
        (*nb)++;
        next = *(void **)frame;
        if(!ISALIGNED(next) || next <= frame)
            return;
        frame = next;
    }
}

static int (*orig_backtrace)(void** buffer, int size);


int co_backtrace(void** buffer, int size) {
    if (coroutine_self()) {
        unsigned int num_frames;
        _co_thread_stack_pcs((vm_address_t*)buffer, size, &num_frames, 1, NULL);
        while (num_frames >= 1 && buffer[num_frames-1] == NULL) num_frames -= 1;
        return num_frames;
    } else {
        return orig_backtrace(buffer, size);
    }
}

static BOOL co_isDebuggerAttached() {
    static BOOL debuggerIsAttached = NO;
    
    struct kinfo_proc info;
    size_t info_size = sizeof(info);
    int name[4];
    
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = getpid(); // from unistd.h, included by Foundation
    
    if (sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
        NSLog(@"[HockeySDK] ERROR: Checking for a running debugger via sysctl() failed: %s", strerror(errno));
        debuggerIsAttached = false;
    }
    
    if (!debuggerIsAttached && (info.kp_proc.p_flag & P_TRACED) != 0) {
        debuggerIsAttached = true;
    }
    
    return debuggerIsAttached;
}



void co_rebind_backtrace(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (co_isDebuggerAttached()) {
            co_rebind_symbols((struct rebinding[1]){{"backtrace", co_backtrace, (void *)&orig_backtrace}}, 1);
        }
    });
}

