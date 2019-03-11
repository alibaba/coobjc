//
//  coroutine.c
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

#include "coroutine.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stddef.h>
#include <string.h>
#include <stdint.h>
#include "coroutine_context.h"
#import <pthread/pthread.h>
#import <mach/mach.h>
#import "co_queuedebugging_support.h"


#define COROUTINE_DEAD 0
#define COROUTINE_READY 1
#define COROUTINE_RUNNING 2
#define COROUTINE_SUSPEND 3


#define STACK_SIZE      (64*1024)
#define DEFAULT_COROUTINE_COUNT     64

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"


void scheduler_queue_push(coroutine_scheduler_t *scheduler, coroutine_t *co);
coroutine_t *scheduler_queue_pop(coroutine_scheduler_t *scheduler);
coroutine_scheduler_t *coroutine_scheduler_new(void);
void coroutine_scheduler_free(coroutine_scheduler_t *schedule);
void coroutine_resume_im(coroutine_t *co);
void *coroutine_memory_malloc(size_t s);
void  coroutine_memory_free(void *ptr, size_t size);

static pthread_key_t coroutine_scheduler_key = 0;

void *coroutine_memory_malloc(size_t s) {
    vm_address_t address;
    
    vm_size_t size = s;
    kern_return_t ret = vm_allocate((vm_map_t)mach_task_self(), &address, size,  VM_MAKE_TAG(VM_MEMORY_STACK) | VM_FLAGS_ANYWHERE);
    if ( ret != ERR_SUCCESS ) {
        return NULL;
    }
    return (void *)address;
}

void  coroutine_memory_free(void *ptr, size_t size) {
    if (ptr) {
        vm_deallocate((vm_map_t)mach_task_self(), (vm_address_t)ptr, size);
    }
}

coroutine_scheduler_t *coroutine_scheduler_self(void) {
    
    if (!coroutine_scheduler_key) {
        pthread_key_create(&coroutine_scheduler_key, coroutine_scheduler_free);
    }
    
    void *schedule = pthread_getspecific(coroutine_scheduler_key);
    return schedule;
}

coroutine_scheduler_t *coroutine_scheduler_self_create_if_not_exists(void) {
    
    if (!coroutine_scheduler_key) {
        pthread_key_create(&coroutine_scheduler_key, coroutine_scheduler_free);
    }
    
    void *schedule = pthread_getspecific(coroutine_scheduler_key);
    if (!schedule) {
        schedule = coroutine_scheduler_new();
        pthread_setspecific(coroutine_scheduler_key, schedule);
    }
    return schedule;
}

void coroutine_scheduler_main(coroutine_t *scheduler_co) {
    
    coroutine_scheduler_t *scheduler = scheduler_co->scheduler;
    for (;;) {
        
        // pop a coroutine from queue.head.
        coroutine_t *co = scheduler_queue_pop(scheduler);
        if (co == NULL) {
            // jump out. scheduler will enter idle.
            coroutine_yield(scheduler_co);
            continue;
        }
        // set scheduler's current running coroutine.
        scheduler->running_coroutine = co;
        // resume the coroutine
        coroutine_resume_im(co);
        
        // scheduler's current running coroutine.
        scheduler->running_coroutine = nil;
        
        // if coroutine finished, free coroutine.
        if (co->status == COROUTINE_DEAD) {
            coroutine_close_ifdead(co);
        }
    }
}

coroutine_scheduler_t *coroutine_scheduler_new(void) {
    
    coroutine_scheduler_t *scheduler = calloc(1, sizeof(coroutine_scheduler_t));
    coroutine_t *co = coroutine_create((void(*)(void *))coroutine_scheduler_main);
    co->stack_size = 16 * 1024; // scheduler does not need so much stack memory.
    scheduler->main_coroutine = co;
    co->scheduler = scheduler;
    co->is_scheduler = true;
    return scheduler;
}

void coroutine_scheduler_free(coroutine_scheduler_t *schedule) {
    coroutine_close_ifdead(schedule->main_coroutine);
}

coroutine_t *coroutine_create(coroutine_func func) {
    coroutine_t *co = calloc(1, sizeof(coroutine_t));
    co->entry = func;
    co->stack_size = STACK_SIZE;
    co->status = COROUTINE_READY;
    
    // check debugger is attached, fix queue debugging.
    co_rebind_backtrace();
    return co;
}


void coroutine_setuserdata(coroutine_t* co, void* userdata, coroutine_func ud_dispose) {
    if (co->userdata && co->userdata_dispose) {
        co->userdata_dispose(co->userdata);
    }
    co->userdata = userdata;
    co->userdata_dispose = ud_dispose;
}

void *coroutine_getuserdata(coroutine_t* co) {
    
    return co->userdata;
}

