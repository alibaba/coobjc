//
//  coobjcPromiseTests.m
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


@interface TestThreadObject1 : NSObject

+ (instancetype)sharedInstance;

- (void)runBlock:(dispatch_block_t)block;

@end

@implementation TestThreadObject1

+ (instancetype)sharedInstance{
    static TestThreadObject1 *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TestThreadObject1 alloc] init];
    });
    return instance;
}

- (void)_handle:(dispatch_block_t)block{
    block();
}

- (void)runBlock:(dispatch_block_t)block{
    [self performSelectorInBackground:@selector(_handle:) withObject:block];
}

@end

static dispatch_queue_t test_queue(){
    static dispatch_queue_t q = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        q = dispatch_queue_create("xxxtest", NULL);
    });
    return q;
}

static id testPromise1() {
    
    COPromise *promise = [COPromise new];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [promise fulfill:@11];
    });
    
    return promise;
}

static id testPromise2() {
    
    COPromise *promise = [COPromise new];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [promise reject:[NSError errorWithDomain:@"hehe" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"hehe1"}]];
    });
    
    return promise;
}

static COPromise *testPromise11() {
    return [COPromise promise:^(COPromiseFulfill  _Nonnull fullfill, COPromiseReject  _Nonnull reject) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            fullfill(@"1");
        });
    }];
}
static COPromise *testPromise12() {
    return [COPromise promise:^(COPromiseFulfill  _Nonnull fullfill, COPromiseReject  _Nonnull reject) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            fullfill(@"2");
        });
    }];
}
static COPromise *testPromise13() {
    return [COPromise promise:^(COPromiseFulfill  _Nonnull fullfill, COPromiseReject  _Nonnull reject) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            reject([NSError errorWithDomain:@"aa" code:3 userInfo:@{}]);
        });
    }];
}

static COPromise *testPromise21() {
    return [COPromise promise:^(COPromiseFulfill  _Nonnull fullfill, COPromiseReject  _Nonnull reject) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            fullfill(@"1");
        });
    }];
}

static COPromise *testPromise22() {
    return [COPromise promise:^(COPromiseFulfill  _Nonnull fullfill, COPromiseReject  _Nonnull reject) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            fullfill(@"2");
        });
    }];
}

@interface Test123 : NSObject
{
    dispatch_block_t _block;
}
+ (instancetype)instance;
@end

@implementation Test123

+ (instancetype)instanceWithBlock:(dispatch_block_t)block {
    Test123 *obj = [self new];
    obj->_block = block;
    return obj;
}

- (void)fire {
    _block();
}

@end

static id testPromise3() {
    
    COPromise *promise = [COPromise new];
    
    
    dispatch_source_t timer = nil;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
    dispatch_source_set_event_handler(timer, ^{
        [promise fulfill:@13];
        dispatch_source_cancel(timer);
    });
    dispatch_resume(timer);
    
    [promise onCancel:^(COPromise * _Nonnull promise) {
        dispatch_source_cancel(timer);
    }];
    
    return promise;
}

static COPromise* downloadImageWithError(){
    COPromise* promise = [COPromise promise];
    long total = 0;
    for (int i = 0; i < 100000000; i++) {
        total += i;
    }
    NSError* error = [NSError errorWithDomain:@"wrong" code:20 userInfo:@{@"h":@"yc"}];
    [promise reject:error];
    return promise;
}


static COProgressPromise* progressDownloadFileFromUrl(NSString *url){
    COProgressPromise *promise = [COProgressPromise promise];
    [NSURLSession sharedSession].configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [promise reject:error];
        }
        else{
            [promise fulfill:data];
        }
    }];
    [task resume];
    if (@available(iOS 11.0, *)) {
        [promise setupWithProgress:task.progress];
    } else {
        // Fallback on earlier versions
        NSProgress *progress = [NSProgress progressWithTotalUnitCount:10];
        
        [promise setupWithProgress:progress];

        
        dispatch_source_t timer = nil;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 0.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(timer, ^{
            if (progress.completedUnitCount < progress.totalUnitCount) {
                progress.completedUnitCount += 1;
            }
            else{
                dispatch_source_cancel(timer);
            }
        });
        dispatch_resume(timer);
        
        [promise onCancel:^(COPromise * _Nonnull promise) {
            dispatch_source_cancel(timer);
        }];
    }
    return promise;
}


SpecBegin(coPromise)



