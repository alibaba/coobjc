//
//  Promise.swift
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

private enum PromiseState {
    case pending
    case fulfilled
    case rejected
    
}

public enum Resolution<T> {
    case fulfilled(T)
    case rejected(Error)
}

public class Promise<T> {
    
    
    public typealias PromiseOnCancelBlock = (Promise<T>) -> Void
    public typealias PromiseFulfill = (T) -> Void
    public typealias PromiseReject = (Error) -> Void
    public typealias PromiseConstructor = (@escaping PromiseFulfill, @escaping PromiseReject) -> Void
    
    private typealias PromiseObserver = (PromiseState, Resolution<T>) -> Void
    
    
    
    private var state: PromiseState = .pending
    private var _value: T?
    public var value: T? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _value
        }
    }
    
    private var _error: Error?
    public var error: Error? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _error
        }
    }
    
    private var promiseObservers: [PromiseObserver] = []
    private let lock = NSRecursiveLock()
    
    public var isPending: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return state == .pending
        }
    }
    
    public var isFulfilled: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return state == .fulfilled
        }
    }
    public var isRejected: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return state == .rejected
        }
    }
    
    
    public init() {}
    
    public convenience init(constructor: @escaping PromiseConstructor) {
        self.init(on: co_get_current_queue(), constructor: constructor)
    }
    
    public convenience init(on queue: DispatchQueue?, constructor: @escaping PromiseConstructor) {
        self.init()
        
        let fulfill: PromiseFulfill = { (val: T) in
            self.fulfill(value: val)
        }
        let reject: PromiseReject = { (err: Error) in
            self.reject(error: err)
        }
        
        if let q = queue {
            q.async {
                constructor(fulfill, reject);
            }
        } else {
            constructor(fulfill, reject)
        }
    }
    
    public func fulfill(value: T) {
        
        var observers: [PromiseObserver]? = nil
        var stateTmp: PromiseState? = nil
        
        do {
            lock.lock()
            defer { lock.unlock() }
            if state == .pending {
                state = .fulfilled
                stateTmp = state
                _value = value
                observers = promiseObservers
                promiseObservers = []
            }
        }
        
        observers?.forEach({ (observer) in
            observer(stateTmp!, Resolution<T>.fulfilled(value))
        })
    }
    
    public func reject(error: Error) {
        
        var observers: [PromiseObserver]? = nil
        var stateTmp: PromiseState? = nil
        
        do {
            lock.lock()
            defer { lock.unlock() }
            if state == .pending {
                state = .rejected
                stateTmp = state
                _value = value
                observers = promiseObservers
                promiseObservers = []
            }
        }
        
        observers?.forEach({ (observer) in
            observer(stateTmp!, Resolution<T>.rejected(error))
        })
    }
    
    public func cancel() {
        self.reject(error: COError.promiseCancelled)
    }
    
    public func onCancel(onCancelBlock: @escaping PromiseOnCancelBlock) {
        
        self.catch { [weak self](err) in
            if let strongSelf = self, let error = err as? COError, error == .promiseCancelled {
                onCancelBlock(strongSelf)
            }
        }
    }
    
    private func observe(fulfill: PromiseFulfill?, reject: PromiseReject?) {
        if fulfill == nil && reject == nil {
            return
        }
        
        var stateTmp: PromiseState = .pending
        
        var valueTmp: T? = nil
        var errorTmp: Error? = nil
        
        lock.lock()
        
        switch self.state {
        case .pending:
            promiseObservers.append { (st, resolution) in
                
                switch st {
                case .pending:
                    break
                case .fulfilled:
                    if let fulfillBlock = fulfill {
                        switch resolution {
                        case .fulfilled(let val):
                            fulfillBlock(val)
                            break
                        case .rejected(_):
                            break
                        }
                    }
                    break
                case .rejected:
                    if let rejectBlock = reject {
                        switch resolution {
                        case .fulfilled(_):
                            break
                        case .rejected(let error):
                            rejectBlock(error)
                            break
                        }
                    }
                    break
                }
            }
            break
        case .fulfilled:
            stateTmp = .fulfilled
            valueTmp = value
            break
        case .rejected:
            stateTmp = .rejected
            errorTmp = error
        }
        
        lock.unlock()
        
        if stateTmp == .fulfilled {
            if let fulfillBlock = fulfill {
                fulfillBlock(valueTmp!)
            }
        }
        else if stateTmp == .rejected {
            if let rejectBlock = reject {
                rejectBlock(errorTmp!)
            }
        }
    }
    
    private func chainedPromise<U>(chainedFulfill: @escaping ((T) -> U), chainedReject: ((Error) -> Error)?) -> Promise<U> {
        
        let promise = Promise<U>()
        
        let fulfillr = { (val: U) in
            promise.fulfill(value: val)
        }
        
        let rejectr = { (error: Error) in
            promise.reject(error: error)
        }
        
        self.observe(fulfill: { (val: T) in
            
            let ret = chainedFulfill(val)
            fulfillr(ret)
            
        }) { (err: Error) in
            
            if let chainedRejectBlock = chainedReject {
                let ret = chainedRejectBlock(err)
                rejectr(ret)
            } else {
                rejectr(err)
            }
        }
        return promise
    }
    
    private func chainedPromise<U>(chainedFulfill: @escaping ((T) -> Promise<U>), chainedReject: ((Error) -> Error)?) -> Promise<U> {
        
        let promise = Promise<U>()
        
        let fulfillr = { (val: U) in
            promise.fulfill(value: val)
        }
        
        let rejectr = { (error: Error) in
            promise.reject(error: error)
        }
        
        self.observe(fulfill: { (val: T) in
            
            let ret = chainedFulfill(val)
            ret.observe(fulfill: { (val2: U) in
                fulfillr(val2)
            }, reject: { (err) in
                rejectr(err)
            })
            
        }) { (err: Error) in
            
            if let chainedRejectBlock = chainedReject {
                let ret = chainedRejectBlock(err)
                rejectr(ret)
            } else {
                rejectr(err)
            }
        }
        return promise
    }
    
    @discardableResult
    public func then<U>(work: @escaping (T) -> U) -> Promise<U> {
        return self.chainedPromise(chainedFulfill: work, chainedReject: nil)
    }
    
    @discardableResult
    public func then<U>(work: @escaping (T) -> Promise<U>) -> Promise<U> {
        return self.chainedPromise(chainedFulfill: work, chainedReject: nil)
    }
    
    @discardableResult
    public func `catch`(reject: @escaping (Error) -> Void) -> Promise<T> {
        
        return self.chainedPromise(chainedFulfill: { (val: T) -> T in
            return val
        },  chainedReject: { (err) -> Error in
            
            reject(err)
            return err
        })
    }
}
