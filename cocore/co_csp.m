//
//  co_csp.m
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

#import "co_csp.h"
#import <dispatch/dispatch.h>
#include <pthread/pthread.h>

#pragma mark - queue

static void chancancelallalt(co_channel *c);

static void amove(void *dst, void *src, uint n) {
    if(dst){
        if(src == nil) {
            memset(dst, 0, n);
        } else {
            memmove(dst, src, n);
        }
    }
}

static void queueinit(chan_queue *q, int elemsize, int bufsize, int expandsize, void *buf) {
    q->elemsize = elemsize;
    q->size = bufsize;
    q->expandsize = expandsize;
    
    if (expandsize) {
        if (bufsize > 0) {
            q->arr = malloc(bufsize * elemsize);
        }
    } else {
        if (buf) {
            q->arr = buf;
        }
    }
}

static int queuepush(chan_queue *q, void *element)
{
    if (q->count == q->size) {
        
        if (q->expandsize) {
            // expand buffer, example:
            //   ⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽
            //  |█ █ █ █ _ _ _ _ █ █ █ █ |    size=12, count=8, head=4, tail=8;
            //   ⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺
            //            ↓
            //   ⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽
            //  |█ █ █ █ _ _ _ _ _ _ _ _ █ █ █ █ |    size=16, count=8, head=4, tail=12;
            //   ⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺
            size_t oldsize = q->size;
            q->size += q->expandsize;
            q->arr = realloc(q->arr, q->size * q->elemsize);
            
            if (q->head <= q->tail) {
                void *copyaddr = q->arr + q->tail * q->elemsize;
                void *destaddr = copyaddr + q->expandsize * q->elemsize;
                size_t copysize = (oldsize - q->tail) * q->elemsize;
                memmove(destaddr, copyaddr, copysize);
                q->tail += q->expandsize;
            }
            
        } else {
            // fail
            return 0;
        }
    }
    
    amove(q->arr + q->head * q->elemsize, element, q->elemsize);
    q->head = (q->head + 1) % q->size;
    q->count ++;
    return 1;
}

static int queuepop(chan_queue *q, void *val) {
    
    if (q->count > 0) {
        
        amove(val, q->arr + q->tail * q->elemsize, q->elemsize);
        q->tail = (q->tail + 1) % q->size;
        q->count--;
        return 1;
    } else {
        return 0;
    }
}

#pragma mark - altqueue

static int altqueuepush(alt_queue *q, chan_alt *alt) {
    if (!alt) {
        return 0;
    }
    if (q->head) {
        alt->next = q->head;
        q->head->prev = alt;
        q->head = alt;
    } else {
        q->head = alt;
    }
    
    if (!q->tail) {
        q->tail = alt;
    }
    q->count++;
    return 1;
}

static int altqueuepop(alt_queue *q, chan_alt **alt) {
    if (q->tail) {
        *alt = q->tail;
        
        chan_alt *prev = q->tail->prev;
        if (prev) {
            prev->next = NULL;
            q->tail->prev = NULL;
            q->tail = prev;
        } else {
            q->head = NULL;
            q->tail = NULL;
        }
        q->count--;
        return 1;
    }
    return 0;
}

static int altqueueremove(alt_queue *q, chan_alt *alt) {
    if (!alt) {
        return 0;
    }
    
    chan_alt *prev = alt->prev;
    chan_alt *next = alt->next;
    
    if (prev) {
        prev->next = next;
    }
    if (next) {
        next->prev = prev;
    }
    
    if (q->head == alt) {
        q->head = next;
    }
    if (q->tail == alt) {
        q->tail = prev;
    }
    q->count--;
    return 1;
}

#pragma mark - channel

