//
//  coroutine.h
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

#ifndef coroutine_h
#define coroutine_h

#include <stdio.h>
#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus
    
    /**
     Define the scheduler of coroutine
     */
    struct coroutine_scheduler;
    
    /**
     Define the coroutine's entry func type
     */
    typedef void (*coroutine_func)(void *);
    
    /**
     The structure store coroutine's context data.
     */
    struct coroutine {
        coroutine_func entry;                   // Process entry.
        void *userdata;                         // Userdata.
        coroutine_func userdata_dispose;        // Userdata's dispose action.
        void *context;                          // Coroutine's Call stack data.
        void *pre_context;                      // Coroutine's source process's Call stack data.
        int status;                             // Coroutine's running status.
        uint32_t stack_size;                    // Coroutine's stack size
        void *stack_memory;                     // Coroutine's stack memory address.
        void *stack_top;                    // Coroutine's stack top address.
        struct coroutine_scheduler *scheduler;  // The pointer to the scheduler.
        int8_t   is_scheduler;                  // The coroutine is a scheduler.
        
        struct coroutine *prev;
        struct coroutine *next;
        
        void *autoreleasepage;                  // If enable autorelease, the custom autoreleasepage.
        bool is_cancelled;                      // The coroutine is cancelled
    };
    typedef struct coroutine coroutine_t;
    
    /**
     Create a new routine.
     
     @param func main entrance
     @return routine obj
     */
    coroutine_t *coroutine_create(coroutine_func func);
    
    
    /**
     Set/Get userdata.

     @param co       coroutine object
     @param userdata userdata pointer
     @param userdata_dispose callback when coroutine free.
     */
    void coroutine_setuserdata(coroutine_t *co, void *userdata, coroutine_func userdata_dispose);
    void *coroutine_getuserdata(coroutine_t *co);
    
    /**
     Close and free a coroutine if dead.

     @param co coroutine object
     */
    void coroutine_close_ifdead(coroutine_t *co);
    
    /**
     Add coroutine to scheduler, and resume the specified coroutine whatever.
     */
    void coroutine_resume(coroutine_t *co);
    
    /**
     Add coroutine to scheduler, and resume the specified coroutine if idle.
     */
    void coroutine_add(coroutine_t *co);
    
    /**
     Yield the specified coroutine now.
     */
    void coroutine_yield(coroutine_t *co);
    
    /**
     Get the current coroutine.

     @return The current coroutine or NULL.
     */
    coroutine_t *coroutine_self(void);
    
    /**
     Define the linked list of scheduler's queue.
     */
    struct coroutine_list {
        coroutine_t *head;
        coroutine_t *tail;
    };
    typedef struct coroutine_list coroutine_list_t;
    
    /**
     Define the scheduler.
     One thread own one scheduler, all coroutine run this thread shares it.
     */
    struct coroutine_scheduler {
        coroutine_t         *main_coroutine;
        coroutine_t         *running_coroutine;
        coroutine_list_t     coroutine_queue;
    };
    typedef struct coroutine_scheduler coroutine_scheduler_t;
    
    /**
     Get the current thread's scheduler.

     @return The scheduler object.
     */
    coroutine_scheduler_t *coroutine_schedule_self(void);
    
#ifdef __cplusplus
}
#endif //__cplusplus

#endif /* coroutine_h */