void coroutine_close(coroutine_t *co) {
    
    coroutine_setuserdata(co, nil, nil);
    if (co->stack_memory) {
        coroutine_memory_free(co->stack_memory, co->stack_size);
    }
    free(co->context);
    free(co->pre_context);
    free(co);
}

void coroutine_close_ifdead(coroutine_t *co) {
    
    if (co->status == COROUTINE_DEAD) {
        coroutine_close(co);
    }
}

static void coroutine_main(coroutine_t *co) {
    co->status = COROUTINE_RUNNING;
    co->entry(co);
    co->status = COROUTINE_DEAD;
    coroutine_setcontext(co->pre_context);
}

// use optnone to keep the `skip` not be optimized.
__attribute__ ((optnone))
void coroutine_resume_im(coroutine_t *co) {
    switch (co->status) {
        case COROUTINE_READY:
        {
            co->stack_memory = coroutine_memory_malloc(co->stack_size);
            co->stack_top = co->stack_memory + co->stack_size - 3 * sizeof(void *);
            // get the pre context
            co->pre_context = malloc(sizeof(coroutine_ucontext_t));
            BOOL skip = false;
            coroutine_getcontext(co->pre_context);
            if (skip) {
                // when proccess reenter(resume a coroutine), skip the remain codes, just return to pre func.
                return;
            }
#pragma unused(skip)
            skip = true;
            
            free(co->context);
            co->context = calloc(1, sizeof(coroutine_ucontext_t));
            coroutine_makecontext(co->context, (IMP)coroutine_main, co, (void *)co->stack_top);
            // setcontext
            coroutine_begin(co->context);
            
            break;
        }
        case COROUTINE_SUSPEND:
        {
            BOOL skip = false;
            coroutine_getcontext(co->pre_context);
            if (skip) {
                // when proccess reenter(resume a coroutine), skip the remain codes, just return to pre func.
                return;
            }
#pragma unused(skip)
            skip = true;
            // setcontext
            coroutine_setcontext(co->context);
            
            break;
        }
        default:
            assert(false);
            break;
    }
}

void coroutine_resume(coroutine_t *co) {
    if (!co->is_scheduler) {
        coroutine_scheduler_t *scheduler = coroutine_scheduler_self_create_if_not_exists();
        co->scheduler = scheduler;
        
        scheduler_queue_push(scheduler, co);
        
        if (scheduler->running_coroutine) {
            // resume a sub coroutine.
            scheduler_queue_push(scheduler, scheduler->running_coroutine);
            coroutine_yield(scheduler->running_coroutine);
        } else {
            // scheduler is idle
            coroutine_resume_im(co->scheduler->main_coroutine);
        }
    }
}

void coroutine_add(coroutine_t *co) {
    if (!co->is_scheduler) {
        coroutine_scheduler_t *scheduler = coroutine_scheduler_self_create_if_not_exists();
        co->scheduler = scheduler;
        if (scheduler->main_coroutine->status == COROUTINE_DEAD) {
            coroutine_close_ifdead(scheduler->main_coroutine);
            coroutine_t *main_co = coroutine_create(coroutine_scheduler_main);
            main_co->is_scheduler = true;
            main_co->scheduler = scheduler;
            scheduler->main_coroutine = main_co;
        }
        scheduler_queue_push(scheduler, co);
        
        if (!scheduler->running_coroutine) {
            coroutine_resume_im(co->scheduler->main_coroutine);
        }
    }
}

// use optnone to keep the `skip` not be optimized.
__attribute__ ((optnone))
void coroutine_yield(coroutine_t *co)
{
    if (co == NULL) {
        // if null
        co = coroutine_self();
    }
    BOOL skip = false;
    coroutine_getcontext(co->context);
    if (skip) {
        return;
    }
#pragma unused(skip)
    skip = true;
    co->status = COROUTINE_SUSPEND;
    coroutine_setcontext(co->pre_context);
}

coroutine_t *coroutine_self() {
    coroutine_scheduler_t *schedule = coroutine_scheduler_self();
    if (schedule) {
        return schedule->running_coroutine;
    } else {
        return nil;
    }
}

#pragma mark - linked lists

void scheduler_queue_push(coroutine_scheduler_t *scheduler, coroutine_t *co) {
    coroutine_list_t *queue = &scheduler->coroutine_queue;
    if(queue->tail) {
        queue->tail->next = co;
        co->prev = queue->tail;
    } else {
        queue->head = co;
        co->prev = nil;
    }
    queue->tail = co;
    co->next = nil;
}

coroutine_t *scheduler_queue_pop(coroutine_scheduler_t *scheduler) {
    coroutine_list_t *queue = &scheduler->coroutine_queue;
    coroutine_t *co = queue->head;
    if (co) {
        queue->head = co->next;
        // Actually, co->prev is nil now.
        if (co->next) {
            co->next->prev = co->prev;
        } else {
            queue->tail = co->prev;
        }
    }
    return co;
}

#pragma clang diagnostic pop

