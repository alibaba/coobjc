//
//  coobjcCrashCaseTests.m
//  coobjcBaseExampleTests
//
//  Created by 彭 玉堂 on 2019/3/22.
//  Copyright © 2019 fantasy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <coobjc/coobjc.h>

typedef void (^TestBlock)(COPromiseFulfill fullfill);

@interface HYDispatchGroupQueue: NSObject
{
    NSRecursiveLock  *_lock;    //同步锁
}
@property (nonatomic, strong) NSMutableArray    *groupArray;
@end

@implementation HYDispatchGroupQueue

#pragma mark - Init&LifeCircle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _groupArray = [NSMutableArray new];
        _lock = [NSRecursiveLock new];
    }
    return self;
}

#pragma mark - Public

- (void)addTask:(TestBlock)task
{
    [_lock lock];
    [self.groupArray addObject:task];
    [_lock unlock];
}

//每次进入都新建协程和timer
- (void)beginTaskWithTimeout:(NSTimeInterval)timeout completed:(void(^)(NSArray *))completed
{
    __block NSTimer *t = nil;   //超时定时器
    //新建协程
    COCoroutine *co = co_launch(^{
        NSMutableArray *taskArray = [NSMutableArray new];
        [self->_lock lock];
        int index = 0;
        for (TestBlock task in self.groupArray) {
            COPromise *promise = [self coDotask:task];
//            promise.tag = [NSString stringWithFormat:@"id-%d",index++];
            [taskArray addObject:promise];
        }
        [self->_lock unlock];
        NSArray *results = batch_await(taskArray);
        if (co_isCancelled()) {//取当前协程判断是否cancel
            results = nil;
        }
        completed ? completed(results) : nil;
        [t invalidate];
        t = nil;
    });
    //新建timer
    if (timeout > 0) {
        if ([[NSThread currentThread] isMainThread]) {  //主线程
            t = [NSTimer timerWithTimeInterval:timeout target:self selector:@selector(timeoutTrigger:) userInfo:co repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:t forMode:NSRunLoopCommonModes];
        } else {
            t = [NSTimer timerWithTimeInterval:timeout target:self selector:@selector(timeoutTrigger:) userInfo:co repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:t forMode:NSRunLoopCommonModes];
            [[NSRunLoop currentRunLoop] run];
        }
    }
}

#pragma mark - event

- (void)timeoutTrigger:(NSTimer *)sender
{
    COCoroutine *co = sender.userInfo;
    [co cancel];
}

#pragma mark - Private

- (COPromise *)coDotask:(TestBlock)task
{
    COPromise *promise = [COPromise promise:^(COPromiseFulfill  _Nonnull fulfill, COPromiseReject  _Nonnull reject) {
        task(fulfill);
    }];
    return promise;
}

@end

HYDispatchGroupQueue *groupQueue = nil;

@interface coobjcCrashCaseTests : XCTestCase

@end

@implementation coobjcCrashCaseTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    
    groupQueue = [[HYDispatchGroupQueue alloc] init];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

//test case for https://github.com/alibaba/coobjc/issues/56
- (void)testCrash56{
    XCTestExpectation *e = [self expectationWithDescription:@"testCrash"];
    [groupQueue addTask:^(COPromiseFulfill fullfill) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            fullfill(@(1));
        });
    }];
    [groupQueue addTask:^(COPromiseFulfill fullfill) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            fullfill(@(2));
        });
    }];
    [groupQueue addTask:^(COPromiseFulfill fullfill) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            fullfill(@(3));
        });
    }];
    
//    for (NSInteger i = 0; i < 10; ++i) {
//
//    }
    
    [groupQueue beginTaskWithTimeout:5 completed:^(NSArray * _Nonnull array) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"%@", array);
        });
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [e fulfill];
    });
    
    [self waitForExpectations:@[e] timeout:10];
}

@end
