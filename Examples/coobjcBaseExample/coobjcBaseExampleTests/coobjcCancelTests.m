//
//  coobjcCancelTests.m
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

SpecBegin(coCancel)

describe(@"cancel in the same thread", ^{
    it(@"tes cancel", ^{
        __block int val = 0;
        COCoroutine *co = co_launch(^{
            val++;
            NSLog(@"before");
            co_delay(1);
            NSLog(@"after");
            if (!co_isActive()) return;
            val++;
        });
        XCTAssert(val == 0);
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [co cancel];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    XCTAssert(val == 1);
                    done();
                });
                
            });
        });
    });
    
    
    it(@"cancel after routine done will do nothing", ^{
        __block int val = 0;
        COCoroutine *co = co_launch(^{
            val++;
            co_delay(1.0);
            if (!co_isActive()) return;
            val++;
        });
        XCTAssert(val == 0);
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                XCTAssert(val == 2);
                [co cancel];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    XCTAssert(val == 2);
                    done();
                });
            });
        });
    });
    
    
    it(@"cancel after routine done will do nothing", ^{
        __block int val = 0;
        COCoroutine *co = co_launch(^{
            val++;
            co_delay(1.0);
            if (!co_isActive()) return;
            val++;
        });
        XCTAssert(val == 0);
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                XCTAssert(val == 2);
                [co cancel];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    XCTAssert(val == 2);
                    done();
                });
            });
        });
    });
});

SpecEnd
