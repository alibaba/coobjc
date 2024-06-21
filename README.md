<p align="center" >
  <img src="coobjc_icon.png" alt="coobjc" title="coobjc">
</p>

This library provides coroutine support for Objective-C and Swift. We added await method、generator and actor model like C#、Javascript and Kotlin. For convenience, we added coroutine categories for some Foundation and UIKit API in [cokit framework](cokit/README.md) like NSFileManager, JSON, NSData, UIImage etc. We also add tuple support in coobjc.

[cooobjc 中文文档](README_cn.md)

## 0x0 iOS Asynchronous programming problem

Block-based asynchronous programming callback is currently the most widely used asynchronous programming method for iOS. The GCD library provided by iOS system makes asynchronous development very simple and convenient, but there are many disadvantages based on this programming method：

* get into Callback hell

    Sequence of simple operations is unnaturally composed in the nested blocks. This "Callback hell" makes it difficult to keep track of code that is running, and the stack of closures leads to many second order effects.

* Handling errors becomes difficult and very verbose

* Conditional execution is hard and error-prone

* forget to call the completion block

* Because completion handlers are awkward, too many APIs are defined synchronously

    This is hard to quantify, but the authors believe that the awkwardness of defining and using asynchronous APIs (using completion handlers) has led to many APIs being defined with apparently synchronous behavior, even when they can block. This can lead to problematic performance and responsiveness problems in UI applications - e.g. spinning cursor. It can also lead to the definition of APIs that cannot be used when asynchrony is critical to achieve scale, e.g. on the server.

* Multi-threaded crashes that are difficult to locate

* Locks and semaphore abuse caused by blocking


## 0x1 Solution

These problem have been faced in many systems and many languages, and the abstraction of coroutines is a standard way to address them. Without delving too much into theory, coroutines are an extension of basic functions that allow a function to return a value or be suspended. They can be used to implement generators, asynchronous models, and other capabilities - there is a large body of work on the theory, implementation, and optimization of them.

