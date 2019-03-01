//
//  coobjcBenchmarkTests.m
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

SpecBegin(coPerformance)

describe(@"count benchmark", ^{
    /*
    it(@"create 100 co and thread", ^{
         __block NSTimeInterval co_cost = 0;
        __block NSTimeInterval thread_cost = 0;
        __block int co_run_count = 0;
        __block int thread_count = 0;
        

        
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d", [NSDate date], rand()]];
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://pytstore.oss-cn-shanghai.aliyuncs.com/TMARDefault.zip"]];
        [data writeToFile:filePath atomically:YES];
        NSTimeInterval beginTime = [[NSDate date] timeIntervalSince1970];

        
        dispatch_semaphore_t sem = dispatch_semaphore_create(1);
        co_repeat(100, ^(int index){
            NSData *data = await([NSData co_dataWithContentOfFile:filePath]);
            co_run_count++;
            if(co_run_count == 100){
                co_cost = [[NSDate date] timeIntervalSince1970] - beginTime;
                NSLog(@"co cost: %f", (float)co_cost);
            }
        });
        
        for (int i = 0; i < 100; i++) {
//            int  j = i;
            [NSThread detachNewThreadWithBlock:^{
                NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
                
                dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
                thread_count++;
                if(thread_count == 100){
                    thread_cost = [[NSDate date] timeIntervalSince1970] - beginTime;
                    NSLog(@"thread cost: %f", (float)thread_cost);
                }
                dispatch_semaphore_signal(sem);
            }];
        }
        
        waitUntilTimeout(10, ^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"co cost: %.3f, thread cost: %.3f", (float)co_cost, (float)thread_cost);
                done();
            });
        });

    });
    
    it(@"create 1000 co and thread", ^{
        __block NSTimeInterval co_cost = 0;
        __block NSTimeInterval thread_cost = 0;
        __block int co_run_count = 0;
        __block int thread_count = 0;
        
        
        
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d", [NSDate date], rand()]];
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://pytstore.oss-cn-shanghai.aliyuncs.com/GalileoShellApp.ipa"]];
        [data writeToFile:filePath atomically:YES];
        NSTimeInterval beginTime = [[NSDate date] timeIntervalSince1970];
        
        
        dispatch_semaphore_t sem = dispatch_semaphore_create(1);
        co_repeat(1000, ^(int index){
            NSData *data = await([NSData co_dataWithContentOfFile:filePath]);
            co_run_count++;
            if(co_run_count == 1000){
                co_cost = [[NSDate date] timeIntervalSince1970] - beginTime;
                NSLog(@"co cost: %f", (float)co_cost);
            }
        });
        
        for (int i = 0; i < 1000; i++) {
            //            int  j = i;
            [NSThread detachNewThreadWithBlock:^{
                NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
                
                dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
                thread_count++;
                if(thread_count == 1000){
                    thread_cost = [[NSDate date] timeIntervalSince1970] - beginTime;
                    NSLog(@"thread cost: %f", (float)thread_cost);
                }
                dispatch_semaphore_signal(sem);
            }];
        }
        
        waitUntilTimeout(10, ^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"co cost: %.3f, thread cost: %.3f", (float)co_cost, (float)thread_cost);
                done();
            });
        });
        
    });
    
    it(@"create 10000 co and thread", ^{
        __block NSTimeInterval co_cost = 0;
        __block NSTimeInterval thread_cost = 0;
        __block int co_run_count = 0;
        __block int thread_count = 0;
        
        
        
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d", [NSDate date], rand()]];
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://pytstore.oss-cn-shanghai.aliyuncs.com/GalileoShellApp.ipa"]];
        [data writeToFile:filePath atomically:YES];
        NSTimeInterval beginTime = [[NSDate date] timeIntervalSince1970];
        
        
        dispatch_semaphore_t sem = dispatch_semaphore_create(1);
        co_repeat(1000, ^(int index){
            NSData *data = await([NSData co_dataWithContentOfFile:filePath]);
            co_run_count++;
            if(co_run_count == 10000){
                co_cost = [[NSDate date] timeIntervalSince1970] - beginTime;
                NSLog(@"co cost: %f", (float)co_cost);
            }
        });
        
        for (int i = 0; i < 1000; i++) {
            //            int  j = i;
            [NSThread detachNewThreadWithBlock:^{
                NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
                
                dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
                thread_count++;
                if(thread_count == 10000){
                    thread_cost = [[NSDate date] timeIntervalSince1970] - beginTime;
                    NSLog(@"thread cost: %f", (float)thread_cost);
                }
                dispatch_semaphore_signal(sem);
            }];
        }
        
        waitUntilTimeout(10, ^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"co cost: %.3f, thread cost: %.3f", (float)co_cost, (float)thread_cost);
                done();
            });
        });
        
    });
     */
});

SpecEnd

