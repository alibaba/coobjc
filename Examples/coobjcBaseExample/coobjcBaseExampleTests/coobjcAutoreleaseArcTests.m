//
//  coobjcAutoreleaseArcTests.m
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
#import <coobjc/co_autorelease.h>

static int state;

static dispatch_queue_t get_test_queue(){
    static dispatch_queue_t q = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        q = dispatch_queue_create("test_queue", NULL);
    });
    return q;
}

static dispatch_queue_t get_test_queue1(){
    static dispatch_queue_t q = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        q = dispatch_queue_create("test_queue_1", NULL);
    });
    return q;
}

#define NESTED_COUNT 8

@interface TestDeallocator : NSObject @end
@implementation TestDeallocator
-(void) dealloc
{
    // testprintf("-[Deallocator %p dealloc]\n", self);
    state++;
}
@end

@interface coobjcAutoreleaseArcTests : XCTestCase

@end

@implementation coobjcAutoreleaseArcTests

- (COPromise<NSNumber*>*)makeAsynPromise{
    return [COPromise promise:^(COPromiseFullfill  resolve, COPromiseReject  reject) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            resolve(@1);
        });
    }];
}

- (void)setUp {
    [super setUp];
    co_autoreleaseInit();
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testEnableAutoreleasePool{
    co_enableAutorelease = YES;
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    co_launch_onqueue(get_test_queue(), ^{
        state = 0;
        @autoreleasepool{
            coroutine_t *routine = coroutine_self();
            XCTAssert(routine->autoreleasepage != NULL);
            
            for (int i = 0; i < 10; i++) {
                __autoreleasing TestDeallocator *d = [[TestDeallocator alloc] init];
            }
        }
        

        
        
        XCTAssert(state == 10);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [e fulfill];
        });
    });
    [self waitForExpectations:@[e] timeout:1000];
    
}

- (void)testEnableAutoreleasePoolAwait{
    co_enableAutorelease = YES;
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    co_launch_onqueue(get_test_queue(), ^{
        state = 0;

        @autoreleasepool{
            coroutine_t *routine = coroutine_self();
            XCTAssert(routine->autoreleasepage != NULL);
            for (int i = 0; i < 10; i++) {
                __autoreleasing TestDeallocator *d = [[TestDeallocator alloc] init];
            }
            id val = await([self makeAsynPromise]);
            //TODO: NSLog会导致autorelease崩溃
            printf("%d\n", [val intValue]);
            for (int i = 0; i < 10; i++) {
                __autoreleasing TestDeallocator *d = [[TestDeallocator alloc] init];
            }
        }
        
        
        
        XCTAssert(state == 20);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [e fulfill];
        });
    });
    [self waitForExpectations:@[e] timeout:1000];
    
}

- (void)testEnableAutoreleasePoolNSLog{
    co_enableAutorelease = YES;
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    co_launch_onqueue(get_test_queue(), ^{
        state = 0;
        @autoreleasepool{
            coroutine_t *routine = coroutine_self();
            XCTAssert(routine->autoreleasepage != NULL);
            for (int i = 0; i < 10; i++) {
                __autoreleasing TestDeallocator *d = [[TestDeallocator alloc] init];
            }
            NSLog(@"test");
            for (int i = 0; i < 10; i++) {
                __autoreleasing TestDeallocator *d = [[TestDeallocator alloc] init];
            }
            
            
        }
        
        XCTAssert(state == 20);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [e fulfill];
        });
        
        
    });
    [self waitForExpectations:@[e] timeout:1000];
    
}

- (void)testDisableAutoreleasePool{
    co_enableAutorelease = NO;
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    co_launch_onqueue(get_test_queue(), ^{
        state = 0;
        
        coroutine_t *routine = coroutine_self();
        XCTAssert(routine->autoreleasepage == NULL);
        for (int i = 0; i < 10; i++) {
            __autoreleasing TestDeallocator *d = [[TestDeallocator alloc] init];
        }
        NSLog(@"test");
        for (int i = 0; i < 10; i++) {
            __autoreleasing TestDeallocator *d = [[TestDeallocator alloc] init];
        }
            
            

        
        XCTAssert(state == 0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [e fulfill];
        });
        
        
    });
    [self waitForExpectations:@[e] timeout:1000];
}

- (void)testAutoreleasePoolNested{
    co_enableAutorelease = YES;
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    co_launch_onqueue(get_test_queue(), ^{
        state = 0;
        
        @autoreleasepool{
            coroutine_t *routine = coroutine_self();
            XCTAssert(routine->autoreleasepage != NULL);
            {
                @autoreleasepool{
                    for (int i = 0; i < 10; i++) {
                        __autoreleasing TestDeallocator *d = [[TestDeallocator alloc] init];
                    }
                }
            }
            
            id val = await([self makeAsynPromise]);
            //TODO: NSLog会导致autorelease崩溃
            NSLog(@"%@", val);
            {
                @autoreleasepool{
                    for (int i = 0; i < 10; i++) {
                        __autoreleasing TestDeallocator *d = [[TestDeallocator alloc] init];
                    }
                }
            }
            val = await([self makeAsynPromise]);
            //TODO: NSLog会导致autorelease崩溃
            NSLog(@"%@", val);
            
            for (int i = 0; i < 10; i++) {
                __autoreleasing TestDeallocator *d = [[TestDeallocator alloc] init];
            }
            
            
            
        }
        
        XCTAssert(state == 30);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [e fulfill];
        });
        
        
    });
    [self waitForExpectations:@[e] timeout:1000];
}

- (void)testAutoreleasePoolNestedUnbanlance{
    co_enableAutorelease = YES;
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    co_launch_onqueue(get_test_queue(), ^{
        state = 0;
        @autoreleasepool{
            coroutine_t *routine = coroutine_self();
            XCTAssert(routine->autoreleasepage != NULL);
            {
                @try{
                    @autoreleasepool{
                        for (int i = 0; i < 10; i++) {
                            __autoreleasing TestDeallocator *d = [[TestDeallocator alloc] init];
                        }
                        @throw [NSException exceptionWithName:@"test" reason:@"test" userInfo:nil];
                    }
                }
                @catch(NSException *e){
                    
                }
                
                
                //            co_autoreleasePoolPop(ctx1);
            }
            
            id val = await([self makeAsynPromise]);
            //TODO: NSLog会导致autorelease崩溃
            NSLog(@"%@", val);
            {
                @autoreleasepool{
                    for (int i = 0; i < 10; i++) {
                        __autoreleasing TestDeallocator *d = [[TestDeallocator alloc] init];
                    }
                }
                
            }
            val = await([self makeAsynPromise]);
            //TODO: NSLog会导致autorelease崩溃
            NSLog(@"%@", val);
            
            for (int i = 0; i < 10; i++) {
                __autoreleasing TestDeallocator *d = [[TestDeallocator alloc] init];
            }
            
            
            
        }
        
        XCTAssert(state == 30);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [e fulfill];
        });
        
    });
    [self waitForExpectations:@[e] timeout:1000];
}

- (void)testAutoreleasePoolNSArray{
    co_enableAutorelease = YES;
    XCTestExpectation *e = [self expectationWithDescription:@"test"];
    co_launch_onqueue(get_test_queue(), ^{
        NSArray *list = @[@1, @2, @3, @4, @5, @6];
        [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"%@", obj);
            id value = await([self makeAsynPromise]);
            NSLog(@"%@", value);
        }];
        [e fulfill];
    });
    [self waitForExpectations:@[e] timeout:1000];
}

@end
