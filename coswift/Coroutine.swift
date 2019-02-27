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


public func co_get_swiftobj(co: UnsafeMutablePointer<coroutine_t>?) -> Coroutine? {
    return co.flatMap { (coo) -> UnsafeMutableRawPointer?  in
        return coroutine_getuserdata(coo)
        }.flatMap({ (ud) -> Coroutine? in
            return Unmanaged<Coroutine>.fromOpaque(ud).takeUnretainedValue()
        })
}

/**
 COCoroutine is the object owned coroutine.
 */
open class Coroutine {
    
    
    /**
     Call back when coroutine is finished.
     */
    public var finishedBlock: (() -> Void)?
    
    
    /**
     The code body of the coroutine.
     */
    public var execBlock: () throws -> Void
    
    
    /**
     The `dispatch_queue_t` coroutine will run on it.
     */
    public var queue: DispatchQueue
    
    
    /**
     The struct pointer of coroutine_t
     */
    private var co: UnsafeMutablePointer<coroutine_t>?
    
    
    /**
     When COCoroutine as a Generator, this Channel use to yield a value.
     */
    public var yieldChan: Chan<Any>?
    
    
    /**
     If `COCoroutine is suspend by a Channel, this pointer mark it.
     */
    public var currentChan: Chan<Any>?
    
    
    /**
     The lastError marked in the Coroutine.
     */
    public var lastError: Error?
    
    
    /**
     Get the current running coroutine object.
     
     @return The coroutine object.
     */
    public class func current() -> Coroutine? {
        
        let co: UnsafeMutablePointer<coroutine_t>? = coroutine_self()
        if co != nil {
            return co_get_swiftobj(co: co)
        } else {
            return nil
        }
    }
    
    
    /**
     Tell if the coroutine is cancelled or finished.
     
     @return isActive
     */
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
    
    /// running
    private func execute() {
        
        defer {
            finished = true
            if let finishBlock = finishedBlock {
                finishBlock()
            }
            yieldChan = nil
        }
        
        do {
            try self.execBlock()
        } catch {
            self.lastError = error

        }
    }
    
    
    /// The c bridge
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
    
    /**
     The coroutine is Finished.
     */
    private var finished: Bool = false
    public var isFinished: Bool {
        get {
            return finished
        }
    }
    
    private var resumed: Bool = false
    
    /**
     The coroutine is cancelled.?
     */
    private var cancelled: Bool = false
    public var isCancelled: Bool {
        get {
            return cancelled
        }
    }
    
    private func performBlockOnQueue(block: @escaping ()->Void ) {
        
        if co_get_current_queue() == self.queue {
            block()
        } else {
            self.queue.async {
                block()
            }
        }
    }
    
    private func internalCancel() {
        if cancelled {
            return
        }
        cancelled = true
        
        self.co?.pointee.is_cancelled = true
        if let chan = self.currentChan {
            chan.cancel();
        }
    }
    
    /**
     Cancel the coroutine.
     */
    public func cancel() {
        performBlockOnQueue {
            self.internalCancel()
        }
    }
    
    
    /**
     Calling this method in another coroutine. wait the coroutine to be finished.
     */
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
    
    
    /**
     Calling this method in another coroutine. Cancel the coroutine, and wait the coroutine to be finished.
     */
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
    
    
    /**
     Resume the coroutine.
     
     @return The coroutine object.
     */
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
    
    /**
     Resume the coroutine, if on current queue, run in current runloop.
     */
    public func resumeNow() -> Void {
        self.performBlockOnQueue {
            if self.resumed {
                return
            }
            self.resumed = true
            coroutine_resume(self.co)
        }
    }
    
    /**
     Add coroutine to the scheduler. If sheduler is idle, resume it.
     */
    public func addToScheduler() -> Void {
        self.performBlockOnQueue {
            coroutine_add(self.co)
        }
    }
}
