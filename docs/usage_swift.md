# coswift usage

This document instroduce how to use coroutine in swift.

# Simple Launch

You can start a coroutine anywhere.

```swift
co_launch {
    // code
}

// running on a DispatchQueue
let queue = DispatchQueue(label: "MyQueue")
co_launch(queue: queue) {
    // code
}

// set custom stack size of coroutine
co_launch(stackSize: 128 * 1024) {
    // code
}
```

# Simple await/async

Define a suspendable func with Promises or Channel, then `await` in a coroutine.

```swift
// make a async operation
func co_fetchSomethingAsynchronous() -> Promise<Data?> {
    
    return Promise<Data?>(constructor: { (fulfill, reject) in
        
        var data: Data? = nil
        var error: Error? = nil
        
        // fetch the data
        ......
        
        if error != nil {
            reject(error!)
        } else {
            fulfill(data)
        }
    })
}


// calling in a coroutine.
co_launch {
    let result = try await {
        co_fetchSomethingAsynchronous()
    }
    switch result {
    case .fulfilled(let data):
        print("data: \(data)")
        break
    case .rejected(let error):
        print("error: \(error)")
    }
}
```

Define a suspendable func with Channel, then `await` in a coroutine.

```swift
func co_fetchSomething() -> Chan<String> {
    
    let chan = Chan<String>()
    
    someQueue.async {
        // fetch operations
        ......
        chan.send_nonblock(val: "the result")
    }
    return chan
}

// calling in a coroutine.
co_launch {
    let resultStr = try await(channel: co_fetchSomething())
    print("result: \(resultStr)")
}

```

# Cancellation 

When cancel a coroutine in coswift, a `COError.coroutineCancelled` throws.

Simple code:

```swift
// make a async operation
func co_fetchSomethingAsynchronous() -> Promise<Data?> {
    
    let promise = Promise<Data?>(constructor: { (fulfill, reject) in
        
        var data: Data? = nil
        var error: Error? = nil
        
        // fetch the data
        ......
        
        if error != nil {
            reject(error!)
        } else {
            fulfill(data)
        }
    })

    promise.onCancel { (promiseObj) in
        
        // do the cancel job
        ......
    }

    return promise
}


// calling in a coroutine.
let task = co_launch {
    let result = try await {
        co_fetchSomethingAsynchronous()
    }
    switch result {
    case .fulfilled(let data):
        print("data: \(data)")
        break
    case .rejected(let error):
        print("error: \(error)")
    }
}

task.cancel()

```

