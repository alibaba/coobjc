//
//  coroutine_context.m
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

#import "coroutine_context.h"
#import "coroutine.h"

#if defined(__arm64__) || defined(__aarch64__)


void coroutine_makecontext (coroutine_ucontext_t *ctx, IMP func, void *arg, void *stackTop)
{
    struct coroutine_ucontext_re *uctx = (struct coroutine_ucontext_re *)ctx;
    uintptr_t stackBegin = (uintptr_t)stackTop - sizeof(uintptr_t);
    uctx->GR.__fp = stackBegin;
    uctx->GR.__sp = stackBegin;
    uctx->GR.__x[0] = (uintptr_t)arg;
    uctx->GR.__pc = (uintptr_t)func;
}

#elif defined(__ARM_ARCH_7A__) || defined(__ARM_ARCH_7S__)

void coroutine_makecontext (coroutine_ucontext_t *ctx, IMP func, void *arg, void *stackTop)
{
    struct coroutine_ucontext_re *uctx = (struct coroutine_ucontext_re *)ctx;
    uintptr_t stackBegin = (uintptr_t)stackTop - sizeof(uintptr_t);
    uctx->GR.__r[7] = stackBegin;
    uctx->GR.__sp = stackBegin;
    uctx->GR.__r[0] = (uintptr_t)arg;
    uctx->GR.__pc = (uintptr_t)func;
}

#elif defined(__i386__)

void coroutine_makecontext (coroutine_ucontext_t *ctx, IMP func, void *arg, void *stackTop)
{
    struct coroutine_ucontext_re *uctx = (struct coroutine_ucontext_re *)ctx;
    uintptr_t stackBegin = (uintptr_t)stackTop - sizeof(uintptr_t);
    uctx->GR.__ebp = stackBegin;
    uctx->GR.__esp = stackBegin - 5 * sizeof(uintptr_t); // start sp must end withs with 0xc, to make the sp align with 16 Byte at the process entry, or will crash at objc_msgSend_uncached
    *(uintptr_t *)(uctx->GR.__esp + 4) = (uintptr_t)arg;
    uctx->GR.__eip = (uintptr_t)func;
}

#elif defined(__x86_64__)

void coroutine_makecontext (coroutine_ucontext_t *ctx, IMP func, void *arg, void *stackTop)
{
    struct coroutine_ucontext_re *uctx = (struct coroutine_ucontext_re *)ctx;
    uintptr_t stackBegin = (uintptr_t)stackTop - sizeof(uintptr_t);
    uctx->GR.__rbp = stackBegin;
    uctx->GR.__rsp = stackBegin- 3 * sizeof(uintptr_t); // start sp must end withs with 0xc, to make the sp align with 16 Byte at the process entry, or will crash at objc_msgSend_uncached
    uctx->GR.__rdi = (uintptr_t)arg;
    uctx->GR.__rip = (uintptr_t)func;
}
#endif
