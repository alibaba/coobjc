//
//  coobjcChannelTests.m
//  coobjcBaseExampleTests
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

#import <XCTest/XCTest.h>
#import <Specta/Specta.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import <coobjc/coobjc.h>


SpecBegin(coChannel)



describe(@"Channel tests", ^{
    it(@"Channel‘s buffcount is 0,  will blocking send.", ^{
        __block NSInteger step = 0;
        
        COChan *chan = [COChan chanWithBuffCount:0];
        
        co_launch(^{
            step = 1;
            [chan send:@111];
            expect(step).to.equal(4);
            step = 2;
        });
        
        
        co_launch(^{
            
            expect(step).to.equal(1);
            step = 3;
            id value = [chan receive_nonblock];
            expect(step).to.equal(3);
            step = 4;
            expect(value).to.equal(@111);
        });
        waitUntil(^(DoneCallback done) {
            dispatch_async(dispatch_get_main_queue(), ^{
                expect(step).to.equal(2);
                done();
            });
        });
    });
    
    it(@"Channel with buffcount will not blocking send.", ^{
        __block NSInteger step = 0;
        
        COChan *chan = [COChan chanWithBuffCount:1];
        
        co_launch(^{
            step = 1;
            expect(step).to.equal(1);
            [chan send:@111];
            expect(step).to.equal(1);
            step = 2;
        });
        
        
        co_launch(^{
            expect(step).to.equal(2);
            step = 3;
            id value = [chan receive_nonblock];
            expect(step).to.equal(3);
            step = 4;
            expect(value).to.equal(@111);

        });
        waitUntil(^(DoneCallback done) {
            dispatch_async(dispatch_get_main_queue(), ^{
                done();
            });
        });
    });
    
    it(@"Receive just before send.", ^{
        __block NSInteger step = 0;
        
        COChan *chan = [COChan chan];
        
        co_launch(^{
            step = 1;
            expect(step).to.equal(1);
            id value = [chan receive];
            expect(step).to.equal(4);
            expect(value).to.equal(@111);
            step = 2;
        });
        
        
        co_launch(^{
            expect(step).to.equal(1);
            step = 3;
            [chan send:@111];
            expect(step).to.equal(3);
            step = 4;
        });
        waitUntil(^(DoneCallback done) {
            dispatch_async(dispatch_get_main_queue(), ^{
                expect(step).to.equal(2);
                done();
            });
        });
    });
    
    it(@"Channel' buff is full,  will blocking send.", ^{
        __block NSInteger step = 0;
        
        COChan *chan = [COChan chanWithBuffCount:1];
        
        co_launch(^{
            step = 1;
            [chan send:@111];
            expect(step).to.equal(1);
            step = 2;
        });
        
        co_launch(^{
            expect(step).to.equal(2);
            step = 3;
            [chan send:@222];
            step = 4;
        });
        
        co_launch(^{
            expect(step).to.equal(3);
            id value = [chan receive_nonblock];
            expect(step).to.equal(3);
            expect(value).to.equal(@111);
            
            expect(step).to.equal(3);
            value = [chan receive_nonblock];
            expect(step).to.equal(3);
            expect(value).to.equal(@222);
        });
        waitUntil(^(DoneCallback done) {
            dispatch_async(dispatch_get_main_queue(), ^{
                expect(step).to.equal(4);
                done();
            });
        });
    });
    
    it(@"Channel can block muti coroutine use send.", ^{
        __block NSInteger step = 0;
        
        COChan *chan = [COChan chan];
        
        co_launch(^{
            step = 1;
            [chan send:@111];
            expect(step).to.equal(4);
            step = 5;
        });
        
        co_launch(^{
            expect(step).to.equal(1);
            step = 3;
            [chan send:@222];
            expect(step).to.equal(5);
            step = 6;
        });
        
        co_launch(^{
            expect(step).to.equal(3);
            id value = [chan receive_nonblock];
            expect(step).to.equal(3);
            expect(value).to.equal(@111);
            
            
            expect(step).to.equal(3);
            value = [chan receive_nonblock];
            expect(step).to.equal(3);
            expect(value).to.equal(@222);
            NSLog(@"after receive 2");
            step = 4;
        });
        waitUntil(^(DoneCallback done) {
            dispatch_async(dispatch_get_main_queue(), ^{
                expect(step).to.equal(6);
                done();
            });
        });
    });
    
    
    it(@"send non blocking will not block the coroutine.", ^{
        __block NSInteger step = 0;
        
        COChan *chan = [COChan chanWithBuffCount:1];
        
        co_launch(^{
            step = 1;
            [chan send_nonblock:@111];
            expect(step).to.equal(1);
            step = 2;
        });
        
        
        co_launch(^{
            expect(step).to.equal(2);
            step = 3;
            id value = [chan receive_nonblock];
            expect(step).to.equal(3);
            expect(value).to.equal(@111);
        });
        waitUntil(^(DoneCallback done) {
            dispatch_async(dispatch_get_main_queue(), ^{
                expect(step).to.equal(3);
                done();
            });
        });
    });
    
    it(@"Channel buff is full, send non blocking will abandon the value.", ^{
        __block NSInteger step = 0;
        
        COChan *chan = [COChan chan];
        
        co_launch(^{
            step = 1;
            [chan send_nonblock:@111];
            expect(step).to.equal(1);
            step = 2;
        });
        
        
        co_launch(^{
            expect(step).to.equal(2);
            step = 3;
            id value = [chan receive_nonblock];
            expect(step).to.equal(3);
            expect(value).to.equal(nil);
        });
        waitUntil(^(DoneCallback done) {
            dispatch_async(dispatch_get_main_queue(), ^{
                expect(step).to.equal(3);
                done();
            });
        });
    });
    
    it(@"receive shall block the coroutine, when there is no value send.", ^{
        __block NSInteger step = 0;
        
        COChan *chan = [COChan chanWithBuffCount:1];
        
        co_launch(^{
            step = 1;
            id value = [chan receive];
            expect(step).to.equal(4);
            expect(value).to.equal(@111);
            step = 2;
        });
        
        
        co_launch(^{
            expect(step).to.equal(1);
            step = 3;
            [chan send:@111];
            expect(step).to.equal(3);
            step = 4;
        });
        waitUntil(^(DoneCallback done) {
            dispatch_async(dispatch_get_main_queue(), ^{
                expect(step).to.equal(2);
                done();
            });
        });
    });
    
    it(@"receive can block muti coroutine.", ^{
        __block NSInteger step = 0;
        
        COChan *chan = [COChan chanWithBuffCount:1];
        
        co_launch(^{
            step = 1;
            id value = [chan receive];
            expect(step).to.equal(7);
            expect(value).to.equal(@111);
            step = 2;
        });
        
        co_launch(^{
            expect(step).to.equal(1);
            step = 3;
            id value = [chan receive];
            expect(step).to.equal(2);
            expect(value).to.equal(@222);
            step = 4;
        });
        
        
        co_launch(^{
            expect(step).to.equal(3);
            step = 5;
            [chan send:@111];
            expect(step).to.equal(5);

            step = 6;
            [chan send:@222];
            expect(step).to.equal(6);
            step = 7;
        });
        waitUntil(^(DoneCallback done) {
            dispatch_async(dispatch_get_main_queue(), ^{
                expect(step).to.equal(4);
                done();
            });
        });
    });
    
    it(@"receive_nonblock will not block the coroutine.", ^{
        __block NSInteger step = 0;
        
        COChan *chan = [COChan chanWithBuffCount:1];
        
        co_launch(^{
            step = 1;
            id value = [chan receive_nonblock];
            expect(step).to.equal(1);
            expect(value).to.equal(nil);
            step = 2;
        });
        
        co_launch(^{
            expect(step).to.equal(2);
            step = 3;

            [chan send_nonblock:@222];
            expect(step).to.equal(3);
            step = 4;
            
            id value = [chan receive_nonblock];
            expect(value).to.equal(@222);
        });
        
        
        waitUntil(^(DoneCallback done) {
            dispatch_async(dispatch_get_main_queue(), ^{
                done();
            });
        });
    });
    
    it(@"send and receive on muti thread.", ^{
        __block NSInteger receiveCount = 0;
        __block NSInteger receiveValue = 0;
        NSLock *lock =  [[NSLock alloc] init];
        
        __block NSInteger sendCount = 0;
        NSLock *lock1 =  [[NSLock alloc] init];
        
        COChan *chan = [COChan chanWithBuffCount:2];
        
        for (int i = 0; i < 2000; i++) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                co_launch(^{
                    id value = [chan receive];
                    [lock lock];
                    receiveCount ++;
                    receiveValue += [value integerValue];
                    [lock unlock];
                });
            });
        }
        
        for (int i = 0; i < 2000; i++) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                co_launch(^{
                    [chan send:@(i)];
                    [lock1 lock];
                    sendCount ++;
                    [lock1 unlock];
                });
            });
        }
        
        waitUntilTimeout(100, ^(DoneCallback done) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"end");
                expect(receiveCount).to.equal(2000);
                expect(receiveValue).to.equal(1999000);
                expect(sendCount).to.equal(2000);

                done();
            });
        });
    });
    
    
    it(@"expandableChan will not abandon values.", ^{
        __block NSInteger receiveCount = 0;
        __block NSInteger receiveValue = 0;
        
        __block NSInteger sendCount = 0;
        
        COChan *chan = [COChan expandableChan];
        
        for (int i = 0; i < 2000; i++) {
            co_launch(^{
                [chan send:@(i)];
                sendCount++;
            });
        }
        
        for (int i = 0; i < 2000; i++) {
            co_launch(^{
                id value = [chan receive];
                receiveCount++;
                receiveValue+=[value integerValue];
            });
        }
        
        waitUntilTimeout(100, ^(DoneCallback done) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                expect(receiveCount).to.equal(2000);
                expect(receiveValue).to.equal(1999000);
                expect(sendCount).to.equal(2000);
                done();
            });
        });
    });
    
});
SpecEnd
