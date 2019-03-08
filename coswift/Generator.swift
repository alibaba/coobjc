//
//  Generator.swift
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
public func co_sequence<T>(_ type: T.Type, queue: DispatchQueue? = nil, stackSize: UInt32? = nil, block: @escaping () throws -> Void) -> Generator<T> {
    let co = Generator<T>(block: block, on: queue, stackSize: stackSize)
    _ = co.resume()
    return co
}

/// Yield a `{ value } throws` block
/// Example: `yield {  try getSomeValue() }`
///
/// - Parameter closure: the operation returns a value.
/// - Throws: COError
public func yield<T>(closure: @escaping () throws -> T ) throws {
    if let co = Coroutine.current() {
        if co.isCancelled {
            throw COError.generatorCancelled
        }
        
        if let gen = co as? Generator<T> {
            
            try gen.yieldChan.send(val: true)
            
            if gen.isCancelled {
                throw COError.generatorCancelled
            }
            let val = try closure()
            if gen.isCancelled {
                throw COError.generatorCancelled
            }
            try gen.valueChan.send(val: val)
            
        } else {
            throw COError.notGenerator
        }
        
    } else {
        throw COError.invalidCoroutine
    }
}

/// Yield a `{ value }` block
/// Example: `yield { val * 5 - i }`
///
/// - Parameter closure: the operation returns a value.
/// - Throws: COError
public func yield<T>(closure: @escaping () -> T ) throws {
    if let co = Coroutine.current() {
        if co.isCancelled {
            throw COError.generatorCancelled
        }
        
        if let gen = co as? Generator<T> {
            
            try gen.yieldChan.send(val: true)
            
            if gen.isCancelled {
                throw COError.generatorCancelled
            }
            let val = closure()
            if gen.isCancelled {
                throw COError.generatorCancelled
            }
            try gen.valueChan.send(val: val)
            
        } else {
            throw COError.notGenerator
        }
        
    } else {
        throw COError.invalidCoroutine
    }
}

/// Yield a promise operation
/// Example: `yield { somePromise() }`
///
/// - Parameter closure: the operation returns a promise.
/// - Throws: COError
public func yield<T>(closure: @escaping () -> Promise<T> ) throws {
    try yield {
        return try await(closure: closure)
    }
}

/// Yield a channel operation
/// Example: `yield { someChannel() }`
///
/// - Parameter closure: the operation returns a Channel.
/// - Throws: COError
public func yield<T>(closure: @escaping () -> Chan<T> ) throws {
    try yield {
        return try await(closure: closure)
    }
}


/// Define the generator class
open class Generator<T>: Coroutine {
    
    fileprivate var yieldChan: Chan<Bool>
    fileprivate var valueChan: Chan<T>
    
    public override init(block: @escaping () throws -> Void, on queue: DispatchQueue?, stackSize: UInt32?) {
        
        yieldChan = Chan<Bool>()
        valueChan = Chan<T>()

        super.init(block: block, on: queue, stackSize: stackSize)
    }
    
    
    /// Fetch a value from the Generator
    /// Example: `let val = try generator.next()`
    ///
    /// - Returns: the value from generator
    /// - Throws: COError
    open func next() throws -> T {
        if resumed == false {
            _ = resume()
        }
        if Coroutine.current() == nil {
            throw COError.invalidCoroutine
        }
        if isCancelled == true {
            throw COError.generatorCancelled
        }
        if isFinished {
            throw COError.generatorClosed
        }
        
        _ = try yieldChan.receive()
        return try valueChan.receive()
    }
}
