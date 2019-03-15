//
//  coobjcSequenceTests.m
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
#import "coobjcCommon.h"

static COPromise<NSData *> *co_downloadWithURL(NSString *url) {
    
    return [COPromise promise:^(COPromiseFulfill  _Nonnull fullfill, COPromiseReject  _Nonnull reject) {
        
        [NSURLSession sharedSession].configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:[NSURL URLWithString:url] completionHandler:
                                          ^(NSURL *location, NSURLResponse *response, NSError *error) {
                                              if (error) {
                                                  reject(error);
                                                  return;
                                              }
                                              else{
                                                  NSData *data = [[NSData alloc] initWithContentsOfURL:location];
                                                  
                                                  fullfill(data);
                                                  return;
                                              }
                                          }];
        
        [task resume];
        
    }];
}

SpecBegin(coSequence)

describe(@"test sequence on same queue", ^{
    it(@"yield value", ^{
        COGenerator *co1 = co_sequence(^{
            int index = 0;
            while(co_isActive()){
                NSLog(@"==== before yield val %d", index);
                yield_val(@(index));
                NSLog(@"==== after yield val %d", index);
                index++;
            }
        });
        __block int val = 0;
        co_launch(^{
            for(int i = 0; i < 10; i++){
                NSLog(@"==== before next val %d", i);
                val = [[co1 next] intValue];
                NSLog(@"==== after next val %d", val);
            }
            [co1 cancel];
        });
        waitUntilTimeout(2.0, ^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                XCTAssert(val == 9);
                done();
            });
        });
    });
    
    it(@"yield value return param", ^{
        COGenerator *co1 = co_sequence(^{
            int index = 0;
            while(co_isActive()){
                NSLog(@"==== before yield val %d", index);
                
                int param = [co_getYieldParam() intValue];
                expect(param == 5).beTruthy();
                yield_val(@(index));
                
                NSLog(@"==== after yield val %d", index);
                index++;
            }
        });
        __block int val = 0;
        co_launch(^{
            for(int i = 0; i < 10; i++){
                NSLog(@"==== before next val %d", i);
                val = [[co1 nextWithParam:@(5)] intValue];
                NSLog(@"==== after next val %d", val);
            }
            [co1 cancel];
        });
        waitUntilTimeout(2.0, ^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                XCTAssert(val == 9);
                done();
            });
        });
    });
    
    it(@"yield value chain", ^{
        COGenerator *co1 = co_sequence(^{
            int index = 0;
            while(co_isActive()){
                yield_val(@(index));
                index++;
            }
        });
        
        COGenerator *co2 = co_sequence(^{
            int index = 0;
            while(co_isActive()){
                yield_val([co1 next]);
                index++;
            }
        });
        __block int val = 0;
        co_launch(^{
            for(int i = 0; i < 10; i++){
                val = [[co2 next] intValue];
            }
            [co2 cancel];
            [co1 cancel];
        });
        waitUntilTimeout(2.0, ^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                XCTAssert(val == 9);
                done();
            });
        });
    });
    
    it(@"yield promise", ^{
        __block int count = 0;
        COGenerator *co1 = co_sequence(^{
            while(co_isActive()){
                yield( count++; co_downloadWithURL(@"http://pytstore.oss-cn-shanghai.aliyuncs.com/GalileoShellApp.ipa"));
            }
        });
        int filebytes = 248564;
        __block int val = 0;
        co_launch(^{
            for(int i = 0; i < 10; i++){
                NSData *data = [co1 next];
                val += data.length;
                //val = [[co1 next] intValue];
            }
            [co1 cancel];
        });
        waitUntilTimeout(5.0, ^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                expect(val == filebytes * 10).beTruthy();
                expect(count).equal(10);
                done();
            });
        });
    });
    
    it(@"yield promise return param", ^{
        __block int count = 0;
        COGenerator *co1 = co_sequence(^{
            while(co_isActive()){
                int param = [co_getYieldParam() intValue];
                expect(param == 10).beTruthy();
                yield( count++; co_downloadWithURL(@"http://pytstore.oss-cn-shanghai.aliyuncs.com/GalileoShellApp.ipa"));
            }
        });
        int filebytes = 248564;
        __block int val = 0;
        co_launch(^{
            for(int i = 0; i < 10; i++){
                NSData *data = [co1 nextWithParam:@(10)];
                val += data.length;
                //val = [[co1 next] intValue];
            }
            [co1 cancel];
        });
        waitUntilTimeout(5.0, ^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                expect(val == filebytes * 10).beTruthy();
                expect(count).equal(10);
                done();
            });
        });
    });
    
    it(@"yield promise chain", ^{
        __block             int count = 0;
        COGenerator *co2 = co_sequence(^{
            while(co_isActive()){
                yield(count++; co_downloadWithURL(@"http://pytstore.oss-cn-shanghai.aliyuncs.com/GalileoShellApp.ipa"));
            }
        });
        
        COGenerator *co1 = co_sequence((^{
            int index = 0;
            while(co_isActive()){
                NSArray *list = [NSArray arrayWithObjects:[co2 next], [co2 next], nil];
                yield_val(list);
                index++;
            }
        }));
        int filebytes = 248564;
        __block int val = 0;
        co_launch(^{
            for(int i = 0; i < 10; i++){
                NSArray *list = [co1 next];
                val += [list[0] length];
                val += [list[1] length];
                //val = [[co1 next] intValue];
            }
            [co1 cancel];
            [co2 cancel];
        });
        waitUntilTimeout(5.0, ^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                expect(val == filebytes * 20).beTruthy();
                expect(count).to.equal(20);
                done();
            });
        });
    });
    
});

