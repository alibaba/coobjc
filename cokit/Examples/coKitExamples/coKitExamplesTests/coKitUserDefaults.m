//
//  coKitUserDefaults.m
//  coKitExamplesTests
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
#import <cokit/NSUserDefaults+Coroutine.h>
#import <coobjc/coobjc.h>

@interface coKitUserDefaults : XCTestCase

@end

@implementation coKitUserDefaults

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testSetObjects{
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    
    co_launch(^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults co_setInteger:1000 forKey:@"int1"];
        
        NSInteger val = [defaults integerForKey:@"int1"];
        XCTAssert(1000 == val);
        
        [defaults co_setBool:YES forKey:@"bool1"];
        BOOL val1 = [defaults boolForKey:@"bool1"];
        XCTAssert(val1 == YES);
        
        [defaults co_setDouble:10.0 forKey:@"double1"];
        double double1 = [defaults doubleForKey:@"double1"];
        XCTAssert(fabs(double1 - 10) <= 0.00001);
        
        [defaults co_setObject:@"hello world" forKey:@"string1"];
        NSString *string1 = [defaults objectForKey:@"string1"];
        XCTAssert([string1 isEqualToString:@"hello world"]);
        
        [e fulfill];
    });
    
    [self waitForExpectations:@[e] timeout:1000];
}

- (void)testGetObjects{
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    
    co_launch(^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults co_setInteger:1000 forKey:@"int1"];
        
        NSInteger val = [defaults co_integerForKey:@"int1"];
        XCTAssert(1000 == val);
        
        [defaults co_setBool:YES forKey:@"bool1"];
        BOOL val1 = [defaults co_boolForKey:@"bool1"];
        XCTAssert(val1 == YES);
        
        [defaults co_setDouble:10.0 forKey:@"double1"];
        double double1 = [defaults co_doubleForKey:@"double1"];
        XCTAssert(fabs(double1 - 10) <= 0.00001);
        
        [defaults co_setObject:@"hello world" forKey:@"string1"];
        NSString *string1 = [defaults co_objectForKey:@"string1"];
        XCTAssert([string1 isEqualToString:@"hello world"]);
        
        [e fulfill];
    });
    
    [self waitForExpectations:@[e] timeout:1000];
}

@end
