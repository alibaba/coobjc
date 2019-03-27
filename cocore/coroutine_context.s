//
//  coroutine_context.s
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

#if defined(__arm64__) || defined(__aarch64__)

.text
.align 2

/**
 Store the current calling stack(registers need to be store) into the memory passed by x0.
 
 This registers need to be saved:
 - x19-x28  Callee-saved registers.
 - x29,x30,sp  Known as fp,lr,sp.
 - d8-d15   Callee-saved vector registers.
 */
.global _coroutine_getcontext
_coroutine_getcontext:
    stp    x18,x19, [x0, #0x090]
    stp    x20,x21, [x0, #0x0A0]
    stp    x22,x23, [x0, #0x0B0]
    stp    x24,x25, [x0, #0x0C0]
    stp    x26,x27, [x0, #0x0D0]
    str    x28, [x0, #0x0E0];
    stp    x29, x30, [x0, #0x0E8];  // fp, lr
    mov    x9,      sp
    str    x9,      [x0, #0x0F8]
    str    x30,     [x0, #0x100]    // store return address as pc
    stp    d8, d9,  [x0, #0x150]
    stp    d10,d11, [x0, #0x160]
    stp    d12,d13, [x0, #0x170]
    stp    d14,d15, [x0, #0x180]
    mov    x0, #0                   
    ret

/**
 Restore the saved calling stack, and resume code at lr.
 
 Difference from coroutine_setcontext:
 Setting lr to 0, to make the calling stack look clean.
 Should be call at first time.
 */
.global _coroutine_begin
_coroutine_begin:
    ldp    x18,x19, [x0, #0x090]
    ldp    x20,x21, [x0, #0x0A0]
    ldp    x22,x23, [x0, #0x0B0]
    ldp    x24,x25, [x0, #0x0C0]
    ldp    x26,x27, [x0, #0x0D0]
    ldp    x28,x29, [x0, #0x0E0]
    ldr    x9,     [x0, #0x100]  // restore pc into lr
    mov    x30,   #0;
    ldr    x1,      [x0, #0x0F8]
    mov    sp,x1                  // restore sp
    ldp    d8, d9,  [x0, #0x150]
    ldp    d10,d11, [x0, #0x160]
    ldp    d12,d13, [x0, #0x170]
    ldp    d14,d15, [x0, #0x180]
    ldp    x0, x1,  [x0, #0x000]  // restore x0,x1
    ret    x9

/**
 Restore the saved calling stack, and resume code at lr.
 */
.global _coroutine_setcontext
_coroutine_setcontext:
    ldp    x18,x19, [x0, #0x090]
    ldp    x20,x21, [x0, #0x0A0]
    ldp    x22,x23, [x0, #0x0B0]
    ldp    x24,x25, [x0, #0x0C0]
    ldp    x26,x27, [x0, #0x0D0]
    ldp    x28,x29, [x0, #0x0E0]
    ldr    x30,     [x0, #0x100]  // restore pc into lr
    ldr    x1,      [x0, #0x0F8]
    mov    sp,x1                  // restore sp
    ldp    d8, d9,  [x0, #0x150]
    ldp    d10,d11, [x0, #0x160]
    ldp    d12,d13, [x0, #0x170]
    ldp    d14,d15, [x0, #0x180]
    ldp    x0, x1,  [x0, #0x000]  // restore x0,x1
    ret    x30

#elif defined(__ARM_ARCH_7A__) || defined(__ARM_ARCH_7S__)

.text
.align 2

/**
 Store the current calling stack(registers need to be store) into the memory passed by r0.
 */
.global _coroutine_getcontext
_coroutine_getcontext:
    add r0, r0, #4*4        // leave space for r0-r3
    stm r0!, {r4-r6}
    stm r0!, {r7}           // r7(fp)
    str r13, [r0, #20];     // store sp
    str r14, [r0, #24]      // store lr
    str r14, [r0, #28]      // store lr as pc
    mov r1, r8
    mov r2, r9
    mov r3, r10
    stm r0!, {r1-r3}
    mov r1, r11
    str r1, [r0, #0]   // r11
    // r12 does not need storing, it it the intra-procedure-call scratch register
    movs r0, #0
    bx   lr

/**
 Restore the saved calling stack, and resume code at lr.
 
 Difference from coroutine_setcontext:
 Setting lr to 0, to make the calling stack look clean.
 Should be call at first time.
 */
.global _coroutine_begin
_coroutine_begin:
    adds r0, #0x20
    ldm r0!, {r1-r4}  // r8-r11
    subs r0, #0x20
    mov r8, r1
    mov r9, r2
    mov r10, r3
    mov r11, r4
    // r12 does not need loading, it it the intra-procedure-call scratch register
    ldr r2, [r0, #0x24]
    ldr r3, [r0, #0x2c]
    mov sp, r2
    mov r1, r3         // restore pc into lr
    mov lr, #0
    ldm r0, {r4-r7}
    ldr r0, [r0, #-0x10];
    bx   r1

/**
 Restore the saved calling stack, and resume code at lr.
 */
.global _coroutine_setcontext
_coroutine_setcontext:
    adds r0, #0x20
    ldm r0!, {r1-r4}  // r8-r11
    subs r0, #0x20
    mov r8, r1
    mov r9, r2
    mov r10, r3
    mov r11, r4
    // r12 does not need loading, it it the intra-procedure-call scratch register
    ldr r2, [r0, #0x24]
    ldr r3, [r0, #0x2c]
    mov sp, r2
    mov lr, r3         // restore pc into lr
    ldm r0, {r4-r7}
    ldr r0, [r0, #-0x10];
    bx   lr

#elif defined(__i386__)

.text
.align 2

/**
 Store the current calling stack(registers need to be store) into the memory passed in the first arg.
 */
.global _coroutine_getcontext
_coroutine_getcontext:
    push  %eax
    movl  8(%esp), %eax
    movl  %ebx,  4(%eax)
    movl  %ecx,  8(%eax)
    movl  %edx, 12(%eax)
    movl  %edi, 16(%eax)
    movl  %esi, 20(%eax)
    movl  %ebp, %ecx       //  fp
    movl  %ecx, 24(%eax)   // store fp
    movl  4(%esp), %edx
    movl  %edx, 40(%eax)  # store return address as eip
    movl  %esp, %ecx
    addl  $8, %ecx         // sp + 8 as sp
    movl  %ecx, 28(%eax)  // store sp
    # skip ss
    # skip eflags
    # skip cs
    # skip ds
    # skip es
    # skip fs
    # skip gs
    movl  (%esp), %edx
    movl  %edx, (%eax)  # store original eax
    popl  %eax
    xorl  %eax, %eax
    ret

/**
 Restore the saved calling stack, and resume code at lr.
 
 In x86, _coroutine_begin is same as _coroutine_setcontext
 */
.global _coroutine_begin
.global _coroutine_setcontext

_coroutine_begin:
_coroutine_setcontext:
    movl   4(%esp), %eax
    # set up eax and ret on new stack location
    movl  28(%eax), %edx # edx holds new stack pointer
    subl  $8,%edx
    movl  %edx, 28(%eax)
    movl  0(%eax), %ebx
    movl  %ebx, 0(%edx)
    movl  40(%eax), %ebx
    movl  %ebx, 4(%edx)
    # we now have ret and eax pushed onto where new stack will be
    # restore all registers
    movl   4(%eax), %ebx
    movl   8(%eax), %ecx
    movl  12(%eax), %edx
    movl  16(%eax), %edi
    movl  20(%eax), %esi
    movl  24(%eax), %ebp
    movl  28(%eax), %esp
    # skip ss
    # skip eflags
    pop    %eax  # eax was already pushed on new stack
    ret

#elif defined(__x86_64__)

.text
.align 2
/**
 Store the current calling stack(registers need to be store) into the memory passed in the first arg.
 */
.global _coroutine_getcontext
_coroutine_getcontext:
    movq  %rax,   (%rdi)
    movq  %rbx,  8(%rdi)
    movq  %rcx, 16(%rdi)
    movq  %rdx, 24(%rdi)
    movq  %rdi, 32(%rdi)
    movq  %rsi, 40(%rdi)
    movq  %rbp, 48(%rdi)        // pre fp store
    movq  %rsp, 56(%rdi)
    addq  $8,   56(%rdi)        // sp
    movq  %r8,  64(%rdi)
    movq  %r9,  72(%rdi)
    movq  %r10, 80(%rdi)
    movq  %r11, 88(%rdi)
    movq  %r12, 96(%rdi)
    movq  %r13,104(%rdi)
    movq  %r14,112(%rdi)
    movq  %r15,120(%rdi)
    movq  (%rsp), %rsi          //  lr
    movq  %rsi, 128(%rdi)
    # skip rflags
    # skip cs
    # skip fs
    # skip gs
    xorl  %eax, %eax
    ret

/**
 Restore the saved calling stack, and resume code at lr.
 
 In x86, _coroutine_begin is same as _coroutine_setcontext
 */
.global _coroutine_begin
.global _coroutine_setcontext

_coroutine_begin:
_coroutine_setcontext:
    movq  56(%rdi), %rax # rax holds new stack pointer
    subq  $16, %rax
    movq  %rax, 56(%rdi)
    movq  32(%rdi), %rbx  # store new rdi on new stack
    movq  %rbx, 0(%rax)
    movq  128(%rdi), %rbx # store new rip on new stack
    movq  %rbx, 8(%rax)
    # restore all registers
    movq    0(%rdi), %rax
    movq    8(%rdi), %rbx
    movq   16(%rdi), %rcx
    movq   24(%rdi), %rdx
    # restore rdi later
    movq   40(%rdi), %rsi
    movq   48(%rdi), %rbp
    # restore rsp later
    movq   64(%rdi), %r8
    movq   72(%rdi), %r9
    movq   80(%rdi), %r10
    movq   88(%rdi), %r11
    movq   96(%rdi), %r12
    movq  104(%rdi), %r13
    movq  112(%rdi), %r14
    movq  120(%rdi), %r15
    # skip rflags
    # skip cs
    # skip fs
    # skip gs
    movq  56(%rdi), %rsp  # cut back rsp to new location
    pop    %rdi      # rdi was saved here earlier
    ret            # rip was saved here

#endif
