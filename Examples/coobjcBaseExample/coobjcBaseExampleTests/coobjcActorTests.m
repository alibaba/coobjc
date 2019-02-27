//
//  coobjcActorTests.m
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
#import <coobjc.h>

static dispatch_queue_t get_test_queue(){
    static dispatch_queue_t q = nil;
    if (!q) {
        q = dispatch_queue_create("test", NULL);
    }
    return q;
}

SpecBegin(coActor)

describe(@"actor tests", ^{
    it(@"create actor", ^{
        __block int val = 0;
        __block int val1 = 0;
        co_actor(^(COActorChan *chan) {
            val = 1;
            XCTAssert(chan != nil);
        });
        co_actor_onqueue(get_test_queue(), ^(COActorChan *chan) {
            val1 = 1;
            XCTAssert(chan != nil);
        });
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                XCTAssert(val == 1);
                XCTAssert(val1 == 1);
                done();
            });
        });
    });
    it(@"for in chan", ^{
        __block int val = 0;
        COActor* actor = co_actor(^(COActorChan *chan) {
            int tmpVal = 0;
            for(COActorMessage *message in chan){
                if([message intType] == 1){
                    tmpVal++;
                }
                else if([message intType] == -1){
                    tmpVal--;
                }
                else if([message intType] == 2){
                    message.complete(@(tmpVal));
                }
            }
        });
        co_launch(^{
            [actor sendMessage:@(1)];
            [actor sendMessage:@(1)];
            [actor sendMessage:@(1)];
            [actor sendMessage:@(1)];
            [actor sendMessage:@(1)];
            [actor sendMessage:@(1)];

            [actor sendMessage:@(-1)];

            COActorCompletable *completable = [actor sendMessage:@(2)];
            id result = await(completable);
            val = [result intValue];
            [actor cancel];
        });

        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                XCTAssert(val == 5);
                done();
            });
        });
    });
    
    it(@"for in async chan", ^{
        __block int val = 0;
        COActor* actor = co_actor_onqueue(get_test_queue(), ^(COActorChan *chan) {
            int tmpVal = 0;
            for(COActorMessage *message in chan){
                if([message intType] == 1){
                    tmpVal++;
                }
                else if([message intType] == -1){
                    tmpVal--;
                }
                else if([message intType] == 2){
                    message.complete(@(tmpVal));
                }
            }
        });
        co_launch(^{
            for(int i = 0; i < 100; i++){
                [actor sendMessage:@(1)];
            }
            for(int i = 0; i< 90; i++){
                [actor sendMessage:@(-1)];
            }
            
            
            COActorCompletable *completable = [actor sendMessage:@(2)];
            id result = await(completable);
            val = [result intValue];
            [actor cancel];
        });
        
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                XCTAssert(val == 10);
                done();
            });
        });
    });
    
    it(@"next in chan", ^{
        __block int val = 0;
        COActor* actor = co_actor(^(COActorChan *chan) {
            int tmpVal = 0;
            COActorMessage *message = nil;
            while((message = [chan next])){
                if([message intType] == 1){
                    tmpVal++;
                }
                else if([message intType] == -1){
                    tmpVal--;
                }
                else if([message intType] == 2){
                    message.complete(@(tmpVal));
                }
            }
        });
        co_launch(^{
            [actor sendMessage:@(1)];
            [actor sendMessage:@(1)];
            [actor sendMessage:@(1)];
            [actor sendMessage:@(1)];
            [actor sendMessage:@(1)];
            [actor sendMessage:@(1)];
            
            [actor sendMessage:@(-1)];
            
            COActorCompletable *completable = [actor sendMessage:@(2)];
            id result = await(completable);
            val = [result intValue];
            [actor cancel];
        });
        
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                XCTAssert(val == 5);
                done();
            });
        });
    });
    
    it(@"actor cancel", ^{
        __block int val = 0;
        __block int canceled = 0;
        COActor* actor = co_actor(^(COActorChan *chan) {
            int tmpVal = 0;
            for(COActorMessage *message in chan){
                if([message intType] == 1){
                    tmpVal++;
                }
                else if([message intType] == -1){
                    tmpVal--;
                }
                else if([message intType] == 2){
                    message.complete(@(tmpVal));
                }
            }
            NSLog(@"actor cancelled");
            canceled = 1;
        });
        co_launch(^{
            [actor sendMessage:@(1)];
            [actor sendMessage:@(1)];
            [actor sendMessage:@(1)];
            [actor sendMessage:@(1)];
            [actor sendMessage:@(1)];
            [actor sendMessage:@(1)];
            
            [actor sendMessage:@(-1)];
            
            COActorCompletable *completable = [actor sendMessage:@(2)];
            id result = await(completable);
            val = [result intValue];
//            NSLog(@"actor cancel");
            [actor cancel];
            NSLog(@"actor cancel");

        });
        
        waitUntilTimeout(5.1, ^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                XCTAssert(val == 5);
                XCTAssert(canceled == 1);
                XCTAssert([actor isCancelled] == true);
                XCTAssert([actor isFinished] == true);
                done();
            });
        });
    });
    
    it(@"counter example", ^{
        COActor *countActor = co_actor_onqueue(get_test_queue(), ^(COActorChan *channel) {
            int count = 0;
            for(COActorMessage *message in channel){
                if([[message stringType] isEqualToString:@"inc"]){
                    count++;
                }
                else if([[message stringType] isEqualToString:@"get"]){
                    message.complete(@(count));
                }
            }
        });
        co_launch(^{
            [countActor sendMessage:@"inc"];
            [countActor sendMessage:@"inc"];
            [countActor sendMessage:@"inc"];
            int currentCount = [await([countActor sendMessage:@"get"]) intValue];
        });
        co_launch_onqueue(dispatch_queue_create("counter queue1", NULL), ^{
            [countActor sendMessage:@"inc"];
            [countActor sendMessage:@"inc"];
            [countActor sendMessage:@"inc"];
            [countActor sendMessage:@"inc"];
            int currentCount = [await([countActor sendMessage:@"get"]) intValue];
        });
    });
});

SpecEnd
