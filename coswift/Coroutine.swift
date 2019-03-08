//
//  Coroutine.swift
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
import Dispatch


/// Get the swift Coroutine object from a c pointer to coroutine_t struct
///
/// - Parameter co: c pointer to coroutine_t struct
/// - Returns: the swift coroutine object.
public func co_get_swiftobj(co: UnsafeMutablePointer<coroutine_t>?) -> Coroutine? {
    return co.flatMap { (coo) -> UnsafeMutableRawPointer?  in
        return coroutine_getuserdata(coo)
        }.flatMap({ (ud) -> Coroutine? in
            return Unmanaged<Coroutine>.fromOpaque(ud).takeUnretainedValue()
        })
}

/// Coroutine is the object manager coroutine.
open class Coroutine {
    
    /// Callback when coroutine is finished.
    public var finishedBlock: (() -> Void)?
    
    /// The code body of the coroutine.
    public var execBlock: () throws -> Void
    
    /// The DispatchQueue that run the coroutine's code
    public var queue: DispatchQueue
    
    /// The c pointer to coroutine_t struct
    private var co: UnsafeMutablePointer<coroutine_t>?
    
    /// The closure to cancel the blocking Channel when Coroutine cancel.
    /// If a channel blocking this coroutine, should set this block.
    public var chanCancelBlock: (() -> Void)?
    
    /// The lastError occurred in the Coroutine.
    public var lastError: Error?
    
    /// Get the current running coroutine object.
    /// Should call in a coroutine body.
    ///
    /// - Returns: The Coroutine swift object
    public class func current() -> Coroutine? {
        
        let co: UnsafeMutablePointer<coroutine_t>? = coroutine_self()
        if co != nil {
            return co_get_swiftobj(co: co)
        } else {
            return nil
        }
    }
    
    /// Tell if the coroutine is cancelled or finished.
    ///
    /// - Returns: If current coroutine is active
    public class func isActive() -> Bool {
        if let co = Coroutine.current() {
            if co.cancelled || co.finished {
                return false
            } else {
                return true
            }
        }
        return false
    }
    
    /// the coroutine's entry point
    private func execute() {
        
        defer {
            finished = true
            if let finishBlock = finishedBlock {
                finishBlock()
            }
        }
        
        do {
            try self.execBlock()
        } catch {
            self.lastError = error

        }
    }
    
    
    /// The c bridge of the entry point
    private let co_exec: @convention(c) (Optional<UnsafeMutableRawPointer>)->Void = { p in
        
        if let co: UnsafeMutablePointer<coroutine_t> = p?.assumingMemoryBound(to: coroutine_t.self) {
            
            if let coObj: Coroutine = co_get_swiftobj(co: co) {
                
                coObj.execute()
            }
        }
    }
    
    /// Create a coroutine
    ///
    /// - Parameters:
    ///   - block: the block
    ///   - queue: the queue
    public init(block: @escaping () throws -> Void, on queue: DispatchQueue? = nil, stackSize: UInt32? = nil) {
        execBlock = block
        self.queue = queue ?? co_get_current_queue()
        co = coroutine_create(co_exec)
        if let ss = stackSize {
            co?.pointee.stack_size = (ss % 16384 > 0) ? ((ss/16384 + 1)*16384) : ss
        }
        coroutine_setuserdata(co, Unmanaged<Coroutine>.passRetained(self).toOpaque()) { (ud) in
            if let p: UnsafeMutableRawPointer = ud {
                let coObj = Unmanaged<Coroutine>.fromOpaque(p).takeUnretainedValue()
                coObj.co = nil
                Unmanaged<Coroutine>.fromOpaque(p).release()
            }
        }
    }
    
    /// The coroutine is Finished.
    private var finished: Bool = false
    public var isFinished: Bool {
        get {
            return finished
        }
    }
    
    /// The coroutine is started.
    public var resumed: Bool = false
    
    /// The coroutine is cancelled
    private var cancelled: Bool = false
    public var isCancelled: Bool {
        get {
            return cancelled
        }
    }
    
    /// Execute code on the coroutine's queue
    private func performBlockOnQueue(block: @escaping ()->Void ) {
        if co_get_current_queue() == self.queue {
            block()
        } else {
            self.queue.async {
                block()
            }
        }
    }
    
    /// Do the cancel operation
    private func internalCancel() {
        if cancelled {
            return
        }
        cancelled = true
        
        self.co?.pointee.is_cancelled = true
        if let chanCancel = self.chanCancelBlock {
            chanCancel();
        }
    }
    
    /// Cancel the coroutine
    public func cancel() {
        performBlockOnQueue {
            self.internalCancel()
        }
    }
    
    /// Using this method in another coroutine to wait the coroutine finished.
    /// Example:  let co = co_launch { ... }
    ///           co_launch { co.join() }
    public func join() {
        let chan = Chan<Bool>(buffCount: 1)
        performBlockOnQueue {
            
            if self.isFinished {
                chan.send_nonblock(val: true)
            } else {
                self.finishedBlock = {
                    chan.send_nonblock(val: true)
                }
            }
        }
        do {
            _ = try chan.receive()
        } catch {
            
        }
    }
    
    
    /// Using this method in another coroutine,
    /// cancel the coroutine and then wait it finish.
    /// Example:  let co = co_launch { ... }
    ///           co_launch { co.join() }
    public func cancelAndJoin() {
        let chan = Chan<Bool>(buffCount: 1)
        performBlockOnQueue {
            
            if self.isFinished {
                chan.send_nonblock(val: true)
            } else {
                self.finishedBlock = {
                    chan.send_nonblock(val: true)
                }
                self.internalCancel()
            }
        }
        do {
            _ = try chan.receive()
        } catch {
            
        }
    }
    
    /// Resume the coroutine asynchronous.
    ///
    /// - Returns: The coroutine object.
    public func resume() -> Coroutine {
        self.queue.async() {
            
            if self.resumed {
                return
            }
            self.resumed = true
            coroutine_resume(self.co)
        }
        return self
    }
    
    /// Resume the coroutine directly if on same queue, else asynchronous.
    ///
    /// - Returns: The coroutine object.
    public func resumeNow() -> Void {
        self.performBlockOnQueue {
            if self.resumed {
                return
            }
            self.resumed = true
            coroutine_resume(self.co)
        }
    }
    
    
    /// Add coroutine to the scheduler. If sheduler is idle, resume it.
    public func addToScheduler() -> Void {
        self.performBlockOnQueue {
            coroutine_add(self.co)
        }
    }
}
