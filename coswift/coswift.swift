//
//  Api.swift
//  coswift
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

import Foundation


/// Launch a coroutine running on queue, and special the stack size
/// of the coroutine.
///
/// - Parameters:
///   - queue: the `dispatch_queue_t` of coroutine's code running.
///   - stackSize: the custom stack size of coroutine
///   - block: the coroutine's body code
/// - Returns: the coroutine object
@discardableResult
public func co_launch(queue: DispatchQueue? = nil, stackSize: UInt32? = nil, block: @escaping () throws -> Void) -> Coroutine {
    let co = Coroutine(block: block, on: queue, stackSize: stackSize)
    return co.resume()
}

/// Await a promise object
///
/// - Parameter promise: The Promise object
/// - Returns: the promise's resolution
/// - Throws: COError type
///
/// Examples:
///     let resolution = await(somePromise)
///     switch result {
///     case .fulfilled(let val):
///         // the promise fulfilled
///         break
///     case .rejected(let error):
///         // the promise reject
///         break
///     }
public func await<T>(promise: Promise<T>) throws -> Resolution<T>  {
    if let _ = Coroutine.current() {
        
        let chan = Chan<Resolution<T>>(buffCount: 1)
        
        promise.then(work: { (value) -> Any in
            chan.send_nonblock(val: Resolution<T>.fulfilled(value))
        }).catch { (error) in
            if let err = error as? COError, err == .promiseCancelled {
                
            } else {
                chan.send_nonblock(val: Resolution<T>.rejected(error))
            }
        }
        
        chan.onCancel = { (channel) in
            promise.cancel()
        }
        
        return try chan.receive()
        
    } else {
        throw COError.invalidCoroutine
    }
}

/// A Convenience use of await
///
/// - Parameter closure: return a Promise object
/// - Returns: the promise's resolution
/// - Throws: COError
public func await<T>(closure: @escaping () -> Promise<T> ) throws -> Resolution<T> {
    return try await(promise: closure())
}

/// Await a channel object, blocking current process, wait the channel send something.
///
/// - Parameter channel: the Chan object
/// - Returns: The value passing to channel
/// - Throws: COError
public func await<T>(channel: Chan<T>) throws -> T {
    if let _ = Coroutine.current() {
        return try channel.receive()
    } else {
        throw COError.invalidCoroutine
    }
}

/// Check current coroutine is active or not.
public var co_isActive: Bool {
    get {
        return Coroutine.isActive()
    }
}
