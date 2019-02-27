//
//  coKitURLConnectionTests.m
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
#import <cokit/NSURLConnection+Coroutine.h>
#import <coobjc/coobjc.h>
#import <cokit/NSJSONSerialization+Coroutine.h>

@interface coKitURLConnectionTests : XCTestCase

@end

@implementation coKitURLConnectionTests

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

- (void)testRequest{
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    
    co_launch(^{
        NSURLResponse *response = nil;
        NSData *data = [NSURLConnection co_sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/DaveGamble/cJSON/master/tests/inputs/test1"]] response:&response error:nil];
        
        XCTAssert(response != nil);
        XCTAssert(data.length > 0);
        
        NSDictionary *dict = [NSJSONSerialization co_JSONObjectWithData:data options:0 error:nil];
        
        XCTAssert(dict.count > 0);
        XCTAssert([(NSDictionary*)dict[@"glossary"] count] > 0);
        [e fulfill];
    });
    
    [self waitForExpectations:@[e] timeout:1000];
}

- (void)testRequest404{
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    
    co_launch(^{
        NSURLResponse *response = nil;
        NSData *data = [NSURLConnection co_sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/DaveGamble/cJSON/master/tests/inputs/test11111"]] response:&response error:nil];
        
        XCTAssert([(NSHTTPURLResponse*)response statusCode] == 404);
        [e fulfill];
    });
    
    [self waitForExpectations:@[e] timeout:1000];
}


@end
