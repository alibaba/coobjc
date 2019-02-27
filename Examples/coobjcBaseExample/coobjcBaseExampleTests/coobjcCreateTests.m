//
//  coobjcCreateTests.m
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
#import <coobjc.h>

/*
SpecBegin(coCreate)
    describe(@"create with co_create", ^{
        it(@"create with default queue", ^{
            __block int val = 0;
            COCoroutine *co = co_create(^{
                val++;
                NSLog(@"test");
            });
            XCTAssert(co != nil);
            waitUntil(^(DoneCallback done) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    XCTAssert(val == 0);
                    [co resume];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        XCTAssert(val == 1);
                        done();
                    });
                });
            });
        });
        it(@"create with custom queue", ^{
            __block int val = 0;
            dispatch_queue_t q = dispatch_queue_create("test", NULL);
            COCoroutine *co = co_create_onqueue(q, ^{
                val++;
                NSLog(@"test");
            });
            XCTAssert(co != nil);
            waitUntil(^(DoneCallback done) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    XCTAssert(val == 0);
                    [co resume];
                    dispatch_async(q, ^{
                        XCTAssert(val == 1);
                        done();
                    });
                });
            });
        });
        it(@"nest create with same queue", ^{
            __block int val = 0;
            __block COCoroutine *co1 = nil;
            
            COCoroutine *co = co_create(^{
                co1 = co_create(^{
                    val++;
                    NSLog(@"test");
                });
                [co1 resume];
            });
            XCTAssert(co != nil);
            XCTAssert(co1 == nil);
            waitUntil(^(DoneCallback done) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    XCTAssert(co1 == nil);
                    [co resume];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        XCTAssert(co1 != nil);
                        [co1 resume];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            XCTAssert(val == 1);
                            done();
                        });
                    });
                });
            });
        });
        it(@"nest create with different queue", ^{
            __block int val = 0;
            __block COCoroutine *co1 = nil;
            dispatch_queue_t q = dispatch_queue_create("test", NULL);
            
            COCoroutine *co = co_create(^{
                co1 = co_create_onqueue(q, ^{
                    val++;
                    NSLog(@"test");
                });
            });
            XCTAssert(co != nil);
            XCTAssert(co1 == nil);
            waitUntil(^(DoneCallback done) {
                XCTAssert(co1 == nil);
                [co resume];
                dispatch_async(dispatch_get_main_queue(), ^{
                    dispatch_async(q, ^{
                        XCTAssert(co1 != nil);
                        [co1 resume];
                        dispatch_async(q, ^{
                            XCTAssert(val == 1);
                            done();
                        });
                    });
                });
            });
        });
    });

    describe(@"create with co_launch", ^{
        it(@"launch with default queue", ^{
            __block int val = 0;
            co_launch(^{
                val++;
                NSLog(@"test");
            });
            waitUntil(^(DoneCallback done) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    XCTAssert(val == 1);
                    done();
                });
            });
        });
        it(@"create with custom queue", ^{
            __block int val = 0;
            dispatch_queue_t q = dispatch_queue_create("test", NULL);
            co_launch_onqueue(q, ^{
                val++;
                NSLog(@"test");
            });
            waitUntil(^(DoneCallback done) {
                dispatch_async(q, ^{
                    XCTAssert(val == 1);
                    done();
                });
            });
        });
        it(@"nest create with same queue", ^{
            __block int val = 0;
            
            co_launch(^{
                co_launch(^{
                    val++;
                    NSLog(@"test");
                });
            });
            waitUntil(^(DoneCallback done) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        XCTAssert(val == 1);
                        done();
                    });
                });
            });
        });
        it(@"nest create with different queue", ^{
            __block int val = 0;
            dispatch_queue_t q = dispatch_queue_create("test", NULL);
            
            co_launch(^{
                co_launch_onqueue(q, ^{
                    val++;
                    NSLog(@"test");
                });
            });
            waitUntil(^(DoneCallback done) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    dispatch_async(q, ^{
                        dispatch_async(q, ^{
                            XCTAssert(val == 1);
                            done();
                        });
                    });
                });
            });
        });
    });
SpecEnd
*/
