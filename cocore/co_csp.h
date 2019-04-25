//
//  co_csp.h
//  coobjc
//
//  Copyright © 2018 Alibaba Group Holding Limited All rights reserved.
//  Copyright (c) 2005-2007 Russ Cox, Massachusetts Institute of Technology
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
//
//  **
//  Reference code from [libtask](https://swtch.com/libtask/)

#ifndef co_csp_h
#define co_csp_h
#include <stdio.h>
#include <cocore/coroutine.h>

/**
 Define the channel's op code.  send/receive.
 */
typedef enum {
    CHANNEL_SEND = 1,
    CHANNEL_RECEIVE,
} channel_op;

enum channel_errorno {
    CHANNEL_ALT_SUCCESS = 1,
    CHANNEL_ALT_ERROR_COPYFAIL    = 0,
    CHANNEL_ALT_ERROR_CANCELLED   = -1,     // cancel the current alt.
    CHANNEL_ALT_ERROR_BUFFER_FULL = -2,     // no buffer remain, send_nonblock fail
    CHANNEL_ALT_ERROR_NO_VALUE    = -3,     // receive_nonblock fail
};

typedef struct chan_alt chan_alt;
typedef struct chan_queue chan_queue;
typedef struct co_channel co_channel;
typedef struct alt_queue alt_queue;

/**
 Define the chan alt, record a send/receive context.
 */
struct chan_alt
{
    co_channel          *channel;
    void                *value;
    coroutine_t         *task;
    chan_alt            *prev;
    chan_alt            *next;
    IMP                 custom_exec;
    IMP                 cancel_exec;
    channel_op          op;
    int                 can_block;
    bool                is_cancelled;
};

struct alt_queue
{
    chan_alt        *head;
    chan_alt        *tail;
    unsigned int    count;
};

/**
 Define the queue used by channel.
 */
struct chan_queue
{
    void            *arr;
    unsigned int    elemsize;
    unsigned int    size;
    unsigned int    head;
    unsigned int    tail;
    unsigned int    count;
    unsigned int    expandsize;
};

/**
 Define the channel struct
 */
struct co_channel {
    chan_queue    buffer;
    alt_queue     asend;
    alt_queue     arecv;
    pthread_mutex_t  lock;
    void (*custom_resume)(coroutine_t *co);
};

/**
 Create a channel object.

 @param elemsize the element's size
 @param bufsize buffer size
 @return the channel object.
 */
co_channel *chancreate(int elemsize, int bufsize, void (*custom_resume)(coroutine_t *co));

/**
 Free a channel.

 @param chan channel object.
 */
void chanfree(co_channel *chan);

/**
 Non-blocking receive from channel.

 @param c channel
 @param v the pointer will store received value.
 @return channel_errorno
 */
int channbrecv(co_channel *c, void *v);

/**
 Non-blocking receive a pointer value from channel.

 @param c channel
 @return received pointer value, default NULL.
 */
void *channbrecvp(co_channel *c);

/**
 Non-blocking receive a unsigned long value from channel.

 @param c channel
 @return received unsigned long value, default 0.
 */
unsigned long channbrecvul(co_channel *c);

/**
 Non-blocking send value to channel.

 @param c channel
 @param v the value's address.
 @return channel_errorno
 */
int channbsend(co_channel *c, void *v);

/**
 Non-blocking send a pointer value to channel.

 @param c channel
 @param v the pointer
 @return channel_errorno
 */
int channbsendp(co_channel *c, void *v);

/**
 Non-blocking send a unsigned long value to channel.
 
 @param c channel
 @param v the unsigned long value
 @return channel_errorno
 */
int channbsendul(co_channel *c, unsigned long v);

/**
 Blocking receive from channel.
 
 If no one sending, and buffer is empty, blocking the current coroutine.
 
 @param c channel
 @param v the pointer will store received value.
 @return channel_errorno
 */
int chanrecv(co_channel *c, void *v);

/**
 Blocking receive a pointer value from channel.
 
 If no one sending, and buffer is empty, blocking the current coroutine.
 
 @param c channel
 @return received pointer, default NULL.
 */
void *chanrecvp(co_channel *c);

/**
 Blocking receive a unsigned long value from channel.
 
 If no one sending, and buffer is empty, blocking the current coroutine.
 
 @param c channel
 @return received unsigned long value, default 0.
 */
unsigned long chanrecvul(co_channel *c);

/**
 Blocking send value to channel.
 
 If no one sending, and buffer is empty, blocking the current coroutine.
 
 @param c channel
 @param v the pointer will store received value.
 @return channel_errorno
 */
int chansend(co_channel *c, void *v);

/**
 Blocking send a pointer value to channel.
 
 @param c channel
 @param v the pointer
 @return channel_errorno
 */
int chansendp(co_channel *c, void *v);

/**
 Blocking send a unsigned long value to channel.
 
 @param c channel
 @param v the unsigned long value
 @return channel_errorno
 */
int chansendul(co_channel *c, unsigned long v);

/**
 If a channel is blocking a coroutine, using this method
 to cancel the blocking.

 @param co the coroutine object
 @return channel_errorno
 */
int chan_cancel_alt_in_co(coroutine_t *co);

/**
 Blocking send value to channel.
 
 If no one sending, and buffer is empty, blocking the current coroutine.
 
 @param c channel
 @param v the pointer pass the send value.
 @param exec  run at sending.
 @param cancelExec run at cancel a alt.
 @return channel_errorno
 */
int chansend_custom_exec(co_channel *c, void *v, IMP exec, IMP cancelExec);

/**
 Non-blocking send value to channel.
 
 @param c channel
 @param v the value's address.
 @param exec  run at sending.
 @return channel_errorno
 */
int channbsend_custom_exec(co_channel *c, void *v, IMP exec);

/**
 Blocking receive value to channel.
 
 If no one sending, and buffer is empty, blocking the current coroutine.
 
 @param c channel
 @param v the pointer will store received value.
 @param cancelExec run at cancel a alt.
 @return channel_errorno
 */
int chanrecv_custom_exec(co_channel *c, void *v, IMP cancelExec);

#endif
