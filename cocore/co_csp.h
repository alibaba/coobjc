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


typedef struct chan_alt chan_alt;
typedef struct chan_queue chan_queue;
typedef struct co_channel co_channel;

/**
 Define the chan alt, record a send/receive context.
 */
struct chan_alt
{
    co_channel          *channel;
    void                *value;
    coroutine_t         *task;
    channel_op          op;
    int                 can_block;
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
    chan_queue    asend;
    chan_queue    arecv;
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
 @return 1 success, else fail.
 */
int channbrecv(co_channel *c, void *v);

/**
 Non-blocking receive a pointer value from channel.

 @param c channel
 @return received pointer value.
 */
void *channbrecvp(co_channel *c);

/**
 Non-blocking receive a unsigned long value from channel.

 @param c channel
 @return received unsigned long value.
 */
unsigned long channbrecvul(co_channel *c);

/**
 Non-blocking send value to channel.

 @param c channel
 @param v the value's address.
 @return 1 success, else fail.
 */
int channbsend(co_channel *c, void *v);

/**
 Non-blocking send a pointer value to channel.

 @param c channel
 @param v the pointer
 @return 1 success, else fail.
 */
int channbsendp(co_channel *c, void *v);

/**
 Non-blocking send a unsigned long value to channel.
 
 @param c channel
 @param v the unsigned long value
 @return 1 success, else fail.
 */
int channbsendul(co_channel *c, unsigned long v);

/**
 Blocking receive from channel.
 
 If no one sending, and buffer is empty, blocking the current coroutine.
 
 @param c channel
 @param v the pointer will store received value.
 @return 1 success, else fail.
 */
int chanrecv(co_channel *c, void *v);

/**
 Blocking receive a pointer value from channel.
 
 If no one sending, and buffer is empty, blocking the current coroutine.
 
 @param c channel
 @return received pointer.
 */
void *chanrecvp(co_channel *c);

/**
 Blocking receive a unsigned long value from channel.
 
 If no one sending, and buffer is empty, blocking the current coroutine.
 
 @param c channel
 @return received unsigned long value.
 */
unsigned long chanrecvul(co_channel *c);

/**
 Blocking send value to channel.
 
 If no one sending, and buffer is empty, blocking the current coroutine.
 
 @param c channel
 @param v the pointer will store received value.
 @return 1 success, else fail.
 */
int chansend(co_channel *c, void *v);

/**
 Blocking send a pointer value to channel.
 
 @param c channel
 @param v the pointer
 @return 1 success, else fail.
 */
int chansendp(co_channel *c, void *v);

/**
 Blocking send a unsigned long value to channel.
 
 @param c channel
 @param v the unsigned long value
 @return 1 success, else fail.
 */
int chansendul(co_channel *c, unsigned long v);

/**
 Blocking send a int8_t value to channel.
 
 @param c channel
 @param val the int8 value
 @return 1 success, else fail.
 */
int chansendi8(co_channel *c, int8_t val);

/**
 Blocking receive a int8_t value from channel.
 
 If no one sending, and buffer is empty, blocking the current coroutine.
 
 @param c channel
 @return received int8_t value.
 */
int8_t chanrecvi8(co_channel *c);

/**
 Non-blocking send a int8_t value to channel.
 
 @param c channel
 @param val the int8_t value
 @return 1 success, else fail.
 */
int channbsendi8(co_channel *c, int8_t val);

/**
 Non-blocking receive a int8_t value from channel.
 
 @param c channel
 @return received int8_t value.
 */
int8_t channbrecvi8(co_channel *c);

/**
 Get the blocking task count.
 */
int changetblocking(co_channel *c, int *sendBlockingCount, int *receiveBlockingCount);

#endif
