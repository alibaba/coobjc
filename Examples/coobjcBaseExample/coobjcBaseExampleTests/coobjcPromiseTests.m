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
    return [COPromise promise:^(COPromiseFullfill  _Nonnull fullfill, COPromiseReject  _Nonnull reject) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            fullfill(@"1");
        });
    }];
}
static COPromise *testPromise12() {
    return [COPromise promise:^(COPromiseFullfill  _Nonnull fullfill, COPromiseReject  _Nonnull reject) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            fullfill(@"2");
        });
    }];
}
static COPromise *testPromise13() {
    return [COPromise promise:^(COPromiseFullfill  _Nonnull fullfill, COPromiseReject  _Nonnull reject) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            reject([NSError errorWithDomain:@"aa" code:3 userInfo:@{}]);
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
    
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5 target:[Test123 instanceWithBlock:^{
        [promise fulfill:@13];
    }] selector:@selector(fire) userInfo:nil repeats:NO];
    
    
    [promise onCancel:^(COPromise * _Nonnull promise) {
        [timer invalidate];
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
                expect(error.code).to.equal(-2341);
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
            expect(co_getError() != nil);
        });
        waitUntil(^(DoneCallback done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                done();
            });
        });
    });
    
});
SpecEnd
