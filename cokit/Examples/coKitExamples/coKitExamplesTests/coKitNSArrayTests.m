//
//  coKitNSArrayTests.m
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
#import <cokit/NSArray+Coroutine.h>

@interface coKitNSArrayTests : XCTestCase

@end

@implementation coKitNSArrayTests

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
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"test001"];
}

- (void)testNSArrayInitializeFromFile{
    
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    
    co_launch(^{
        for (int i = 0; i < 100; i++) {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            for (int j = 0; j < 10; j++) {
                [list addObject:@(rand() % 1000)];
            }
            NSArray *tmpList = [list copy];
            NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file_%d", i]];
            [tmpList co_writeToFile:filePath atomically:YES];
            
            XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
            
            NSArray *resultList = [[NSArray alloc] co_initWithContentsOfFile:filePath];
            
            XCTAssert(resultList.count == list.count);
            
            for (int j = 0; j < 10; j++) {
                XCTAssert([list[j] intValue] == [resultList[j] intValue]);
            }
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        for (int i = 0; i < 100; i++) {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            for (int j = 0; j < 10; j++) {
                [list addObject:@(rand() % 1000)];
            }
            NSArray *tmpList = [list copy];
            NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file_%d", i]];
            [tmpList co_writeToURL:[NSURL fileURLWithPath:filePath] error:nil];
            
            XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
            
            NSArray *resultList = [[NSArray alloc] co_initWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
            
            XCTAssert(resultList.count == list.count);
            
            for (int j = 0; j < 10; j++) {
                XCTAssert([list[j] intValue] == [resultList[j] intValue]);
            }
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        for (int i = 0; i < 100; i++) {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            for (int j = 0; j < 10; j++) {
                [list addObject:@(rand() % 1000)];
            }
            NSArray *tmpList = [list copy];
            NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file_%d", i]];
            [tmpList co_writeToURL:[NSURL fileURLWithPath:filePath] atomically:YES];
            
            XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
            
            NSArray *resultList = [NSArray co_arrayWithContentsOfFile:filePath];
            
            XCTAssert(resultList.count == list.count);
            
            for (int j = 0; j < 10; j++) {
                XCTAssert([list[j] intValue] == [resultList[j] intValue]);
            }
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        for (int i = 0; i < 100; i++) {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            for (int j = 0; j < 10; j++) {
                [list addObject:@(rand() % 1000)];
            }
            NSArray *tmpList = [list copy];
            NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file_%d", i]];
            [tmpList co_writeToFile:filePath atomically:YES];
            
            XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
            
            NSArray *resultList = [NSArray co_arrayWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:nil];
            
            XCTAssert(resultList.count == list.count);
            
            for (int j = 0; j < 10; j++) {
                XCTAssert([list[j] intValue] == [resultList[j] intValue]);
            }
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        [e fulfill];
    });
    
    [self waitForExpectations:@[e] timeout:1000];
}


- (void)testNSMutableArrayInitializeFromFile{
    
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    
    co_launch(^{
        for (int i = 0; i < 100; i++) {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            for (int j = 0; j < 10; j++) {
                [list addObject:@(rand() % 1000)];
            }
            NSArray *tmpList = [list copy];
            NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file1_%d", i]];
            [tmpList co_writeToFile:filePath atomically:YES];
            
            XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
            
            NSMutableArray *resultList = [[NSMutableArray alloc] co_initWithContentsOfFile:filePath];
            
            XCTAssert(resultList.count == list.count);
            
            for (int j = 0; j < 10; j++) {
                XCTAssert([list[j] intValue] == [resultList[j] intValue]);
            }
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        for (int i = 0; i < 100; i++) {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            for (int j = 0; j < 10; j++) {
                [list addObject:@(rand() % 1000)];
            }
            NSArray *tmpList = [list copy];
            NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file1_%d", i]];
            [tmpList co_writeToFile:filePath atomically:YES];
            
            XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
            
            NSMutableArray *resultList = [[NSMutableArray alloc] co_initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:nil];
            
            XCTAssert(resultList.count == list.count);
            
            for (int j = 0; j < 10; j++) {
                XCTAssert([list[j] intValue] == [resultList[j] intValue]);
            }
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        for (int i = 0; i < 100; i++) {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            for (int j = 0; j < 10; j++) {
                [list addObject:@(rand() % 1000)];
            }
            NSArray *tmpList = [list copy];
            NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file1_%d", i]];
            [tmpList co_writeToFile:filePath atomically:YES];
            
            XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
            
            NSMutableArray *resultList = [NSMutableArray co_arrayWithContentsOfFile:filePath];
            
            XCTAssert(resultList.count == list.count);
            
            for (int j = 0; j < 10; j++) {
                XCTAssert([list[j] intValue] == [resultList[j] intValue]);
            }
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        for (int i = 0; i < 100; i++) {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            for (int j = 0; j < 10; j++) {
                [list addObject:@(rand() % 1000)];
            }
            NSArray *tmpList = [list copy];
            NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file1_%d", i]];
            [tmpList co_writeToFile:filePath atomically:YES];
            
            XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
            
            NSMutableArray *resultList = [NSMutableArray co_arrayWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:nil];
            
            XCTAssert(resultList.count == list.count);
            
            for (int j = 0; j < 10; j++) {
                XCTAssert([list[j] intValue] == [resultList[j] intValue]);
            }
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        [e fulfill];
    });
    
    [self waitForExpectations:@[e] timeout:1000];
}

@end