Kotlin is a static programming language supported by JetBrains that supports modern multi-platform applications. It has been quite hot in the developer community for the past two years. In the Kotlin language, async/await based on coroutine, generator/yield and other asynchronous technologies have become syntactic standard, Kotlin coroutine related introduction, you can refer to：[https://www.kotlincn.net/docs/reference/coroutines/basics.html](https://www.kotlincn.net/docs/reference/coroutines/basics.html)

## 0x2 Coroutine

> **Coroutines are computer program components that generalize subroutines for non-preemptive multitasking, by allowing execution to be suspended and resumed. Coroutines are well-suited for implementing familiar program components such as cooperative tasks, exceptions, event loops, iterators, infinite lists and pipes**


The concept of coroutine has been proposed in the 1960s. It is widely used in the server. It is extremely suitable for use in high concurrency scenarios. It can greatly reduce the number of threads in a single machine and improve the connection and processing capabilities of a single machine. In the meantime, iOS currently does not support the use of coroutines（That's why we want to support it.）

## 0x3 coobjc framework

coobjc is a coroutine development framework that can be used on the iOS by the Alibaba Taobao-Mobile architecture team. Currently it supports the use of Objective-C and Swift. We use the assembly and C language for development, and the upper layer provides the interface between Objective-C and Swift. Currently, It's open source here under Apache open source license.

### 0x31 Install

* cocoapods for objective-c:  pod 'coobjc'
* cocoapods for swift: pod 'coswift'
* cocoapods for cokit: pod 'cokit'
* source code: All the code is in the ./coobjc directory

### 0x32 Documents

* Read the [Coroutine framework design](docs/arch_design.md) document.
* Read the [coobjc Objective-C Guide](docs/usage.md) document.
* Read the [coobjc Swift Guide](docs/usage_swift.md) document.
* Read the [cokit framework](cokit/README.md) document, learn how to use the wrapper api of System Interface.
* We have provided [coobjcBaseExample](Examples/coobjcBaseExample) demos for coobjc, [coSwiftDemo](Examples/coSwiftDemo) for coswift, [coKitExamples](cokit/Examples/coKitExamples) for cokit

### 0x33 Features

#### async/await

* create coroutine

Create a coroutine using the co_launch method

```objc
co_launch(^{
    ...
});
```

The coroutine created by co_launch is scheduled by default in the current thread.

* await asynchronous method

In the coroutine we use the await method to wait for the asynchronous method to execute, get the asynchronous execution result

```objc
- (void)viewDidLoad {
    ...
    co_launch(^{
        // async downloadDataFromUrl
        NSData *data = await(downloadDataFromUrl(url));
        
        // async transform data to image
        UIImage *image = await(imageFromData(data));

        // set image to imageView
        self.imageView.image = image;
    });
}
```

The above code turns the code that originally needs dispatch_async twice into sequential execution, and the code is more concise.

* error handling

In the coroutine, all our methods are directly returning the value, and no error is returned. Our error in the execution process is obtained by co_getError(). For example, we have the following interface to obtain data from the network. When the promise will reject: error

```objc
- (COPromise*)co_GET:(NSString*)url parameters:(NSDictionary*)parameters{
    COPromise *promise = [COPromise promise];
    [self GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [promise fulfill:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [promise reject:error];
    }];
    return promise;
}
```

Then we can use the method in the coroutine：

```objc
co_launch(^{
    id response = await([self co_GET:feedModel.feedUrl parameters:nil]);
    if(co_getError()){
        //handle error message
    }
    ...
});
```

#### Generator

* create generator

We use co_sequence to create the generator

```objc
COGenerator *co1 = co_sequence(^{
            int index = 0;
            while(co_isActive()){
                yield_val(@(index));
                index++;
            }
        });
```

In other coroutines, we can call the next method to get the data in the generator.

```objc
co_launch(^{
            for(int i = 0; i < 10; i++){
                val = [[co1 next] intValue];
            }
        });
```

* use case

The generator can be used in many scenarios, such as message queues, batch download files, bulk load caches, etc.:

```objc
int unreadMessageCount = 10;
NSString *userId = @"xxx";
COSequence *messageSequence = co_sequence_onqueue(background_queue, ^{
   //thread execution in the background
    while(1){
        yield(queryOneNewMessageForUserWithId(userId));
    }
});

//Main thread update UI
co_launch(^{
   for(int i = 0; i < unreadMessageCount; i++){
       if(!isQuitCurrentView()){
           displayMessage([messageSequence next]);
       }
   }
});
```

Through the generator, we can load the data from the traditional producer--notifying the consumer model, turning the consumer into the data-->telling the producer to load the pattern, avoiding the need to use many shared variables for the state in multi-threaded computing. Synchronization eliminates the use of locks in certain scenarios.

#### Actor

> **_The concept of Actor comes from Erlang. In AKKA, an Actor can be thought of as a container for storing state, behavior, Mailbox, and child Actor and Supervisor policies. Actors do not communicate directly, but use Mail to communicate with each other._**

* create actor

We can use co_actor_onqueue to create an actor in the specified thread.

```objc
COActor *actor = co_actor_onqueue(q, ^(COActorChan *channel) {
    ...  //Define the state variable of the actor

    for(COActorMessage *message in channel){
        ...//handle message
    }
});
```

* send a message to the actor

The actor's send method can send a message to the actor

```objc
COActor *actor = co_actor_onqueue(q, ^(COActorChan *channel) {
    ...  //Define the state variable of the actor

    for(COActorMessage *message in channel){
        ...//handle message
    }
});

// send a message to the actor
[actor send:@"sadf"];
[actor send:@(1)];
```

#### tuple

* create tuple
we provide co_tuple method to create tuple

```objc
COTuple *tup = co_tuple(nil, @10, @"abc");
NSAssert(tup[0] == nil, @"tup[0] is wrong");
NSAssert([tup[1] intValue] == 10, @"tup[1] is wrong");
NSAssert([tup[2] isEqualToString:@"abc"], @"tup[2] is wrong");
```

you can store any value in tuple

* unpack tuple
we provide co_unpack method to unpack tuple

```objc
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
```

* use tuple in coroutine
first create a promise that resolve tuple value

```objc
COPromise<COTuple*>*
cotest_loadContentFromFile(NSString *filePath){
    return [COPromise promise:^(COPromiseFullfill  _Nonnull resolve, COPromiseReject  _Nonnull reject) {
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
```

then you can fetch the value like this:

```objc
co_launch(^{
    NSString *tmpFilePath = nil;
    NSData *data = nil;
    NSError *error = nil;
    co_unpack(&tmpFilePath, &data, &error) = await(cotest_loadContentFromFile(filePath));
    XCTAssert([tmpFilePath isEqualToString:filePath], @"file path is wrong");
    XCTAssert(data.length > 0, @"data is wrong");
    XCTAssert(error == nil, @"error is wrong");
});
```

use tuple you can get multiple values from await return

#### Actual case using coobjc

Let's take the code of the Feeds stream update in the GCDFetchFeed open source project as an example to demonstrate the actual usage scenarios and advantages of the coroutine. The following is the original implementation of not using coroutine：

```objc
- (RACSignal *)fetchAllFeedWithModelArray:(NSMutableArray *)modelArray {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        //Create a parallel queue
        dispatch_queue_t fetchFeedQueue = dispatch_queue_create("com.starming.fetchfeed.fetchfeed", DISPATCH_QUEUE_CONCURRENT);
        dispatch_group_t group = dispatch_group_create();
        self.feeds = modelArray;
        for (int i = 0; i < modelArray.count; i++) {
            dispatch_group_enter(group);
            SMFeedModel *feedModel = modelArray[i];
            feedModel.isSync = NO;
            [self GET:feedModel.feedUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                dispatch_async(fetchFeedQueue, ^{
                    @strongify(self);
                    //parse feed
                    self.feeds[i] = [self.feedStore updateFeedModelWithData:responseObject preModel:feedModel];
                    //save to db
                    SMDB *db = [SMDB shareInstance];
                    @weakify(db);
                    [[db insertWithFeedModel:self.feeds[i]] subscribeNext:^(NSNumber *x) {
                        @strongify(db);
                        SMFeedModel *model = (SMFeedModel *)self.feeds[i];
                        model.fid = [x integerValue];
                        if (model.imageUrl.length > 0) {
                            NSString *fidStr = [x stringValue];
                            db.feedIcons[fidStr] = model.imageUrl;
                        }
                        //sendNext
                        [subscriber sendNext:@(i)];
                        //Notification single completion
                        dispatch_group_leave(group);
                    }];
                    
                });//end dispatch async
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                dispatch_async(fetchFeedQueue, ^{
                    @strongify(self);
                    [[[SMDB shareInstance] insertWithFeedModel:self.feeds[i]] subscribeNext:^(NSNumber *x) {
                        SMFeedModel *model = (SMFeedModel *)self.feeds[i];
                        model.fid = [x integerValue];
                        dispatch_group_leave(group);
                    }];
                    
                });//end dispatch async
                
            }];
            
        }//end for
        //Execution event after all is completed
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [subscriber sendCompleted];
        });
        return nil;
    }];
}
```

The following is the call to the above method in viewDidLoad:

```objc
[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
self.fetchingCount = 0;
@weakify(self);
[[[[[[SMNetManager shareInstance] fetchAllFeedWithModelArray:self.feeds] map:^id(NSNumber *value) {
    @strongify(self);
    NSUInteger index = [value integerValue];
    self.feeds[index] = [SMNetManager shareInstance].feeds[index];
    return self.feeds[index];
}] doCompleted:^{
    @strongify(self);
    NSLog(@"fetch complete");
    self.tbHeaderLabel.text = @"";
    self.tableView.tableHeaderView = [[UIView alloc] init];
    self.fetchingCount = 0;
    [self.tableView.mj_header endRefreshing];
    [self.tableView reloadData];
    if ([SMFeedStore defaultFeeds].count > self.feeds.count) {
        self.feeds = [SMFeedStore defaultFeeds];
        [self fetchAllFeeds];
    }
    [self cacheFeedItems];
}] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(SMFeedModel *feedModel) {
    @strongify(self);
    self.tableView.tableHeaderView = self.tbHeaderView;
    self.fetchingCount += 1;
    self.tbHeaderLabel.text = [NSString stringWithFormat:@"正在获取%@...(%lu/%lu)",feedModel.title,(unsigned long)self.fetchingCount,(unsigned long)self.feeds.count];
    feedModel.isSync = YES;
    [self.tableView reloadData];
}];
```

The above code is relatively poor in terms of readability and simplicity. Let's take a look at the code after using the coroutine transformation:

```objc
- (SMFeedModel*)co_fetchFeedModelWithUrl:(SMFeedModel*)feedModel{
    feedModel.isSync = NO;
    id response = await([self co_GET:feedModel.feedUrl parameters:nil]);
    if (response) {
        SMFeedModel *resultModel = await([self co_updateFeedModelWithData:response preModel:feedModel]);
        int fid = [[SMDB shareInstance] co_insertWithFeedModel:resultModel];
        resultModel.fid = fid;
        if (resultModel.imageUrl.length > 0) {
            NSString *fidStr = [@(fid) stringValue];
            [SMDB shareInstance].feedIcons[fidStr] = resultModel.imageUrl;
        }
        return resultModel;
    }
    int fid = [[SMDB shareInstance] co_insertWithFeedModel:feedModel];
    feedModel.fid = fid;
    return nil;
}
```

Here is the place in viewDidLoad that uses the coroutine to call the interface:

```objc
co_launch(^{
    for (NSUInteger index = 0; index < self.feeds.count; index++) {
        SMFeedModel *model = self.feeds[index];
        self.tableView.tableHeaderView = self.tbHeaderView;
        self.tbHeaderLabel.text = [NSString stringWithFormat:@"正在获取%@...(%lu/%lu)",model.title,(unsigned long)(index + 1),(unsigned long)self.feeds.count];
        model.isSync = YES;
        SMFeedModel *resultMode = [[SMNetManager shareInstance] co_fetchFeedModelWithUrl:model];
        if (resultMode) {
            self.feeds[index] = resultMode;
            [self.tableView reloadData];
        }
    }
    self.tbHeaderLabel.text = @"";
    self.tableView.tableHeaderView = [[UIView alloc] init];
    self.fetchingCount = 0;
    [self.tableView.mj_header endRefreshing];
    [self.tableView reloadData];
    [self cacheFeedItems];
});
```

The code after the coroutine transformation has become easier to understand and less error-prone.

#### Swift

coobjc fully supports Swift through top-level encapsulation, enabling us to enjoy the coroutine ahead of time in Swift.
Because Swift has richer and more advanced syntax support, coobjc is more elegant in Swift, for example:

```swift
func test() {
    co_launch {//create coroutine
        //fetch data asynchronous
        let resultStr = try await(channel: co_fetchSomething())
        print("result: \(resultStr)")
    }

    co_launch {//create coroutine
        //fetch data asynchronous
        let result = try await(promise: co_fetchSomethingAsynchronous())
        switch result {
            case .fulfilled(let data):
                print("data: \(String(describing: data))")
                break
            case .rejected(let error):
                print("error: \(error)")
        }
    }
}
```

## 0x4 Advantages of the coroutine

* Concise
  * Less concept: there are only a few operators, compared to dozens of operators in response, it can't be simpler.
  * The principle is simple: the implementation principle of the coroutine is very simple, the entire coroutine library has only a few thousand lines of code
* Easy to use
  * Simple to use: it is easier to use than GCD, with few interfaces
  * Easy to retrofit: existing code can be corouted with only a few changes, and we have a large number of coroutine interfaces for the system library.
* Clear
  * Synchronous write asynchronous logic: Synchronous sequential way of writing code is the most acceptable way for humans, which can greatly reduce the probability of error
  * High readability: Code written in coroutine mode is much more readable than block nested code
* High performance
  * Faster scheduling performance: The coroutine itself does not need to switch between kernel-level threads, scheduling performance is fast, Even if you create tens of thousands of coroutines, there is no pressure.
  * Reduce app block: The use of coroutines to help reduce the abuse of locks and semaphores, and to reduce the number of stalls and jams from the root cause by encapsulating the coroutine interfaces such as IOs that cause blocking, and improve the overall performance of the application.

## 0x5 Communication

* If you **need help**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/coobjc). (Tag 'coobjc')
* If you'd like to **ask a general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/coobjc).
* If you **found a bug**, _and can provide steps to reliably reproduce it_, open an issue.
* If you **have a feature request**, open an issue.
* If you **want to contribute**, submit a pull request.
* If you are interested in **joining Alibaba Taobao-Mobile architecture team**, please send your resume to [junzhan](mailto:junzhan.yzw@taobao.com)

