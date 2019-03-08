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
    
    public typealias  ChanOnCancelBlock = (Chan) -> Void
    
    public var onCancel: ChanOnCancelBlock?
    public var isCancelled: Bool {
        get {
            return cancelled
        }
    }
    
    private var buffCount: Int32
    private var cchan: UnsafeMutablePointer<co_channel>
    private var cancelled: Bool = false
    private var buffList: [T] = []
    private let lock = NSRecursiveLock()
    
    public init(buffCount: Int32) {
        
        self.buffCount = buffCount
        let eleSize = Int32(MemoryLayout<UInt>.size)
        cchan = chancreate(eleSize, buffCount, co_chan_custom_resume)
    }
    
    public convenience init() {
        self.init(buffCount: 0)
    }
    
    deinit {
        chanfree(cchan)
    }
    
    public class func expandable() -> Chan<T> {
        
        return Chan(buffCount: -1)
    }
    
    public func send(val: T) throws {
        
        if let co = Coroutine.current() {
            co.chanCancelBlock = {
                self.cancel()
            }
            
            lock.lock()
            buffList.append(val)
            lock.unlock()
            chansendul(cchan, 1);
            co.chanCancelBlock = nil
            if cancelled {
                throw COError.coroutineCancelled
            }
        }
    }
    
    public func send_nonblock(val: T) {
        
        lock.lock()
        buffList.append(val)
        lock.unlock()
        channbsendul(cchan, 1)
    }
    
    public func receive() throws -> T {
        
        if let co = Coroutine.current() {
            
            co.chanCancelBlock = {
                self.cancel()
            }
            let ret = chanrecvul(cchan);
            co.chanCancelBlock = nil

            if ret == 1 {
                
                lock.lock()
                let obj = buffList.removeFirst()
                lock.unlock()
                return obj
            } else {
                throw COError.coroutineCancelled
            }
            
        } else {
            throw COError.invalidCoroutine
        }
    }
    
    public func receive_nonblock() -> T? {
     
        let ret = channbrecvul(cchan)
        if ret == 1 {
            lock.lock()
            let obj = buffList.removeFirst()
            lock.unlock()
            return obj
        } else {
            return nil
        }
    }
    
    public func cancel() {
        
        if cancelled {
            return
        }
        cancelled = true
        
        if let cancelBlock = self.onCancel {
            cancelBlock(self)
        }
        
        var blockingSend:Int32 = 0
        var blockingReceive:Int32 = 0
        
        if (changetblocking(cchan, &blockingSend, &blockingReceive) != 0) {
            
            if blockingSend > 0 {
                for _ in 0..<blockingSend {
                    chanrecvul(cchan)
                }
            } else if blockingReceive > 0 {
                for _ in 0..<blockingReceive {
                    chansendul(cchan, 0)
                }
            }
        }
    }
}