describe(@"test sequence on multi thread", ^{
    it(@"yield value", ^{
        dispatch_queue_t q = dispatch_queue_create("test", NULL);
        COGenerator *co1 = co_sequence_onqueue(q, ^{
            int index = 0;
            while(co_isActive()){
                yield_val(@(index));
                index++;
            }
        });
        __block int val = 0;
        co_launch(^{
            for(int i = 0; i < 10; i++){
                val = [[co1 next] intValue];
            }
            [co1 cancel];
        });
        waitUntilTimeout(2.0, ^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                XCTAssert(val == 9);
                done();
            });
        });
    });
    
    it(@"yield value chain", ^{
        dispatch_queue_t q1 = dispatch_queue_create("test", NULL);
        dispatch_queue_t q2 = dispatch_queue_create("test", NULL);

        COGenerator *co1 = co_sequence_onqueue(q1, ^{
            int index = 0;
            while(co_isActive()){
                yield_val(@(index));
                index++;
            }
        });
        
        COGenerator *co2 = co_sequence_onqueue(q2, ^{
            int index = 0;
            while(co_isActive()){
                yield_val([co1 next]);
                index++;
            }
        });
        __block int val = 0;
        co_launch(^{
            for(int i = 0; i < 10; i++){
                val = [[co2 next] intValue];
            }
            [co2 cancel];
            [co1 cancel];
        });
        waitUntilTimeout(2.0, ^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                XCTAssert(val == 9);
                done();
            });
        });
    });
    
    it(@"yield promise", ^{
        dispatch_queue_t q1 = dispatch_queue_create("test", NULL);
        COGenerator *co1 = co_sequence_onqueue(q1, ^{
            int index = 0;
            while(co_isActive()){
                yield(co_downloadWithURL(@"http://pytstore.oss-cn-shanghai.aliyuncs.com/GalileoShellApp.ipa"));
                index++;
            }
        });
        int filebytes = 248564;
        __block int val = 0;
        co_launch(^{
            for(int i = 0; i < 10; i++){
                NSData *data = [co1 next];
                val += data.length;
                //val = [[co1 next] intValue];
            }
            [co1 cancel];
        });
        waitUntilTimeout(5.0, ^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                XCTAssert(val == filebytes * 10);
                done();
            });
        });
    });
    
    it(@"yield promise chain", ^{
        dispatch_queue_t q1 = dispatch_queue_create("test", NULL);
        dispatch_queue_t q2 = dispatch_queue_create("test", NULL);

        COGenerator *co2 = co_sequence_onqueue(q1, ^{
            int index = 0;
            while(co_isActive()){
                yield(co_downloadWithURL(@"http://pytstore.oss-cn-shanghai.aliyuncs.com/GalileoShellApp.ipa"));
                index++;
            }
        });
        
        COGenerator *co1 = co_sequence_onqueue(q2, (^{
            int index = 0;
            while(co_isActive()){
                NSArray *list = [NSArray arrayWithObjects:[co2 next], [co2 next], nil];
                yield_val(list);
                index++;
            }
        }));
        int filebytes = 248564;
        __block int val = 0;
        co_launch(^{
            for(int i = 0; i < 10; i++){
                NSArray *list = [co1 next];
                val += [list[0] length];
                val += [list[1] length];
                //val = [[co1 next] intValue];
            }
            [co1 cancel];
            [co2 cancel];
        });
        waitUntilTimeout(5.0, ^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                XCTAssert(val == filebytes * 20);
                done();
            });
        });
    });
});

SpecEnd
