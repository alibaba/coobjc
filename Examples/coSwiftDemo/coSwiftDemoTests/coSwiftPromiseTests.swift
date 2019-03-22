//
//  coSwiftDemoTests.swift
//  coSwiftDemoTests
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

import XCTest
import coswift
import Quick
import Nimble

func testPromise1() -> Promise<String> {
    let promise = Promise<String>();
    
    DispatchQueue.main.async {
        promise.fulfill(value: "123")
    }
    return promise
}

func testPromise2() -> Promise<String> {
    let promise = Promise<String>();
    
    DispatchQueue.main.async {
        promise.reject(error: NSError(domain: "aa", code: -1, userInfo: nil))
    }
    return promise
}

func testPromise3() -> Promise<String> {
    let promise = Promise<String>();
    
    
    let timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
        print("[\(NSDate())]====promise on fulfill 1234")
        promise.fulfill(value: "1234")
    }
    
    promise.onCancel { (promise) in
        print("[\(NSDate())]====promise on cancel")
        timer.invalidate()
    }
    return promise
}

func testPromise21() -> Promise<String> {
    return Promise<String> { (fulfill, reject) in
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5000), execute: {
            fulfill("1")
        })
    }
}

func testPromise22() -> Promise<String> {
    return Promise<String> { (fulfill, reject) in
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(4000), execute: {
            fulfill("2")
        })
    }
}

func promiseAsyncA(parameter: String) -> Promise<String> {
    return Promise<String>(constructor: { (fulfill, _) in
        fulfill(parameter + "promiseAsyncA")
    })
}

func promiseAsyncB(parameter: String) -> Promise<String> {
    return Promise<String>(constructor: { (fulfill, _) in
        fulfill(parameter + "promiseAsyncB")
    })
}

class PromiseSpec: QuickSpec {
    
    
    override func spec() {
        describe("Promise tests") {
            
            it("fulfill return the value") {
                
                let co = co_launch {
                    
                    let result = try await { testPromise1() }
                    
                    switch result {
                    case .fulfilled(let str):
                        expect(str).to(equal("123"))
                        break
                    case .rejected( _):
                        expect(false).to(beTrue())
                        break
                    }
                }
                
                waitUntil { done in
                    
                    co_launch {
                        
                        co.join()
                        done()
                    }
                    
                }
            }
            
            
            
            it("reject should return nil, and error.") {

                let co = co_launch {
                    
                    let result = try await { testPromise2() }
                    
                    switch result {
                    case .fulfilled(_ ):
                        expect(false).to(beTrue())
                        break
                    case .rejected(let error):
                        expect(error as NSError).to(equal(NSError(domain: "aa", code: -1, userInfo: nil)))
                        break
                    }
                }
                
                waitUntil(timeout: 2) { done in
                    
                    co_launch {
                        
                        co.join()
                        done()
                    }
                    
                }
            }
            
            it("test simple chained promise") {
                
                let promise = testPromise1()
                
                promise
                    .then(work: { (retStr) -> Data in
                        expect(retStr).to(equal("123"))
                        return retStr.data(using: String.Encoding.utf8)!
                    })
                    .then(work: { (data) -> String in
                        
                        let retStr = String(data: data, encoding: String.Encoding.utf8)!
                        expect(retStr).to(equal("123"))
                        return retStr
                    })
                
                var step = 0;
                promise
                    .catch(reject: { (error) in
                        expect(false).to(beTrue())
                    })
                    .then(work: { (retStr) -> Data in
                        step = 1;
                        expect(retStr).to(equal("123"))
                        return retStr.data(using: String.Encoding.utf8)!
                    })
                    .then(work: { (data) -> String in
                        step = 2;
                        let retStr = String(data: data, encoding: String.Encoding.utf8)!
                        expect(retStr).to(equal("123"))
                        return retStr
                    })
                
                waitUntil(timeout: 3, action: { (done) in
                    
                    expect(step).to(equal(2))
                    done()
                })
            }
            
            it("cancel a coroutine when await a promise") {
                
                let co = co_launch {
                    print("[\(NSDate())]====test begin")

                    let result = try await{ testPromise3() }
                    
                    switch result {
                    case .fulfilled(let str):
                        print("[\(NSDate())]====test error with fulfilled: \(str)")
                        break
                    case .rejected(let error):
                        print("[\(NSDate())]====test error with error: \(error)")
                        break
                    }
                    
                    // should be cancelled
                    expect(false).to(beTrue())
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    print("[\(NSDate())]====test error begin co cancel")
                    co.cancel()
                })
                
                waitUntil(timeout: 10, action: { (done) in
                    co_launch {
                        co.join()
                        print("[\(NSDate())]====test co is finished")
                        done()
                    }
                })
            }
            
            it("cancel a finished coroutine will do nothing") {
                
                let co = co_launch {
                    
                    let result = try await{ testPromise3() }
                    
                    switch result {
                    case .fulfilled(let str):
                        expect(str).to(equal("1234"))
                        break
                    case .rejected( _):
                        expect(false).to(beTrue())
                        break
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3100), execute: {
                    
                    co.cancel()
                    
                })
                
                waitUntil(timeout: 10, action: { (done) in
                    
                    co_launch {
                        co.join()
                        done()
                    }
                })
            }
            
            it("test concurrent await promise") {
                var step = 0;
                let co = co_launch {
                    
                    let begin = CACurrentMediaTime()
                    
                    let p1 = testPromise21()
                    let p2 = testPromise22()
                    
                    let r1 = try await { p1 }
                    switch r1 {
                    case .fulfilled(let str):
                        expect(str).to(equal("1"))
                        break
                    case .rejected(_):
                        expect(false).to(beTrue())
                        break
                    }
                    
                    
                    let r2 = try await { p2 }
                    switch r2 {
                    case .fulfilled(let str):
                        expect(str).to(equal("2"))
                        break
                    case .rejected(_):
                        expect(false).to(beTrue())
                        break
                    }
                    
                    let duration = CACurrentMediaTime() - begin
                    expect(duration < 5.5).to(beTrue())
                    step = 1;

                }
                
                waitUntil(timeout: 6, action: { (done) in
                    
                    co_launch {
                        co.join()
                        expect(step).to(equal(1))
                        done()
                    }
                })
            }
            
            it("test chained promise") {
                
                promiseAsyncA(parameter: "A")
                    .then { (msg)  in promiseAsyncB(parameter: msg) }
                    .then { (promiseB) -> Void in
                        expect(promiseB).to(equal("ApromiseAsyncApromiseAsyncB"))
                }
            }
            
            it("test co delay") {
                
                let queue = DispatchQueue(label: "queue")
                var step = 0
                let co = co_launch(queue: queue) {
                    
                    print("time before:\(Date())")
                    
                    try co_delay(3)
                    step = 1
                    print("time after:\(Date())")
                }
                
                waitUntil(timeout: 5, action: { (done) in
                    
                    co_launch {
                        co.join()
                        expect(step).to(equal(1))
                        done()
                    }
                })
            }
            
            it("test cancel co delay") {
                
                let queue = DispatchQueue(label: "queue")
                var step = 0
                let co = co_launch(queue: queue) {
                    
                    print("time before:\(Date())")
                    
                    try co_delay(3)
                    step = 1
                    print("time after:\(Date())")
                }
                
                waitUntil(timeout: 5, action: { (done) in
                    
                    co_launch {
                        co.cancelAndJoin()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                            expect(step).to(equal(0))
                            done()
                        })
                    }
                })
            }
        }
    }
}

