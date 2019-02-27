//
//  coKitArchieveTests.m
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
#import <cokit/NSKeyedArchiver+Coroutine.h>
#import <cokit/NSArray+Coroutine.h>
#import <cokit/NSData+Coroutine.h>

@interface coKitArchieveTests : XCTestCase

@end

@implementation coKitArchieveTests

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
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"test010"];
}

- (void)testArchieve{
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    
    co_launch(^{
        for (int i = 0; i < 10; i++) {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            for (int j = 0; j < 10; j++) {
                [list addObject:@(rand() % 1000)];
            }
            NSArray *tmpList = [list copy];
            NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file_%d", i]];
            [NSKeyedArchiver co_archiveRootObject:tmpList toFile:filePath];
            
            XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
            
            NSArray *resultList = [NSKeyedUnarchiver co_unarchiveObjectWithFile:filePath];
            
            XCTAssert(resultList.count == list.count);
            
            for (int j = 0; j < 10; j++) {
                XCTAssert([list[j] intValue] == [resultList[j] intValue]);
            }
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        [e fulfill];
    });
    
    [self waitForExpectations:@[e] timeout:10];
}


@end
