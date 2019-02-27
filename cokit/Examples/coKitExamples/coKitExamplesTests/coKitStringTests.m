//
//  coKitStringTests.m
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
#import <cokit/NSString+Coroutine.h>

@interface coKitStringTests : XCTestCase

@end

@implementation coKitStringTests

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
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"test100"];
}

- (void)testStringWrite{
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    
    co_launch(^{
        for (int i = 0; i < 101; i++) {
            NSMutableString *mutlContent = [[NSMutableString alloc] init];
            for (int j = 0; j < 10; j++) {
                [mutlContent appendFormat:@"%d_", rand()];
            }
            NSString *tmpStr = [mutlContent copy];
            NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file_%d", i]];
            [tmpStr co_writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        
        for (int i = 0; i < 101; i++) {
            
            NSMutableString *mutlContent = [[NSMutableString alloc] init];
            for (int j = 0; j < 10; j++) {
                [mutlContent appendFormat:@"%d_", rand()];
            }
            NSString *tmpStr = [mutlContent copy];
            NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file1_%d", i]];
            [tmpStr co_writeToURL:[NSURL fileURLWithPath:filePath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            
        }
        
        
        [e fulfill];
    });
    
    [self waitForExpectations:@[e] timeout:1000];
}

- (void)testStringRead{
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    
    co_launch(^{
        for (int i = 0; i < 101; i++) {
            NSMutableString *mutlContent = [[NSMutableString alloc] init];
            for (int j = 0; j < 10; j++) {
                [mutlContent appendFormat:@"%d_", rand()];
            }
            NSString *tmpStr = [mutlContent copy];
            NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file_%d", i]];
            [tmpStr co_writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
            
            NSString *retStr = [NSString co_stringWithContentsOfFile:filePath usedEncoding:nil error:nil];
            
            XCTAssert([retStr isEqualToString:tmpStr]);
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        for (int i = 0; i < 101; i++) {
            NSMutableString *mutlContent = [[NSMutableString alloc] init];
            for (int j = 0; j < 10; j++) {
                [mutlContent appendFormat:@"%d_", rand()];
            }
            NSString *tmpStr = [mutlContent copy];
            NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file1_%d", i]];
            [tmpStr co_writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
            
            NSString *retStr = [NSString co_stringWithContentsOfURL:[NSURL fileURLWithPath:filePath] usedEncoding:nil error:nil];
            
            XCTAssert([retStr isEqualToString:tmpStr]);
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        for (int i = 0; i < 101; i++) {
            NSMutableString *mutlContent = [[NSMutableString alloc] init];
            for (int j = 0; j < 10; j++) {
                [mutlContent appendFormat:@"%d_", rand()];
            }
            NSString *tmpStr = [mutlContent copy];
            NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file1_%d", i]];
            [tmpStr co_writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
            
            NSString *retStr = [NSString co_stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            
            XCTAssert([retStr isEqualToString:tmpStr]);
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        for (int i = 0; i < 101; i++) {
            NSMutableString *mutlContent = [[NSMutableString alloc] init];
            for (int j = 0; j < 10; j++) {
                [mutlContent appendFormat:@"%d_", rand()];
            }
            NSString *tmpStr = [mutlContent copy];
            NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file1_%d", i]];
            [tmpStr co_writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
            
            NSString *retStr = [[NSString alloc] co_initWithContentsOfFile:filePath usedEncoding:nil error:nil];
            
            XCTAssert([retStr isEqualToString:tmpStr]);
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        for (int i = 0; i < 101; i++) {
            NSMutableString *mutlContent = [[NSMutableString alloc] init];
            for (int j = 0; j < 10; j++) {
                [mutlContent appendFormat:@"%d_", rand()];
            }
            NSString *tmpStr = [mutlContent copy];
            NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file1_%d", i]];
            [tmpStr co_writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
            
            NSString *retStr = [[NSString alloc] co_initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            
            XCTAssert([retStr isEqualToString:tmpStr]);
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        
        [e fulfill];
    });
    
    [self waitForExpectations:@[e] timeout:1000];
}


@end
