//
//  Chan.swift
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

private let co_chan_custom_resume: @convention(c) (UnsafeMutablePointer<coroutine_t>?) -> Void = { co in
    
    if let coObj: Coroutine = co_get_swiftobj(co: co) {
        coObj.addToScheduler()
    }
}

/// Define the Channel
public class Chan<T> {
    
    // Define the channel's alt cancel type
    public typealias  ChanOnCancelBlock = (Chan) -> Void
    
    
    private var buffCount: Int32
    private var cchan: UnsafeMutablePointer<co_channel>
    private var buffList: [T] = []
    private let lock = NSRecursiveLock()
    
    
    /// Create a channel with the buffcount.
    ///
    /// - Parameter buffCount: the max buffer count of the channel.
    public init(buffCount: Int32) {
        
        self.buffCount = buffCount
        let eleSize = Int32(MemoryLayout<Int8>.size)
        cchan = chancreate(eleSize, buffCount, co_chan_custom_resume)
    }
    
    
    /// Create a channel with the buffcount 0.
    public convenience init() {
        self.init(buffCount: 0)
    }
    
    deinit {
        chanfree(cchan)
    }
    
    
    /// Create a expandable Channel.  the buffer count is expandable, which means,
    /// `send` will not blocking current process. And, val send to channel will not abandon.
    /// The bufferCount value is being set to -1.
    ///
    /// - Returns: the channel object
    public class func expandable() -> Chan<T> {
        
        return Chan(buffCount: -1)
    }
    
    /// Blocking send a value to the channel.
    ///
    /// - Parameter val: the value to send.
    /// - Throws: COError types
    public func send(val: T, onCancel: ChanOnCancelBlock? = nil) throws {
        
        if let co = Coroutine.current() {
            co.chanCancelBlock = { coroutine in
                self.cancelForCoroutine(co: coroutine)
            }
            
            let objcBlock: @convention(block) ()->Void = {
                self.lock.lock()
                defer { self.lock.unlock() }
                self.buffList.append(val)
            }
            let custom_exec = imp_implementationWithBlock(objcBlock)
            
            var cancel_exec: IMP? = nil
            if let block = onCancel {
                let objcBlock1: @convention(block) ()->Void = {
                    block(self)
                }
                cancel_exec = imp_implementationWithBlock(objcBlock1)
            }
            
            defer {
                imp_removeBlock(custom_exec)
                if let exec = cancel_exec {
                    imp_removeBlock(exec)
                }
                co.chanCancelBlock = nil
            }
            
            var v: Int8 = 1
            
            let ret = chansend_custom_exec(cchan, &v, custom_exec, cancel_exec)
            
            if ret == CHANNEL_ALT_ERROR_CANCELLED.rawValue {
                throw COError.coroutineCancelled
            }
        } else {
            throw COError.invalidCoroutine
        }
    }
    
    /// Non-blocking send a value to the channel
    ///
    /// - Parameter val: the value to send.
    public func send_nonblock(val: T) {
        
        let objcBlock: @convention(block) ()->Void = {
            self.lock.lock()
            defer { self.lock.unlock() }
            self.buffList.append(val)
        }
        let custom_exec = imp_implementationWithBlock(objcBlock)
        var v: Int8 = 1
        _ = channbsend_custom_exec(cchan, &v, custom_exec)
        imp_removeBlock(custom_exec)
    }
    
    /// Blocking receive a value from the channel
    ///
    /// - Returns: the received value
    /// - Throws: COError types
    public func receive(onCancel: ChanOnCancelBlock? = nil) throws -> T {
        
        if let co = Coroutine.current() {
            
            co.chanCancelBlock = { coroutine in
                self.cancelForCoroutine(co: coroutine)
            }
            
            var v: Int8 = 0
            
            var cancel_exec: IMP? = nil
            if let block = onCancel {
                let objcBlock: @convention(block) ()->Void = {
                    block(self)
                }
                cancel_exec = imp_implementationWithBlock(objcBlock)
            }
            
            defer {
                if let exec = cancel_exec {
                    imp_removeBlock(exec)
                }
                co.chanCancelBlock = nil
            }
            
            let ret = chanrecv_custom_exec(cchan, &v, cancel_exec)

            if ret == CHANNEL_ALT_SUCCESS.rawValue {
                
                do {
                    lock.lock()
                    defer { lock.unlock() }
                    let obj = buffList.removeFirst()
                    return obj
                }
            } else if ret == CHANNEL_ALT_ERROR_CANCELLED.rawValue {
                throw COError.coroutineCancelled
            } else {
                throw COError.chanReceiveFailUnknown
            }
            
        } else {
            throw COError.invalidCoroutine
        }
    }
    
    /// Non-blocking receive a value from the channel
    ///
    /// - Returns: the receive value or nil.
    public func receive_nonblock() -> T? {
        var v: Int8 = 0
        let ret = channbrecv(cchan, &v)

        if ret == CHANNEL_ALT_SUCCESS.rawValue {
            do {
                lock.lock()
                defer { lock.unlock() }
                let obj = buffList.removeFirst()
                return obj
            }
        } else {
            return nil
        }
    }
    
    /// Blocking receive all values in the channel for now.
    /// At least receive one value.
    ///
    /// - Returns: the values
    /// - Throws: COError types
    public func receiveAll() throws -> [T] {
        
        var retArray:[T] = []
        
        retArray.append(try self.receive())
        
        while let obj = self.receive_nonblock() {
            retArray.append(obj)
        }
        return retArray
    }
    
    /// Blocking receive count values in the channel.
    ///
    /// - Parameter count: the value count will receive.
    /// - Returns: the values
    /// - Throws: COError types
    public func receiveWithCount(count: UInt) throws -> [T] {
        
        var retArray:[T] = []
        var currCount = 0
        while currCount < count {
            let obj = try self.receive()
            retArray.append(obj)
            currCount += 1
        }
        return retArray
    }
    
    /// Cancel the channel's current sending or receiving operation
    /// Why we provide this api?
    /// Sometimes, we need cancel a operation, such as a Network Connection. So, a coroutine is cancellable.
    /// But Channel may blocking the coroutine, so we need cancel the Channel when cancel a coroutine.
    public func cancelForCoroutine(co: Coroutine) {
        
        chan_cancel_alt_in_co(co.co)
    }
}