describe(@"Proimse tests", ^{
    it(@"fulfill will return the result normally.", ^{
        __block NSInteger val = 0;
        
        co_launch(^{
            
            id result = await(testPromise1());
            val = [result integerValue];
            expect(val).to.equal(11);
        });
        waitUntil(^(DoneCallback done) {
            dispatch_async(dispatch_get_main_queue(), ^{
                expect(val).to.equal(11);
                done();
            });
        });
    });
    
    it(@"reject should return nil, and error.", ^{
        __block NSInteger val = 0;
        co_launch(^{
            
            id result = await(testPromise2());
            if (!result) {
                NSError *error = co_getError();
                expect(error).to.equal([NSError errorWithDomain:@"hehe" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"hehe1"}]);
                val = 12;
            } else {
                val = 11;
            }
        });
        waitUntil(^(DoneCallback done) {
            dispatch_async(dispatch_get_main_queue(), ^{
                expect(val).to.equal(12);
                done();
            });
        });
    });
    
    it(@"after cancel, the coroutine should not execute the rest codes.", ^{
        __block NSInteger val = 44;
        COCoroutine *co = co_launch(^{
            
            id result = await(testPromise3());
            if (!result) {
                NSError *error = co_getError();
                expect([COPromise isPromiseCancelled:error]).to.beTruthy();
                expect(co_isActive()).to.equal(NO);
                expect(co_isCancelled()).to.equal(YES);
                val = 12;
            } else {
                val = 11;
            }
        });
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [co cancel];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    expect(val).to.equal(12);
                    done();
                });
            });
        });
    });
    
    it(@"cancel a routine which is finished will do nothing.", ^{
        __block NSInteger val = 44;
        COCoroutine *co = co_launch(^{
            
            id result = await(testPromise3());
            if (!result) {
                NSError *error = co_getError();
                val = 12;
            } else {
                val = 11;
            }
        });
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [co cancel];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    expect(val).to.equal(11);
                    done();
                });
            });
        });
    });
    
    it(@"batch await test", ^{
        __block NSInteger val = 0;
        co_launch(^{
            
            NSArray *results = batch_await(@[
                                             testPromise11(),
                                             testPromise12(),
                                             testPromise13(),
                                             ]);
            val = 1;
            expect(results[0]).to.equal(@"1");
            expect(results[1]).to.equal(@"2");
            expect(results[2]).to.equal([NSError errorWithDomain:@"aa" code:3 userInfo:@{}]);

        });
        
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                expect(val).to.equal(1);
                done();
            });
        });
    });
    
    it(@"https://github.com/alibaba/coobjc/issues/26", ^{
        co_launch(^{
            id dd = await(downloadImageWithError());
            expect(co_getError()).notTo.equal(nil);
        });
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                done();
            });
        });
    });
    
    it(@"test progress promise", ^{
        co_launch(^{
            int progressCount = 0;
            COProgressPromise *promise = progressDownloadFileFromUrl(@"http://img17.3lian.com/d/file/201701/17/9a0d018ba683b9cbdcc5a7267b90891c.jpg");
            for(id p in promise){
                double v = [p doubleValue];
                NSLog(@"current progress: %f", (float)v);
                progressCount++;
            }
            expect(progressCount > 0).beTruthy();
            NSData *data = await(promise);
            expect(data.length > 0).beTruthy();
        });
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                done();
            });
        });
    });
    
    it(@"test progress promise 50%", ^{
        co_launch(^{
            int progressCount = 0;
            COProgressPromise *promise = progressDownloadFileFromUrl(@"http://img17.3lian.com/d/file/201701/17/9a0d018ba683b9cbdcc5a7267b90891c.jpg");
            for(id p in promise){
                double v = [p doubleValue];
                if(v >= 0.5){
                    break;
                }
                NSLog(@"current progress: %f", (float)v);
                progressCount++;
            }
            expect(progressCount > 0).beTruthy();
            NSData *data = await(promise);
            expect(data.length > 0).beTruthy();
        });
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                done();
            });
        });
    });
    
    it(@"test progress promise direct", ^{
        co_launch(^{
            int progressCount = 0;
            COProgressPromise *promise = progressDownloadFileFromUrl(@"http://img17.3lian.com/d/file/201701/17/9a0d018ba683b9cbdcc5a7267b90891c.jpg");
            NSData *data = await(promise);
            expect(data.length > 0).beTruthy();
        });
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                done();
            });
        });
    });
    
    it(@"test progress promise error", ^{
        __block int step = 0;
        co_launch(^{
            int progressCount = 0;
            COProgressPromise *promise = progressDownloadFileFromUrl(@"http://img17.3lianghhjghj.com/d/file/201701/17/9a0d018ba683b9cbdcc5a7267b90891c.jpg1111");
            for(id p in promise){
                double v = [p doubleValue];
                if(v >= 0.5){
                    break;
                }
                NSLog(@"current progress: %f", (float)v);
                progressCount++;
            }
            expect(progressCount > 0).to.beTruthy();
            NSData *data = await(promise);
            expect(data == nil).beTruthy();
            expect(co_getError() != nil).beTruthy();
            step = 11;
        });
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                expect(step).to.equal(11);
                done();
            });
        });
    });
    
    it(@"test concurrent await promise", ^{
        __block int val = 0;
        co_launch(^{
            
            NSTimeInterval begin = CACurrentMediaTime();
            id p1 = testPromise21();
            id p2 = testPromise22();
            
            NSString *r1 = await(p1);
            expect(r1).to.equal(@"1");
            NSString *r2 = await(p2);
            expect(r2).to.equal(@"2");
            
            NSTimeInterval duration = CACurrentMediaTime() - begin;
            expect(duration < 5.5).beTruthy();
            val = 1;
        });
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                expect(val).to.equal(1);
                done();
            });
        });
    });
    
});


