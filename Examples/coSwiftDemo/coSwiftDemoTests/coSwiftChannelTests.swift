//
//  coSwiftChannelTests.swift
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


class ChannelSpec: QuickSpec {
    
    
    override func spec() {
        describe("Channel tests") {
            
            it("Channel‘s buffcount is 0,  will blocking send.") {
                
                var step = 0;
                
                let chan = Chan<String>(buffCount: 0)
                
                let co = co_launch {
                    step = 1
                    try chan.send(val: "111")
                    expect(step).to(equal(4))
                    step = 2
                }
                
                let co1 = co_launch {
                    expect(step).to(equal(1))
                    step = 3
                    let val = chan.receive_nonblock()
                    expect(val).to(equal("111"))
                    expect(step).to(equal(3))
                    step = 4
                }
                
                waitUntil { done in
                    
                    co_launch {
                        co.join()
                        co1.join()
                        expect(step).to(equal(2))
                        done()
                    }
                }
            }
            
            it("Channel with buffcount will not blocking send.") {
                var step = 0;
                
                let chan = Chan<String>(buffCount: 1)
                
                let co = co_launch {
                    step = 1
                    try chan.send(val: "111")
                    expect(step).to(equal(1))
                    step = 2
                }
                
                let co1 = co_launch {
                    expect(step).to(equal(2))
                    step = 3
                    let val = chan.receive_nonblock()
                    expect(val).to(equal("111"))
                    expect(step).to(equal(3))
                    step = 4
                }
                
                waitUntil { done in
                    
                    co_launch {
                        co.join()
                        co1.join()
                        expect(step).to(equal(4))
                        done()
                    }
                }
            }
            
            it("Receive just before send.") {
                var step = 0;
                
                let chan = Chan<String>(buffCount: 0)
                
                let co = co_launch {
                    step = 1
                    let val = try chan.receive()
                    expect(step).to(equal(4))
                    expect(val).to(equal("111"))
                    step = 2
                }
                
                let co1 = co_launch {
                    expect(step).to(equal(1))
                    step = 3
                    try chan.send(val: "111")
                    expect(step).to(equal(3))
                    step = 4
                }
                
                waitUntil { done in
                    
                    co_launch {
                        co.join()
                        co1.join()
                        expect(step).to(equal(2))
                        done()
                    }
                }
            }
            
            it("Channel' buff is full,  will blocking send.") {
                var step = 0;
                
                let chan = Chan<String>(buffCount: 1)
                
                let co = co_launch {
                    step = 1
                    try chan.send(val: "111")
                    expect(step).to(equal(1))
                    step = 2
                }
                
                let co1 = co_launch {
                    expect(step).to(equal(2))
                    step = 3
                    try chan.send(val: "222")
                    expect(step).to(equal(5))
                    step = 4
                }
                
                let co2 = co_launch {
                    expect(step).to(equal(3))
                    let val = chan.receive_nonblock()
                    expect(val).to(equal("111"))
                    expect(step).to(equal(3))
                    
                    let val2 = chan.receive_nonblock()
                    expect(val2).to(equal("222"))
                    expect(step).to(equal(3))
                    step = 5
                }
                
                waitUntil { done in
                    
                    co_launch {
                        co.join()
                        co1.join()
                        co2.join()

                        expect(step).to(equal(4))
                        done()
                    }
                }
            }

            
            it("Channel can block muti coroutine use send.") {
                var step = 0;
                
                let chan = Chan<String>(buffCount: 0)
                
                let co = co_launch {
                    step = 1
                    try chan.send(val: "111")
                    expect(step).to(equal(4))
                    step = 5
                }
                
                let co1 = co_launch {
                    expect(step).to(equal(1))
                    step = 3
                    try chan.send(val: "222")
                    expect(step).to(equal(5))
                    step = 6
                }
                
                let co2 = co_launch {
                    expect(step).to(equal(3))
                    let val = chan.receive_nonblock()
                    expect(val).to(equal("111"))
                    expect(step).to(equal(3))
                    
                    let val2 = chan.receive_nonblock()
                    expect(val2).to(equal("222"))
                    expect(step).to(equal(3))
                    step = 4
                }
                
                waitUntil { done in
                    
                    co_launch {
                        co.join()
                        co1.join()
                        co2.join()
                        
                        expect(step).to(equal(6))
                        done()
                    }
                }
            }
            
            it("Send non blocking will not block the coroutine.") {
                var step = 0;
                
                let chan = Chan<String>(buffCount: 1)
                
                let co = co_launch {
                    step = 1
                    chan.send_nonblock(val: "111")
                    expect(step).to(equal(1))
                    step = 2
                }
                
                let co1 = co_launch {
                    expect(step).to(equal(2))
                    step = 3
                    let val = chan.receive_nonblock()
                    expect(step).to(equal(3))
                    expect(val).to(equal("111"))
                    step = 4
                }
                
                waitUntil { done in
                    
                    co_launch {
                        co.join()
                        co1.join()
                        expect(step).to(equal(4))
                        done()
                    }
                }
            }
            
            it("Channel buff is full, send non blocking will abandon the value.") {
                var step = 0;
                
                let chan = Chan<String>(buffCount: 0)
                
                let co = co_launch {
                    step = 1
                    chan.send_nonblock(val: "111")
                    expect(step).to(equal(1))
                    step = 2
                }
                
                let co1 = co_launch {
                    expect(step).to(equal(2))
                    step = 3
                    let val = chan.receive_nonblock()
                    expect(step).to(equal(3))
                    expect(val).to(beNil())
                    step = 4
                }
                
                waitUntil { done in
                    
                    co_launch {
                        co.join()
                        co1.join()
                        expect(step).to(equal(4))
                        done()
                    }
                }
            }
            
            
            it("receive shall block the coroutine, when there is no value send.") {
                var step = 0;
                
                let chan = Chan<String>(buffCount: 1)
                
                let co = co_launch {
                    step = 1
                    let val = try chan.receive()
                    expect(val).to(equal("111"))
                    expect(step).to(equal(4))
                    step = 2
                }
                
                let co1 = co_launch {
                    expect(step).to(equal(1))
                    step = 3
                    try chan.send(val: "111")
                    expect(step).to(equal(3))
                    step = 4
                }
                
                waitUntil { done in
                    
                    co_launch {
                        co.join()
                        co1.join()
                        expect(step).to(equal(2))
                        done()
                    }
                }
            }
            
            it("Receive can block muti coroutine.") {
                var step = 0;
                
                let chan = Chan<String>(buffCount: 1)
                
                let co = co_launch {
                    step = 1
                    let val = try chan.receive()
                    expect(val).to(equal("111"))
                    expect(step).to(equal(7))
                    step = 2
                }
                
                let co1 = co_launch {
                    expect(step).to(equal(1))
                    step = 3
                    let val = try chan.receive()
                    expect(step).to(equal(2))
                    expect(val).to(equal("222"))
                    step = 4
                }
                
                let co2 = co_launch {
                    expect(step).to(equal(3))
                    step = 5
                    try chan.send(val: "111")
                    expect(step).to(equal(5))
                    
                    step = 6
                    try chan.send(val: "222")
                    expect(step).to(equal(6))
                    step = 7
                }
                
                waitUntil { done in
                    
                    co_launch {
                        co.join()
                        co1.join()
                        co2.join()
                        
                        expect(step).to(equal(4))
                        done()
                    }
                }
            }
            
            it("receive_nonblock will not block the coroutine.") {
                var step = 0;
                
                let chan = Chan<String>(buffCount: 1)
                
                let co = co_launch {
                    step = 1
                    let val = chan.receive_nonblock()
                    expect(val).to(beNil())
                    expect(step).to(equal(1))
                    step = 2
                }
                
                let co1 = co_launch {
                    expect(step).to(equal(2))
                    step = 3
                    
                    chan.send_nonblock(val: "222")
                    expect(step).to(equal(3))
                    step = 4;
                    
                    let val = chan.receive_nonblock()
                    expect(val).to(equal("222"))
                    step = 5
                }
                
                waitUntil { done in
                    
                    co_launch {
                        co.join()
                        co1.join()
                        expect(step).to(equal(5))
                        done()
                    }
                }
            }
            
            
            it("send and receive on muti thread.") {

                var receiveCount = 0
                var receiveValue = 0
                
                let lock = NSLock()
                var sendCout = 0;
                let lock1 = NSLock()
                
                let chan = Chan<Int>(buffCount: 2)
                
                var coList: [Coroutine] = []
                
                for i in 0..<2000 {
                    
                    let co = co_launch(queue: DispatchQueue.global()) {
                        
                        let val = try chan.receive()
                        
                        do {
                            lock.lock()
                            defer { lock.unlock() }
                            receiveCount += 1
                            receiveValue += val
                        }
                    }
                    coList.append(co)
                }
                
                for i in 0..<2000 {
                    
                    let co = co_launch(queue: DispatchQueue.global()) {
                        
                        try chan.send(val: i)
                        
                        do {
                            lock1.lock()
                            defer { lock1.unlock() }
                            sendCout += 1
                        }
                    }
                    coList.append(co)
                }
                
                
                
                waitUntil(timeout: 100) { done in
                    
                    co_launch {
                        
                        for co in coList {
                            co.join()
                        }
                        expect(receiveCount).to(equal(2000))
                        expect(receiveValue).to(equal(1999000))
                        expect(sendCout).to(equal(2000))

                        done()
                    }
                }
            }
            
            
            it("expandable channel will not abandon values.") {
                
                var receiveCount = 0
                var receiveValue = 0
                
                let lock = NSLock()
                var sendCout = 0;
                let lock1 = NSLock()
                
                let chan = Chan<Int>.expandable()
                
                var coList: [Coroutine] = []
                
                for i in 0..<2000 {
                    
                    let co = co_launch(queue: DispatchQueue.global()) {
                        
                        
                        try chan.send(val: i)
                        
                        do {
                            lock1.lock()
                            defer { lock1.unlock() }
                            sendCout += 1
                        }

                        
                    }
                    coList.append(co)
                }
                
                for i in 0..<2000 {
                    
                    let co = co_launch(queue: DispatchQueue.global()) {
                        
                        
                        let val = try chan.receive()
                        
                        do {
                            lock.lock()
                            defer { lock.unlock() }
                            receiveCount += 1
                            receiveValue += val
                        }
                    }
                    coList.append(co)
                }
                
                
                
                waitUntil(timeout: 100) { done in
                    
                    co_launch {
                        
                        for co in coList {
                            co.join()
                        }
                        expect(receiveCount).to(equal(2000))
                        expect(receiveValue).to(equal(1999000))
                        expect(sendCout).to(equal(2000))
                        
                        done()
                    }
                }
            }
        }
    }

}