## 0x6 Unit Tests

coobjc includes a suite of unit tests within the Tests subdirectory. These tests can be run simply be executed the test action on the platform framework you would like to test. You can find coobjc's unit tests in Examples/coobjcBaseExample/coobjcBaseExampleTests. You can find cokit's unit tests in cokit/Examples/coKitExamples/coKitExamplesTests.

## 0x7 Credits

coobjc couldn't exist without:

* [Promises](https://github.com/google/promises) - Google's Objective-C and Swift Promises framework.
* [libtask](https://swtch.com/libtask/) - A simple coroutine library.
* [movies](https://github.com/KMindeguia/movies) - a ios demo app, we use the code in coobjc examples
* [v2ex](https://github.com/singro/v2ex) - An iOS client for v2ex.com, we use the code in coobjc examples
* [tuples](https://github.com/atg/tuples) - Objective-C tuples.
* [fishhook](https://github.com/facebook/fishhook) - Rebinding symbols in Mach-O binaries
* [Sol](https://github.com/comyar/Sol) - Sol° beautifully displays weather information so you can plan your day accordingly. Check the weather in your current location or any city around the world. Implemented in Objective-C.
* [Swift](https://github.com/apple/swift) - The Swift Programming Language
* [libdispatch](https://github.com/apple/swift-corelibs-libdispatch) - The libdispatch Project, (a.k.a. Grand Central Dispatch), for concurrency on multicore hardware
* [objc4](https://opensource.apple.com/source/objc4/objc4-750.1/) - apple objc framework
* https://blog.csdn.net/qq910894904/article/details/41911175
* http://www.voidcn.com/article/p-fwlohnnc-gc.html
* https://blog.csdn.net/shenlei19911210/article/details/61194617

## 0x8 Authors

* [pengyutang125](https://github.com/pengyutang125)
* [NianJi](https://github.com/NianJi)
* [intheway](https://github.com/intheway)
* [ValiantCat](https://github.com/ValiantCat)
* [jmpews](https://github.com/jmpews)

## 0x9 Contributing

* [Contributing](./CONTRIBUTING.md)

## 0xA License

coobjc is released under the Apache 2.0 license. See [LICENSE](LICENSE) for details.
