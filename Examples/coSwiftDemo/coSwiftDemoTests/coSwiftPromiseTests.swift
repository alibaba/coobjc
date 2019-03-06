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
        promise.fulfill(value: "1234")
    }
    
    promise.onCancel { (promise) in
        timer.invalidate()
    }
    return promise
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
                    
                    _ = try await{ testPromise3() }
                    
                    // should be cancelled
                    expect(false).to(beTrue())
                }
                
                waitUntil(timeout: 5, action: { (done) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                        
                        co.cancel()
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                            done()
                        })
                    })
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
                
                waitUntil(timeout: 5, action: { (done) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3100), execute: {
                        
                        co.cancel()
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
                            done()
                        })
                    })
                })
            }
        }
    }
}

