//
//  coKitExamplesTests.m
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
#import <cokit/UIImage+Coroutine.h>

@interface coKitExamplesTests : XCTestCase

@end

@implementation coKitExamplesTests

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
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    co_launch(^{
        UIImage *image = await([UIImage async_imageWithContentsOfFileNamed:@"home"]);
        NSAssert(image != nil, @"test");
        
        image = await([UIImage async_imageWithContentsOfFileNamed:@"home1"]);
        NSAssert(image != nil, @"test1");
        
        image = await([UIImage async_imageWithContentsOfFileNamed:@"home2"]);
        NSAssert(image != nil, @"test2");
        
        image = await([UIImage async_imageWithContentsOfFileNamed:@"home.png"]);
        NSAssert(image != nil, @"test");
        
        image = await([UIImage async_imageWithContentsOfFileNamed:@"home1.png"]);
        NSAssert(image != nil, @"test1");
        
        image = await([UIImage async_imageWithContentsOfFileNamed:@"home2.png"]);
        NSAssert(image != nil, @"test2");
        
        image = await([UIImage async_imageWithContentsOfFileNamed:@"home@2x.png"]);
        NSAssert(image == nil, @"test");
        
        image = await([UIImage async_imageWithContentsOfFileNamed:@"home1@3x.png"]);
        NSAssert(image == nil, @"test1");
        
        image = await([UIImage async_imageWithContentsOfFileNamed:@"home2@2x.png"]);
        NSAssert(image == nil, @"test2");
        [e fulfill];
    });
    
    [self waitForExpectations:@[e] timeout:10];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
