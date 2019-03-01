//
//  coobjcDelayTests.m
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
#import "coobjcCommon.h"

SpecBegin(coDelay)

describe(@"test delay", ^{
    it(@"delay must run in coroutine", ^{
        int exception = 0;
        @try{
            co_delay(1);
        }@catch(NSException *e){
            exception++;
        }
        XCTAssert(exception == 1);
        NSTimeInterval duration = 3;
        __block NSTimeInterval realDuration = 0;
        co_launch(^{
            NSTimeInterval begin = [[NSDate date] timeIntervalSince1970];
            co_delay(3);
            realDuration = [[NSDate date] timeIntervalSince1970] - begin;
        });
        waitUntilTimeout(5, ^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                XCTAssert(fabs(duration - realDuration) < 0.1);
                done();
            });
        });
    });
});

SpecEnd