co_channel *chancreate(int elemsize, int bufsize, void (*custom_resume)(coroutine_t *co)) {
    
    co_channel *c;
    if (bufsize < 0) {
        c = calloc(1, sizeof(co_channel));
    } else {
        c = calloc(1, (sizeof(co_channel) + bufsize*elemsize));
    }
    
    // init buffer
    if (bufsize < 0) {
        queueinit(&c->buffer, elemsize, 16, 16, NULL);
    } else {
        queueinit(&c->buffer, elemsize, bufsize, 0, (void *)(c+1));
    }
    
    // init lock
    c->lock = (pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER;
    
    c->custom_resume = custom_resume;

    return c;
}

void chanfree(co_channel *c) {
    
    if(c == nil) {
        return;
    }
    chancancelallalt(c);
    if (c->buffer.expandsize) {
        free(c->buffer.arr);
    }
    pthread_mutex_destroy(&c->lock);
    free(c);
}

static void chanlock(co_channel *c) {
    pthread_mutex_lock(&c->lock);
}

static void chanunlock(co_channel *c) {
    pthread_mutex_unlock(&c->lock);
}

#define otherop(op)    (CHANNEL_SEND+CHANNEL_RECEIVE-(op))

static alt_queue *chanarray(co_channel *c, uint op) {
    switch(op){
        default:
            return nil;
        case CHANNEL_SEND:
            return &c->asend;
        case CHANNEL_RECEIVE:
            return &c->arecv;
    }
}

static int altcanexec(chan_alt *a) {
    alt_queue *altqueue;
    co_channel *c;
    
    c = a->channel;
    if(c->buffer.size == 0){
        altqueue = chanarray(c, otherop(a->op));
        return altqueue && altqueue->count;
    } else if (c->buffer.expandsize) {
        // expandable buffer
        switch(a->op){
            default:
                return 0;
            case CHANNEL_SEND:
                // send always success.
                return 1;
            case CHANNEL_RECEIVE:
                return c->buffer.count > 0;
        }
    } else{
        switch(a->op){
            default:
                return 0;
            case CHANNEL_SEND:
                return c->buffer.count < c->buffer.size;
            case CHANNEL_RECEIVE:
                return c->buffer.count > 0;
        }
    }
}

static void altqueue(chan_alt *a) {
    alt_queue *altqueue = chanarray(a->channel, a->op);
    altqueuepush(altqueue, a);
}


/*
 * Actually move the data around.  There are up to three
 * players: the sender, the receiver, and the channel itself.
 * If the channel is unbuffered or the buffer is empty,
 * data goes from sender to receiver.  If the channel is full,
 * the receiver removes some from the channel and the sender
 * gets to put some in.
 * 1 success, 0 fail.
 */
static int altcopy(chan_alt *s, chan_alt *r) {
    chan_alt *t;
    co_channel *c;
    
    /*
     * Work out who is sender and who is receiver
     */
    if(s == nil && r == nil) {
        return 0;
    }
    assert(s != nil);
    c = s->channel;
    if(s->op == CHANNEL_RECEIVE){
        t = s;
        s = r;
        r = t;
    }
    assert(s==nil || s->op == CHANNEL_SEND);
    assert(r==nil || r->op == CHANNEL_RECEIVE);
    
    /*
     * Channel is empty (or unbuffered) - copy directly.
     */
    if(s && r){
        // no buffer
        if (c->buffer.count == 0) {
            if (s->custom_exec) {
                s->custom_exec();
            }
            amove(r->value, s->value, c->buffer.elemsize);
            return 1;
        } else {
            // hasBuffer
            // receive first from buffer
            queuepop(&c->buffer, r->value);
            // then send to buffer
            return queuepush(&c->buffer, s->value);
        }
    }
    
    /*
     * Otherwise it's always okay to receive and then send.
     */
    if(r){
        return queuepop(&c->buffer, r->value);
    } else if(s) {
        return queuepush(&c->buffer, s->value);
    }
    return 0;
}

static int altexec(chan_alt *a) {

    alt_queue *altqueue;
    chan_alt *other = NULL;
    co_channel *c;
    
    c = a->channel;
    altqueue = chanarray(c, otherop(a->op));
    if(altqueuepop(altqueue, &other)){

        int copyRet = altcopy(a, other);
        assert(copyRet == 1);
        coroutine_t *co = other->task;
        void (*custom_resume)(coroutine_t *co) = c->custom_resume;
        chanunlock(c);
        
        // call back sender
        chan_alt *sender = a->op == CHANNEL_SEND ? a : other;
        if (sender->custom_exec) {
            sender->custom_exec();
        }
        
        if (custom_resume) {
            custom_resume(co);
        } else {
            coroutine_add(co);
        }
        return CHANNEL_ALT_SUCCESS;
    } else {
        int copyRet = altcopy(a, nil);
        chanunlock(c);
        
        if (copyRet && a->op == CHANNEL_SEND) {
            if (a->custom_exec) {
                a->custom_exec();
            }
        }
        return copyRet ? CHANNEL_ALT_SUCCESS : CHANNEL_ALT_ERROR_COPYFAIL;
    }
}

static void chancancelallalt(co_channel *c) {
    
    if (!c) {
        return;
    }
    
    chan_alt **remainList = NULL;
    size_t remainCount = 0;
    
    chanlock(c);

    remainCount = c->asend.count + c->arecv.count;
    if (remainCount > 0) {
        remainList = calloc(remainCount, sizeof(chan_alt *));
        
        chan_alt **ptr = remainList;
        
        alt_queue *sending = &c->asend;
        if (sending->count) {
            
            for (int i = 0; i < sending->count; i++) {
                altqueuepop(sending, ptr);
                ptr++;
            }
        }
        alt_queue *recv = &c->arecv;
        if (recv->count) {
            
            for (int i = 0; i < recv->count; i++) {
                altqueuepop(recv, ptr);
                ptr++;
            }
        }
    }
    
    chanunlock(c);
    
    if (remainCount > 0) {
        for (int i = 0; i < remainCount; i++) {
            chan_alt *a = remainList[i];
            if (!a) {
                continue;
            }
            a->is_cancelled = true;
            // custom cancel
            if (a->cancel_exec) {
                a->cancel_exec();
            }
            
            // resume the task.
            coroutine_t *co = a->task;
            void (*custom_resume)(coroutine_t *co) = c->custom_resume;
            
            if (custom_resume) {
                custom_resume(co);
            } else {
                coroutine_add(co);
            }
        }
        
    }
    
    if (remainList) {
        free(remainList);
    }
    
}



void altcancel(chan_alt *a) {
    if (!a) {
        return;
    }
    
    alt_queue *altqueue;
    co_channel *c;
    
    c = a->channel;
    if (c) {
        chanlock(c);
        
        altqueue = chanarray(c, a->op);
        if(altqueue && altqueue->count){
            
            altqueueremove(altqueue, a);
            chanunlock(c);
            a->is_cancelled = true;
            
            // custom cancel
            if (a->cancel_exec) {
                a->cancel_exec();
            }
            
            // resume the task.
            coroutine_t *co = a->task;
            void (*custom_resume)(coroutine_t *co) = c->custom_resume;
            
            if (custom_resume) {
                custom_resume(co);
            } else {
                coroutine_add(co);
            }
        } else {
            chanunlock(c);
        }
    }
}

int chan_cancel_alt_in_co(coroutine_t *co) {
    if (co && co->chan_alt) {
        altcancel(co->chan_alt);
        return 1;
    }
    return 0;
}

int chanalt(chan_alt *a) {
    
    int canblock = a->can_block;
    co_channel *c;
    coroutine_t *t = coroutine_self();
        
    a->task = t;
    c = a->channel;
    
    chanlock(c);
    
    if(altcanexec(a)) {
        return altexec(a);
    }
    
    if(!canblock) {
        chanunlock(c);
        return a->op == CHANNEL_SEND ? CHANNEL_ALT_ERROR_BUFFER_FULL : CHANNEL_ALT_ERROR_NO_VALUE;
    }
    
    // add to queue
    altqueue(a);
    // set coroutine's chan_alt
    t->chan_alt = a;
    
    chanunlock(c);
    
    // blocking.
    coroutine_yield(t);
    // resume
    t->chan_alt = nil;
    // alt is cancelled
    if (a->is_cancelled) {
        return CHANNEL_ALT_ERROR_CANCELLED;
    }
    
    return CHANNEL_ALT_SUCCESS;
}

static int _chanop(co_channel *c, int op, void *p, int canblock) {
    chan_alt *a = malloc(sizeof(chan_alt));
    
    a->channel = c;
    a->op = op;
    a->value = p;
    a->op = op;
    a->can_block = canblock;
    a->prev = NULL;
    a->next = NULL;
    a->is_cancelled = false;
    a->custom_exec = NULL;
    a->cancel_exec = NULL;
    
    int ret = chanalt(a);
    free(a);
    return ret;
}

static int _chanop2(co_channel *c, int op, void *p, int canblock, IMP custom_exec, IMP cancel_exec) {
    chan_alt *a = malloc(sizeof(chan_alt));
    
    a->channel = c;
    a->op = op;
    a->value = p;
    a->op = op;
    a->can_block = canblock;
    a->prev = NULL;
    a->next = NULL;
    a->is_cancelled = false;
    a->custom_exec = custom_exec;
    a->cancel_exec = cancel_exec;

    int ret = chanalt(a);
    free(a);
    return ret;
}

#pragma mark - public apis

int chansend(co_channel *c, void *v) {
    return _chanop(c, CHANNEL_SEND, v, 1);
}

int channbsend(co_channel *c, void *v) {
    return _chanop(c, CHANNEL_SEND, v, 0);
}

int chanrecv(co_channel *c, void *v) {
    return _chanop(c, CHANNEL_RECEIVE, v, 1);
}

int channbrecv(co_channel *c, void *v) {
    return _chanop(c, CHANNEL_RECEIVE, v, 0);
}

int chansendp(co_channel *c, void *v) {
    return _chanop(c, CHANNEL_SEND, (void*)&v, 1);
}

void *chanrecvp(co_channel *c) {
    void *v = NULL;
    
    _chanop(c, CHANNEL_RECEIVE, (void*)&v, 1);
    return v;
}

int channbsendp(co_channel *c, void *v) {
    return _chanop(c, CHANNEL_SEND, (void*)&v, 0);
}

void *channbrecvp(co_channel *c) {
    void *v = NULL;
    
    _chanop(c, CHANNEL_RECEIVE, (void*)&v, 0);
    return v;
}

int chansendul(co_channel *c, unsigned long val) {
    return _chanop(c, CHANNEL_SEND, &val, 1);
}

unsigned long chanrecvul(co_channel *c) {
    unsigned long val = 0;
    
    _chanop(c, CHANNEL_RECEIVE, &val, 1);
    return val;
}

int channbsendul(co_channel *c, unsigned long val) {
    return _chanop(c, CHANNEL_SEND, &val, 0);
}

unsigned long channbrecvul(co_channel *c) {
    unsigned long val = 0;
    
    _chanop(c, CHANNEL_RECEIVE, &val, 0);
    return val;
}

int chansend_custom_exec(co_channel *c, void *v, IMP exec, IMP cancelExec) {
    return _chanop2(c, CHANNEL_SEND, v, 1, exec, cancelExec);
}

int channbsend_custom_exec(co_channel *c, void *v, IMP exec) {
    return _chanop2(c, CHANNEL_SEND, v, 0, exec, NULL);
}

int chanrecv_custom_exec(co_channel *c, void *v, IMP cancelExec) {
    return _chanop2(c, CHANNEL_RECEIVE, v, 1, NULL, cancelExec);
}
