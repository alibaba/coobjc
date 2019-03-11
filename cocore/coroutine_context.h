//
//  coroutine_context.h
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

#ifndef coroutine_context_h
#define coroutine_context_h

#include <stdio.h>
#import <Foundation/Foundation.h>


#if defined(__arm64__) || defined(__aarch64__)

typedef struct coroutine_ucontext {
    uint64_t data[100];
} coroutine_ucontext_t;

struct coroutine_ucontext_re {
    struct GPRs {
        uint64_t __x[29]; // x0-x28
        uint64_t __fp;    // Frame pointer x29
        uint64_t __lr;    // Link register x30
        uint64_t __sp;    // Stack pointer x31
        uint64_t __pc;    // Program counter
        uint64_t padding; // 16-byte align, for cpsr
    } GR;
    double  VR[32];
};

#elif defined(__ARM_ARCH_7A__) || defined(__ARM_ARCH_7S__)

typedef struct coroutine_ucontext {
    uint32_t data[16];
} coroutine_ucontext_t;

struct coroutine_ucontext_re {
    struct GPRs {
        uint32_t __r[13]; // r0-r12
        uint32_t __sp;    // Stack pointer r13
        uint32_t __lr;    // Link register r14
        uint32_t __pc;    // Program counter r15
    } GR;
};

#elif defined(__i386__)

typedef struct coroutine_ucontext {
    uint32_t data[16];
} coroutine_ucontext_t;


struct coroutine_ucontext_re {
    struct GPRs {
        unsigned int __eax;
        unsigned int __ebx;
        unsigned int __ecx;
        unsigned int __edx;
        unsigned int __edi;
        unsigned int __esi;
        unsigned int __ebp;
        unsigned int __esp;
        unsigned int __ss;
        unsigned int __eflags;
        unsigned int __eip;
        unsigned int __cs;
        unsigned int __ds;
        unsigned int __es;
        unsigned int __fs;
        unsigned int __gs;
    } GR;
};


#elif defined(__x86_64__)

typedef struct coroutine_ucontext {
    uint64_t data[21];
} coroutine_ucontext_t;


struct coroutine_ucontext_re {
    struct GPRs {
        uint64_t __rax;
        uint64_t __rbx;
        uint64_t __rcx;
        uint64_t __rdx;
        uint64_t __rdi;
        uint64_t __rsi;
        uint64_t __rbp;
        uint64_t __rsp;
        uint64_t __r8;
        uint64_t __r9;
        uint64_t __r10;
        uint64_t __r11;
        uint64_t __r12;
        uint64_t __r13;
        uint64_t __r14;
        uint64_t __r15;
        uint64_t __rip;
        uint64_t __rflags;
        uint64_t __cs;
        uint64_t __fs;
        uint64_t __gs;
    } GR;
};

#endif


extern int coroutine_getcontext (coroutine_ucontext_t *__ucp);

extern int coroutine_setcontext (coroutine_ucontext_t *__ucp);
extern int coroutine_begin (coroutine_ucontext_t *__ucp);

extern void coroutine_makecontext (coroutine_ucontext_t *__ucp, IMP func, void *arg, void *stackTop);


#endif /* coroutine_context_h */
