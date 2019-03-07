//
//  coSwiftSequenceTests.swift
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


class SequenceSpec: QuickSpec {
    
    
    override func spec() {
        describe("Generator tests") {
            
            it("test sequence on same queue") {
                var step = 0;
                let gen = co_sequence(Int.self) {
                    var i = 0;
                    while true {
                        try yield { i }
                        step = i;
                        i += 1;
                    }
                }
                
                let co = co_launch {
                    
                    for i in 0..<10 {
                        let val = try gen.next()
                        expect(val).to(equal(i))
                    }
                    gen.cancel()
                }
                
                waitUntil { done in
                    
                    co_launch {
                        co.join()
                        gen.join()
                        expect(step).to(equal(9))
                        done()
                    }
                }
            }
            
            it("yield value chain") {
                
                var step = 0;
                let sq1 = co_sequence(Int.self) {
                    
                    var i = 0;
                    while true {
                        try yield { i }
                        step = i;
                        i+=1;
                    }
                }
                
                let sq2 = co_sequence(Int.self) {
                    
                    while true {
                        try yield { try sq1.next() }
                    }
                }
                
                let co = co_launch {
                    
                    for i in 0..<10 {
                        let val = try sq2.next()
                        expect(val).to(equal(i))
                    }
                    sq1.cancel()
                    sq2.cancel()
                }
                
                waitUntil { done in
                    
                    co_launch {
                        co.join()
                        expect(step).to(equal(9))
                        done()
                    }
                }
            }
        }
    }
}
