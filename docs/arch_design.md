# coobjc

![framework_arch.png](images/framework_arch.png)

* The bottom layer is the coroutine kernel, which includes management of stack switching, implementation of coroutine scheduler, implementation of communication channel between coroutines, etc.
* The middle layer is a wrapper based on the operators of the coroutine. Currently, it supports programming models such as async/await, generator, and Actor.
* The top layer is the coroutine extension to the system library, which currently covers all the IO and time-consuming methods of Foundation and UIKit.

coobjc's architecture divided into the following:

- Switch context
- Coroutine object
- Scheduler
- Channel
- Api
- Cancellation
- Swift

# Switch context

Since `ucontext.h` is deprecated on iOS, we implement custom `getcontext` and `setcontext` method using asm, support arm64/armv7/x86_64/i386 four architectures.

The following image figure out how we using `getcontext` and `setcontext` to implement coroutine's `yield` and `resume` operations.

![context.png](/docs/images/context.png)

# Coroutine

- Pausable and recoverable

A coroutine can pause with `yield` function, and recover with `resume` function.

- Custom calling stack

Coroutine alloc a piece of memory use for calling stack, the memory address stored in `stack_memory`.

- Four state

Coroutine has for state: READY/RUNNING/SUSPEND/DEAD. The RUNNING and SUSPEND states may be switched multiple times。

When entering the DEAD state, Coroutine will automatically release.

- Userdata

```
void *userdata;                     // Userdata.
coroutine_func userdata_dispose;    // Userdata's dispose action.
```

You can set a `userdata` to Coroutine, and set `userdata_dispose` to cleanup `userdata` when Coroutine DEAD. 


# Scheduler

How can the coroutine be used in our iOS app? How do you interact with existing code? Which thread is scheduled in the coroutine? So we designed the coroutine scheduler `Scheduler`.

`Scheduler` is responsible for scheduling all user coroutines. It internally manages a coroutine queue, and then continuously loops out the coroutines from the queue for execution. When there is no coroutine in the queue, it switches back to thread execution.

Based on this design, when we want to execute a coroutine, we only add the coroutine to the thread's `Scheduler` queue, and then `Scheduler` is responsible for executing it.

`Scheduler` itself is also a coroutine.

![scheduler.png](/docs/images/scheduler.png)

# Channel 的设计

Channel is the implementation of Process/Channel in the CSP (Communicating Sequential Processes) concurrency model. The Channel implementation in coobjc fully references the implementation of [libtask](https://swtch.com/libtask/).


Channel transfers data between cooperatives. Channel's characteristic is that it can blocking send or blocking receive data in a coroutine (the blockages in coroutine are not real blockages, just only paused).


Channel is divided into **no buffer**, **buffer**, **infinite buffer** (automatic expansion of buffer) mode, the following figure describes the difference between buffers:

![channel1.png](/docs/images/channel1.png)

The main feature of the Channel is that it can blocking the coroutine. When a data from `send` to a Channel, if there is no buffer to save, then the current coroutine will be blocked until there is another place `receive` from this Channel. 

Similarly, `receive` will also block the current coroutine until there is data `send` to the Channel.

![channel2.png](/docs/images/channel2.png)

# Api的设计

The basic design of the coroutine mentioned above is based on the implementation of c, then how is our upper API designed?

- ObjC Classes

We implement ObjC Classes `COCoroutine` and `COChan` for invocation by the upper interface.

- promises
 
Simplified the implementation of `COPromise` based on [promises](https://github.com/google/promises). 
 
- co_launch/await/yield/co_delay
 
`co_launch` is the entry from the thread into the coroutine, is the encapsulation of `COCoroutine`,

The `await/yield` primitive is implemented based on `Channel`, which uses `Channel` to block the characteristics of the coroutine.

`co_delay` is a implementation of delay, it is implemented using `dispatch`.

# Cancellation

The cancellation of the coobjc's coroutine is required in the **collaboration**, similar to the cancellation of NSOperation.

Because of the forced interrupt a code execution, memory leaks may occur, such as:

```
id obj = ...    // Create a object

await(...)      // await， If we stop here, the cleanup phase will not execute. Cause leak.

obj = nil;      // cleanup
```

Another way to cancel a coroutine is to throw an exception, but exceptions in Objective-C can also lead to leaks: https://stackoverflow.com/questions/ 27140891/why-does-try-catch-in-objective-c-cause-memory-leak , so the coroutines in coobjc we need to use the collaboration to complete the cancellation. But in swift we can implement Cancel by throwing Swift.Error

The principle of collaboration cancellation in coobjc is that when canceling a coroutine, system just mark it as `isCancelled`. If you want to design a cancelable coroutine, you need to judge in the code whether the current coroutine has been canceled to exit the code logic.

```
// in objc
COCoroutine *co = co_launch(^{
    ...
    await(...)

    // Check the current coroutine is cancelled.
    if (co_isCancelled()) {
        return;
    }
    ...
})
[co cancel];

// in swift
let co = co_launch {
    ...
    await(...)
    ...
}
co.cancel()

```

# Swift

The bottom layer of **coswift** shares a set of code, but a separate set of Swift interfaces is designed on the top layer. Take advantage of Swift's generic and Error features to have a better experience than **coobjc**.

- Use generics to specify the type of Channel and Promise transport.
- Cancellation does not require collaboration and can be cancelled directly.
- Using tuples
