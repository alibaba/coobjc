//
//  coobjcTupleTests.m
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
#import <coobjc/co_tuple.h>

#ifdef DEBUG

extern int co_tuple_dealloc_count;
extern int co_untuple_dealloc_count;

#endif

@interface TestObject: NSObject

@end

@implementation TestObject

- (void)dealloc{
    NSLog(@"dealloc");
}

@end

COPromise<COTuple*>*
cotest_downloadJSONWithURL(NSString *url){
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if (!error && httpResponse.statusCode != 404) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                resolve(co_tuple(dict, response,nil));
            }
            else{
                if (!error) {
                    error = [NSError errorWithDomain:@"error" code:404 userInfo:nil];
                }
                resolve(co_tuple(nil,response, error));
            }
        }];
        [task resume];
    }];
}

COPromise<COTuple*>*
cotest_loadContentFromFile(NSString *filePath){
    return [COPromise promise:^(COPromiseFulfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
            resolve(co_tuple(filePath, data, nil));
        }
        else{
            NSError *error = [NSError errorWithDomain:@"fileNotFound" code:-1 userInfo:nil];
            resolve(co_tuple(filePath, nil, error));
        }
    }];
}

SpecBegin(COTupleTests)

describe(@"tuple interface", ^{
    it(@"tuple created", ^{
        COTuple *tup = [[COTuple alloc] initWithObjects:nil, @10, @"abc", co_tupleSentinel()];
        NSAssert(tup[0] == nil, @"tup[0] is wrong");
        NSAssert([tup[1] intValue] == 10, @"tup[1] is wrong");
        NSAssert([tup[2] isEqualToString:@"abc"], @"tup[2] is wrong");
        
        tup = [[COTuple alloc] initWithObjects:co_tupleSentinel(), @10, @"abc"];
        NSAssert(tup[0] == nil, @"tup[0] is wrong");
    });
    
    it(@"tuple unpack created", ^{
        COTuple *tup = [[COTuple alloc] initWithObjects:nil, @10, @"abc", co_tupleSentinel()];
        id val0;
        NSNumber *number = nil;
        NSString *str = nil;
        [[COTupleUnpack alloc] initWithPointers:0, &val0, &number, &str, co_unpackSentinel()].tuple = tup;
        NSAssert(val0 == nil, @"val0 is wrong");
        NSAssert([number intValue] == 10, @"number is wrong");
        NSAssert([str isEqualToString:@"abc"], @"str is wrong");
    });
    
});

describe(@"tuple macro", ^{
    it(@"tuple created", ^{
        COTuple *tup = co_tuple(nil, @10, @"abc");
        NSAssert(tup[0] == nil, @"tup[0] is wrong");
        NSAssert([tup[1] intValue] == 10, @"tup[1] is wrong");
        NSAssert([tup[2] isEqualToString:@"abc"], @"tup[2] is wrong");
    });
    
    it(@"tuple unpack created", ^{
        id val0;
        NSNumber *number = nil;
        NSString *str = nil;
        co_unpack(&val0, &number, &str) = co_tuple(nil, @10, @"abc");
        NSAssert(val0 == nil, @"val0 is wrong");
        NSAssert([number intValue] == 10, @"number is wrong");
        NSAssert([str isEqualToString:@"abc"], @"str is wrong");
        
        co_unpack(&val0, &number, &str) = co_tuple(nil, @10, @"abc", @10, @"abc");
        NSAssert(val0 == nil, @"val0 is wrong");
        NSAssert([number intValue] == 10, @"number is wrong");
        NSAssert([str isEqualToString:@"abc"], @"str is wrong");
        
        co_unpack(&val0, &number, &str, &number, &str) = co_tuple(nil, @10, @"abc");
        NSAssert(val0 == nil, @"val0 is wrong");
        NSAssert([number intValue] == 10, @"number is wrong");
        NSAssert([str isEqualToString:@"abc"], @"str is wrong");
        
        NSString *str1;
        
        co_unpack(nil, nil, &str1) = co_tuple(nil, @10, @"abc");
        NSAssert([str1 isEqualToString:@"abc"], @"str1 is wrong");
    });
});

describe(@"tuple with async", ^{
    it(@"test with main queue", ^{
        __block id val0;
        __block NSNumber *number = nil;
        __block NSString *str = nil;
        COTuple *tup = co_tuple(nil, @10, @"abc");
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                co_unpack(&val0, &number, &str) = tup;
                NSAssert(val0 == nil, @"val0 is wrong");
                NSAssert([number intValue] == 10, @"number is wrong");
                NSAssert([str isEqualToString:@"abc"], @"str is wrong");
                done();
            });
        });
        
    });
});

describe(@"tuple with coroutine", ^{
    it(@"test with download from url success", ^{
        co_launch(^{
            NSDictionary *dict = nil;
            NSURLResponse *response = nil;
            NSError *error = nil;
            
            
            co_unpack(&dict, &response, &error) = await(cotest_downloadJSONWithURL(@"http://pytstore.oss-cn-shanghai.aliyuncs.com/monkey_live.json"));
            NSAssert(dict.count > 0, @"not load dict");
            NSAssert(response != nil, @"reponse is wrong");
            NSAssert(error == nil, @"error is wrong");
            

        });
        waitUntilTimeout(2, ^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                done();
            });
        });
    });
    
    it(@"test with download from url error", ^{
        co_launch(^{
            NSDictionary *dict = nil;
            NSURLResponse *response = nil;
            NSError *error = nil;
            
            
            co_unpack(&dict, &response, &error) = await(cotest_downloadJSONWithURL(@"http://pytstore.oss-cn-shanghai.aliyuncs.com/monkey_livexxxxxxxx.json"));
            NSAssert(dict == nil, @"not load dict");
            NSAssert(response != nil, @"reponse is wrong");
            NSAssert(error != nil, @"error is wrong");
        });
        waitUntilTimeout(2, ^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                done();
            });
        });
    });
    
    it(@"test with load file success", ^{
        co_launch(^{
            NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"testxxx"];
            [@"test" writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSString *tmpFilePath = nil;
            NSData *data = nil;
            NSError *error = nil;
            co_unpack(&tmpFilePath, &data, &error) = await(cotest_loadContentFromFile(filePath));
            XCTAssert([tmpFilePath isEqualToString:filePath], @"file path is wrong");
            XCTAssert(data.length > 0, @"data is wrong");
            XCTAssert(error == nil, @"error is wrong");
        });
        waitUntilTimeout(2, ^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                done();
            });
        });
    });
    
    it(@"test with load file error", ^{
        co_launch(^{
            NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"testxxx"];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            NSString *tmpFilePath = nil;
            NSData *data = nil;
            NSError *error = nil;
            co_unpack(&tmpFilePath, &data, &error) = await(cotest_loadContentFromFile(filePath));
            XCTAssert([tmpFilePath isEqualToString:filePath], @"file path is wrong");
            XCTAssert(data.length <= 0, @"data is wrong");
            XCTAssert(error != nil, @"error is wrong");
        });
        waitUntilTimeout(2, ^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                done();
            });
        });
    });
});

SpecEnd
