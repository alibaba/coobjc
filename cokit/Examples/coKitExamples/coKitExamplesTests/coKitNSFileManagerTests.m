//
//  coKitNSFileManagerTests.m
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
#import <cokit/NSFileManager+Coroutine.h>
#import <coobjc/co_tuple.h>

@interface coKitNSFileManagerTests : XCTestCase

@end

@implementation coKitNSFileManagerTests

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
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"test006"];
}

- (void)testCreateDir{
    
    XCTestExpectation *e = [self expectationWithDescription:@"test"];

    co_launch(^{
        for (int i = 0; i < 10; i++) {
            NSString *dirName = [NSString stringWithFormat:@"dir_%d", i];
            NSString *dirPath = [[self tempPath] stringByAppendingPathComponent:dirName];
            BOOL ret = [[NSFileManager defaultManager] co_createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:nil];
            
            XCTAssert(ret == YES);
            XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:dirPath]);
            
            BOOL isDir = NO;
            BOOL retValue = [[NSFileManager defaultManager] co_fileExistsAtPath:dirPath isDirectory:&isDir];
        
            XCTAssert(retValue);
            XCTAssert(isDir);
            
            [[NSFileManager defaultManager] co_removeItemAtPath:dirPath error:nil];
            
            XCTAssert(![[NSFileManager defaultManager] fileExistsAtPath:dirPath]);

            retValue = [[NSFileManager defaultManager] co_fileExistsAtPath:dirPath isDirectory:NULL];
            
            XCTAssert(!retValue);
        }
        
        for (int i = 0; i < 10; i++) {
            NSString *dirName = [NSString stringWithFormat:@"dir_%d", i];
            NSString *dirPath = [[self tempPath] stringByAppendingPathComponent:dirName];
            BOOL ret = [[NSFileManager defaultManager] co_createDirectoryAtURL:[NSURL fileURLWithPath:dirPath] withIntermediateDirectories:NO attributes:nil error:nil];
            
            XCTAssert(ret == YES);
            XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:dirPath]);
            
            BOOL isDir = NO;
            BOOL retValue = [[NSFileManager defaultManager] co_fileExistsAtPath:dirPath isDirectory:&isDir];
            
            XCTAssert(retValue);
            XCTAssert(isDir);
            
            [[NSFileManager defaultManager] co_removeItemAtPath:dirPath error:nil];
            
            XCTAssert(![[NSFileManager defaultManager] fileExistsAtPath:dirPath]);
            
            retValue = [[NSFileManager defaultManager] co_fileExistsAtPath:dirPath isDirectory:NULL];
            
            XCTAssert(!retValue);
        }
        
        
        
        [e fulfill];
    });
    [self waitForExpectations:@[e] timeout:1000];
}

@end
