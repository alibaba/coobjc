//
//  coKitXMLParserTests.m
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
#import <coobjc/coobjc.h>
#import <cokit/NSXMLParser+Coroutine.h>

@interface coKitXMLParserTests : XCTestCase

@end

@implementation coKitXMLParserTests

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

- (void)testXMLParse{
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    COCoroutine *parse_generator = [NSXMLParser co_parseContentsOfURL:[NSURL URLWithString:@"http://xxx.xml"]];
    co_launch(^{
        COXMLItem *item = nil;
        int testsuitesCount = 0;
        int testsuiteCount = 0;
        int testcaseCount = 0;
        while (1) {
//            item = [parse_generator next];
            if (item.itemType == COXMLItemDidStartElement) {
                if ([item.elementName isEqualToString:@"testsuites"]) {
                    testsuitesCount++;
                }
                if ([item.elementName isEqualToString:@"testsuite"]) {
                    testsuiteCount++;
                }
                if ([item.elementName isEqualToString:@"testcase"]) {
                    testcaseCount++;
                }
            }
            NSLog(@"%@", item);
            if (item == nil || item.itemType == COXMLItemError || item.itemType == COXMLItemEnd) {
                break;
            }
        }
        
        XCTAssert(testsuitesCount == 1);
        XCTAssert(testsuiteCount == 4);
        XCTAssert(testcaseCount == 12);
        [e fulfill];
    });
    
    [self waitForExpectations:@[e] timeout:1000];
}

@end