describe(@"background Thread Proimse tests", ^{
    it(@"fulfill will return the result normally.", ^{
        __block NSInteger val = 0;
        
        [[TestThreadObject1 sharedInstance] runBlock:^{
            co_launch(^{
                
                id result = await(testPromise1());
                val = [result integerValue];
                expect(val).to.equal(11);
            });
        }];
        
        
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                expect(val).to.equal(11);
                done();
            });
        });
    });
    
    it(@"reject should return nil, and error.", ^{
        __block NSInteger val = 0;
        [[TestThreadObject1 sharedInstance] runBlock:^{
            co_launch(^{
                
                id result = await(testPromise2());
                if (!result) {
                    NSError *error = co_getError();
                    expect(error).to.equal([NSError errorWithDomain:@"hehe" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"hehe1"}]);
                    val = 12;
                } else {
                    val = 11;
                }
            });
        }];
        
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                expect(val).to.equal(12);
                done();
            });
        });
    });
    
    it(@"after cancel, the coroutine should not execute the rest codes.", ^{
        __block NSInteger val = 44;
        __block COCoroutine *co = nil;
        [[TestThreadObject1 sharedInstance] runBlock:^{
            co = co_launch(^{
                
                id result = await(testPromise3());
                if (!result) {
                    NSError *error = co_getError();
                    expect([COPromise isPromiseCancelled:error]).to.beTruthy();
                    expect(co_isActive()).to.equal(NO);
                    expect(co_isCancelled()).to.equal(YES);
                    val = 12;
                } else {
                    val = 11;
                }
            });
        }];
        
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [co cancel];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    expect(val).to.equal(12);
                    done();
                });
            });
        });
    });
    
    it(@"cancel a routine which is finished will do nothing.", ^{
        __block NSInteger val = 44;
        __block COCoroutine *co = nil;
        [[TestThreadObject1 sharedInstance] runBlock:^{
            co = co_launch(^{
                
                id result = await(testPromise3());
                if (!result) {
                    NSError *error = co_getError();
                    val = 12;
                } else {
                    val = 11;
                }
            });
        }];
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [co cancel];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    expect(val).to.equal(11);
                    done();
                });
            });
        });
    });
    
    it(@"batch await test", ^{
        __block NSInteger val = 0;
        [[TestThreadObject1 sharedInstance] runBlock:^{
            co_launch(^{
                
                NSArray *results = batch_await(@[
                                                 testPromise11(),
                                                 testPromise12(),
                                                 testPromise13(),
                                                 ]);
                val = 1;
                expect(results[0]).to.equal(@"1");
                expect(results[1]).to.equal(@"2");
                expect(results[2]).to.equal([NSError errorWithDomain:@"aa" code:3 userInfo:@{}]);
                
            });
        }];
        
        
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                expect(val).to.equal(1);
                done();
            });
        });
    });
    
    it(@"https://github.com/alibaba/coobjc/issues/26", ^{
        
        [[TestThreadObject1 sharedInstance] runBlock:^{
            co_launch(^{
                id dd = await(downloadImageWithError());
                expect(co_getError()).notTo.equal(nil);
            });
        }];
        
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                done();
            });
        });
    });
    
    it(@"test progress promise", ^{
        [[TestThreadObject1 sharedInstance] runBlock:^{
            co_launch(^{
                int progressCount = 0;
                COProgressPromise *promise = progressDownloadFileFromUrl(@"http://img17.3lian.com/d/file/201701/17/9a0d018ba683b9cbdcc5a7267b90891c.jpg");
                for(id p in promise){
                    double v = [p doubleValue];
                    NSLog(@"current progress: %f", (float)v);
                    progressCount++;
                }
                expect(progressCount > 0).beTruthy();
                NSData *data = await(promise);
                expect(data.length > 0).beTruthy();
            });
        }];
        
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                done();
            });
        });
    });
    
    it(@"test progress promise 50%", ^{
        
        [[TestThreadObject1 sharedInstance] runBlock:^{
            co_launch(^{
                int progressCount = 0;
                COProgressPromise *promise = progressDownloadFileFromUrl(@"http://img17.3lian.com/d/file/201701/17/9a0d018ba683b9cbdcc5a7267b90891c.jpg");
                for(id p in promise){
                    double v = [p doubleValue];
                    if(v >= 0.5){
                        break;
                    }
                    NSLog(@"current progress: %f", (float)v);
                    progressCount++;
                }
                expect(progressCount > 0).beTruthy();
                NSData *data = await(promise);
                expect(data.length > 0).beTruthy();
            });
        }];
        
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                done();
            });
        });
    });
    
    it(@"test progress promise direct", ^{
        [[TestThreadObject1 sharedInstance] runBlock:^{
            co_launch(^{
                int progressCount = 0;
                COProgressPromise *promise = progressDownloadFileFromUrl(@"http://img17.3lian.com/d/file/201701/17/9a0d018ba683b9cbdcc5a7267b90891c.jpg");
                NSData *data = await(promise);
                expect(data.length > 0).beTruthy();
            });
        }];
        
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                done();
            });
        });
    });
    
    it(@"test progress promise error", ^{
        __block int step = 0;

        [[TestThreadObject1 sharedInstance] runBlock:^{
            co_launch(^{
                int progressCount = 0;
                COProgressPromise *promise = progressDownloadFileFromUrl(@"http://img17.3lianghhjghj.com/d/file/201701/17/9a0d018ba683b9cbdcc5a7267b90891c.jpg1111");
                for(id p in promise){
                    double v = [p doubleValue];
                    if(v >= 0.5){
                        break;
                    }
                    NSLog(@"current progress: %f", (float)v);
                    progressCount++;
                }
//                expect(progressCount).to.equal(1);
                NSData *data = await(promise);
                expect(data == nil).beTruthy();
                expect(co_getError() != nil).beTruthy();
                step = 11;
            });
        }];
        
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                done();
                expect(step).to.equal(11);
            });
        });
    });
    
    it(@"test concurrent await promise", ^{
        __block int val = 0;
        [[TestThreadObject1 sharedInstance] runBlock:^{
            co_launch(^{
                
                NSTimeInterval begin = CACurrentMediaTime();
                id p1 = testPromise21();
                id p2 = testPromise22();
                
                NSString *r1 = await(p1);
                expect(r1).to.equal(@"1");
                NSString *r2 = await(p2);
                expect(r2).to.equal(@"2");
                
                NSTimeInterval duration = CACurrentMediaTime() - begin;
                expect(duration < 5.5).beTruthy();
                val = 1;
            });
        }];
        
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                expect(val).to.equal(1);
                done();
            });
        });
    });
    
});

describe(@"https://github.com/alibaba/coobjc/issues/62", ^{
    it(@"fix crash", ^{
        [[[COPromise promise:^(COPromiseFulfill _Nonnull fullfill, COPromiseReject _Nonnull reject) {
            fullfill(@"step 1");
        }] then:^id _Nullable(id _Nullable value) {
            NSLog(@"eIIIIIII = %@", value);
            return [COPromise promise:^(COPromiseFulfill _Nonnull fullfill, COPromiseReject _Nonnull reject) {
                reject([NSError errorWithDomain:@"step 2" code:99 userInfo:nil]);
            }];
        }] catch:^(NSError * _Nonnull error) {
            NSLog(@"eIIIIIII = %@", error.domain);
        }];
    });
});
SpecEnd
