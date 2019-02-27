//
//  coKitJsonTests.m
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
#import <cokit/NSDictionary+Coroutine.h>
#import <cokit/NSJSONSerialization+Coroutine.h>
#import <cokit/NSArray+Coroutine.h>
#import <cokit/NSData+Coroutine.h>

@interface coKitJsonTests : XCTestCase

@end

@implementation coKitJsonTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self tempPath]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[self tempPath] withIntermediateDirectories:NO attributes:nil error:nil];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [[NSFileManager defaultManager] removeItemAtPath:[self tempPath] error:nil];
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

- (NSString*)tempPath{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"test009"];
}


- (void)testJSONParse{
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    
    co_launch(^{
        NSString *testJSONPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
        
        NSData *data = [NSData co_dataWithContentsOfFile:testJSONPath];
        
        XCTAssert(data.length > 0);
        
        NSDictionary *dict = [NSJSONSerialization co_JSONObjectWithData:data options:0 error:nil];
        
        XCTAssert([dict isKindOfClass:[NSDictionary class]]);
        
        NSDictionary *dict1 = dict[@"glossary"];
        XCTAssert(dict1.count > 0);
        
        NSDictionary *dict2 = dict1[@"GlossDiv"];
        XCTAssert(dict2.count > 0);
        
        NSDictionary *dict3 = dict2[@"GlossList"];
        XCTAssert(dict3.count > 0);
        
        [e fulfill];
    });
    
    [self waitForExpectations:@[e] timeout:10];
}

- (void)testJSONGenerator{
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    
    co_launch(^{
        NSString *testJSONPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
        
        NSData *data = [NSData co_dataWithContentsOfFile:testJSONPath];
        
        XCTAssert(data.length > 0);
        
        NSDictionary *dict = [NSJSONSerialization co_JSONObjectWithData:data options:0 error:nil];
        
        XCTAssert([dict isKindOfClass:[NSDictionary class]]);
        
        NSData *resultData = [NSJSONSerialization co_dataWithJSONObject:dict options:0 error:nil];
        
        XCTAssert(resultData.length > 0);
        
        NSString *jsonString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
        
        XCTAssert([jsonString rangeOfString:@"glossary"].location != NSNotFound);
    
        XCTAssert([jsonString rangeOfString:@"SGML"].location != NSNotFound);

        [e fulfill];
    });
    
    [self waitForExpectations:@[e] timeout:10];
}

@end
