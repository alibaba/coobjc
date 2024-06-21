<p align="center" >
  <img src="coobjc_icon.png" alt="coobjc" title="coobjc">
</p>

这个库为 Objective-C 和 Swift 提供了协程功能。coobjc 支持 await、generator 和 actor model，接口参考了 C# 、Javascript 和 Kotlin 中的很多设计。我们还提供了 [cokit 库](cokit/README.md)为 Foundation 和 UIKit 中的部分 API 提供了协程化支持，包括 NSFileManager , JSON , NSData , UIImage 等。coobjc 也提供了元组的支持。

## 0x0 iOS 异步编程问题

基于 Block 的异步编程回调是目前 iOS 使用最广泛的异步编程方式，iOS 系统提供的 GCD 库让异步开发变得很简单方便，但是基于这种编程方式的缺点也有很多，主要有以下几点：

* 容易进入"嵌套地狱"
* 错误处理复杂和冗长
* 容易忘记调用 completion handler
* 条件执行变得很困难
* 从互相独立的调用中组合返回结果变得极其困难
* 在错误的线程中继续执行
* 难以定位原因的多线程崩溃
* 锁和信号量滥用带来的卡顿、卡死

上述问题反应到线上应用本身就会出现大量的多线程崩溃

## 0x1 解决方案

上述问题在很多系统和语言中都会遇到，解决问题的标准方式就是使用协程。这里不介绍太多的理论，简单说协程就是对基础函数的扩展，可以让函数异步执行的时候挂起然后返回值。协程可以用来实现 generator ，异步模型以及其他强大的能力。

Kotlin 是这两年由 JetBrains 推出的支持现代多平台应用的静态编程语言，支持 JVM ，Javascript ，目前也可以在 iOS 上执行，这两年在开发者社区中也是比较火。  
在 Kotlin 语言中基于协程的 async/await ，generator/yield 等异步化技术都已经成了语法标配，Kotlin 协程相关的介绍，大家可以参考：[https://www.kotlincn.net/docs/reference/coroutines/basics.html](https://www.kotlincn.net/docs/reference/coroutines/basics.html)

## 0x2 协程

> **协程是一种在非抢占式多任务场景下生成可以在特定位置挂起和恢复执行入口的程序组件**

协程的概念在60年代就已经提出，目前在服务端中应用比较广泛，在高并发场景下使用极其合适，可以极大降低单机的线程数，提升单机的连接和处理能力，但是在移动研发中，iOS和android目前都不支持协程的使用

## 0x3 coobjc 框架

coobjc 是由手机淘宝架构团队推出的能在 iOS 上使用的协程开发框架，目前支持 Objective-C 和 Swift 中使用，我们底层使用汇编和 C 语言进行开发，上层进行提供了 Objective-C 和 Swift 的接口，目前以 Apache 开源协议进行了开源。

### 0x31 安装

* cocoapods 安装:  pod 'coobjc'
* 源码安装: 所有代码在 ./coobjc 目录下

### 0x32 文档

* 阅读 [协程框架设计](docs/arch_design.md) 文档。
* 阅读 [coobjc Objective-C Guide](docs/usage.md) 文档。
* 阅读 [coobjc Swift Guide](docs/usage_swift.md) 文档。
* 阅读 [cokit framework](cokit/README.md) 文档, 学习如何使用系统接口封装的 api 。

### 0x33 特性

#### async/await

* 创建协程

使用 `co_launch` 方法创建协程

```objc
co_launch(^{
    ...
});
```

`co_launch` 创建的协程默认在当前线程进行调度

* await 异步方法

在协程中我们使用 await 方法等待异步方法执行结束，得到异步执行结果

```objc
- (void)viewDidLoad{
    ...
        co_launch(^{
            NSData *data = await(downloadDataFromUrl(url));
            UIImage *image = await(imageFromData(data));
            self.imageView.image = image;
        });
}
```

上述代码将原本需要 `dispatch_async` 两次的代码变成了顺序执行，代码更加简洁

* 错误处理

在协程中，我们所有的方法都是直接返回值的，并没有返回错误，我们在执行过程中的错误是通过 `co_getError()` 获取的，比如我们有以下从网络获取数据的接口，在失败的时候， promise 会 `reject:error`。

```objc
- (COPromise*)co_GET:(NSString*)url
  parameters:(NSDictionary*)parameters{
    COPromise *promise = [COPromise promise];
    [self GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [promise fulfill:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [promise reject:error];
    }];
    return promise;
}
```

那我们在协程中可以如下使用：

```objc
co_launch(^{
    id response = await([self co_GET:feedModel.feedUrl parameters:nil]);
    if(co_getError()){
        //处理错误信息
    }
    ...
});
```

#### 生成器

* 创建生成器

我们使用 `co_sequence` 创建生成器

```objc
COGenerator *co1 = co_sequence(^{
            int index = 0;
            while(co_isActive()){
                yield_val(@(index));
                index++;
            }
        });
```

在其他协程中，我们可以调用 `next` 方法，获取生成器中的数据

```objc
co_launch(^{
            for(int i = 0; i < 10; i++){
                val = [[co1 next] intValue];
            }
        });
```

* 使用场景

生成器可以在很多场景中进行使用，比如消息队列、批量下载文件、批量加载缓存等：

```objc
int unreadMessageCount = 10;
NSString *userId = @"xxx";
COSequence *messageSequence = sequenceOnBackgroundQueue(@"message_queue", ^{
   //在后台线程执行
    while(1){
        yield(queryOneNewMessageForUserWithId(userId));
    }
});

//主线程更新UI
co(^{
   for(int i = 0; i < unreadMessageCount; i++){
       if(!isQuitCurrentView()){
           displayMessage([messageSequence take]);
       }
   }
});
```

通过生成器，我们可以把传统的生产者加载数据->通知消费者模式，变成消费者需要数据->告诉生产者加载模式，避免了在多线程计算中，需要使用很多共享变量进行状态同步，消除了在某些场景下对于锁的使用。

#### Actor

> **_ Actor 的概念来自于 Erlang ，在 AKKA 中，可以认为一个 Actor 就是一个容器，用以存储状态、行为、Mailbox 以及子 Actor 与 Supervisor 策略。Actor 之间并不直接通信，而是通过 Mail 来互通有无。_**

* 创建 actor

我们可以使用 `co_actor_onqueue` 在指定线程创建 actor

```objc
COActor *actor = co_actor_onqueue(^(COActorChan *channel) {
    ...  //定义 actor 的状态变量
    for(COActorMessage *message in channel){
        ...//处理消息
    }
}, q);
```

* 给 actor 发送消息

actor 的 `send` 方法可以给 actor 发送消息

```objc
COActor *actor = co_actor_onqueue(^(COActorChan *channel) {
    ...  //定义actor的状态变量
    for(COActorMessage *message in channel){
        ...//处理消息
    }
}, q);

// 给actor发送消息
[actor send:@"sadf"];
[actor send:@(1)];

```

#### 元组

* 创建元组

使用 `co_tuple` 方法来创建元组

```objc
COTuple *tup = co_tuple(nil, @10, @"abc");
NSAssert(tup[0] == nil, @"tup[0] is wrong");
NSAssert([tup[1] intValue] == 10, @"tup[1] is wrong");
NSAssert([tup[2] isEqualToString:@"abc"], @"tup[2] is wrong");
```

可以在元组中存储任何数据

* 元组取值

可以使用 `co_unpack` 方法从元组中取值

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

* 在协程中使用元组

首先创建一个 promise 来处理元组里的值

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

然后，你可以像下面这样获取元组里的值：

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

使用元组你可以从 `await` 返回值中获取多个值

#### 演示项目

我们以 GCDFetchFeed 开源项目中 Feeds 流更新的代码为例，演示一下协程的实际使用场景和优势，下面是原始的不使用协程的实现：

```objc
- (RACSignal *)fetchAllFeedWithModelArray:(NSMutableArray *)modelArray {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        //创建并行队列
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
                    //解析feed
                    self.feeds[i] = [self.feedStore updateFeedModelWithData:responseObject preModel:feedModel];
                    //入库存储
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
                        //插入本地数据库成功后开始sendNext
                        [subscriber sendNext:@(i)];
                        //通知单个完成
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

        } //end for
        //全完成后执行事件
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [subscriber sendCompleted];
        });
        return nil;
    }];
}
```

下面是 `viewDidLoad` 中对上述方法的调用：

```objc
[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
self.fetchingCount = 0; //统计抓取数量
@weakify(self);
[[[[[[SMNetManager shareInstance] fetchAllFeedWithModelArray:self.feeds] map:^id(NSNumber *value) {
    @strongify(self);
    NSUInteger index = [value integerValue];
    self.feeds[index] = [SMNetManager shareInstance].feeds[index];
    return self.feeds[index];
}] doCompleted:^{
    //抓完所有的feeds
    @strongify(self);
    NSLog(@"fetch complete");
    //完成置为默认状态
    self.tbHeaderLabel.text = @"";
    self.tableView.tableHeaderView = [[UIView alloc] init];
    self.fetchingCount = 0;
    //下拉刷新关闭
    [self.tableView.mj_header endRefreshing];
    //更新列表
    [self.tableView reloadData];
    //检查是否需要增加源
    if ([SMFeedStore defaultFeeds].count > self.feeds.count) {
        self.feeds = [SMFeedStore defaultFeeds];
        [self fetchAllFeeds];
    }
    //缓存未缓存的页面
    [self cacheFeedItems];
}] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(SMFeedModel *feedModel) {
    //抓完一个
    @strongify(self);
    self.tableView.tableHeaderView = self.tbHeaderView;
    //显示抓取状态
    self.fetchingCount += 1;
    self.tbHeaderLabel.text = [NSString stringWithFormat:@"正在获取%@...(%lu/%lu)",feedModel.title,(unsigned long)self.fetchingCount,(unsigned long)self.feeds.count];
    feedModel.isSync = YES;
    [self.tableView reloadData];
}];
```

上述代码无论从可读性还是简洁性上都比较差，下面我们看一下使用协程改造以后的代码：

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

下面是 `viewDidLoad` 中使用协程调用该接口的地方:

```objc
co_launch(^{
    for (NSUInteger index = 0; index < self.feeds.count; index++) {
        SMFeedModel *model = self.feeds[index];
        self.tableView.tableHeaderView = self.tbHeaderView;
        //显示抓取状态
        self.tbHeaderLabel.text = [NSString stringWithFormat:@"正在获取%@...(%lu/%lu)",model.title,(unsigned long)(index + 1),(unsigned long)self.feeds.count];
        model.isSync = YES;
        //协程化加载数据
        SMFeedModel *resultMode = [[SMNetManager shareInstance] co_fetchFeedModelWithUrl:model];
        if (resultMode) {
            self.feeds[index] = resultMode;
            [self.tableView reloadData];
        }
    }
    self.tbHeaderLabel.text = @"";
    self.tableView.tableHeaderView = [[UIView alloc] init];
    self.fetchingCount = 0;
    //下拉刷新关闭
    [self.tableView.mj_header endRefreshing];
    //更新列表
    [self.tableView reloadData];
    //检查是否需要增加源
    [self cacheFeedItems];
});
```

协程化改造之后的代码，变得更加简单易懂，不易出错

#### Swift

coobjc 通过上层封装来全面支持 Swift ，这使得我们可以提早在 Swift 中使用协程。

由于 Swift 拥有更丰富和更高阶的语法支持，因而 coobjc 在 Swift 中的使用会更优雅，例如：

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

## 0x4 协程的优势

* 简明
  * 概念少：只有很少的几个操作符，相比响应式几十个操作符，简直不能再简单了
  * 原理简单: 协程的实现原理很简单，整个协程库只有几千行代码
* 易用
  * 使用简单：它的使用方式比 GCD 还要简单，接口很少
  * 改造方便：现有代码只需要进行很少的改动就可以协程化，同时我们针对系统库提供了大量协程化接口
* 清晰
  * 同步写异步逻辑：同步顺序方式写代码是人类最容易接受的方式，这可以极大的减少出错的概率
  * 可读性高: 使用协程方式编写的代码比 block 嵌套写出来的代码可读性要高很多
* 性能
  * 调度性能更快：协程本身不需要进行内核级线程的切换，调度性能快，即使创建上万个协程也毫无压力
  * 减少卡顿卡死: 协程的使用以帮助开发减少锁、信号量的滥用，通过封装会引起阻塞的 IO 等协程接口，可以从根源上减少卡顿、卡死，提升应用整体的性能

## 0x5 交流

* 如果你**需要帮助**，请使用 [Stack Overflow](http://stackoverflow.com/questions/tagged/coobjc)。(标签为 'coobjc')
* 如果你想**提问**，请使用 [Stack Overflow](http://stackoverflow.com/questions/tagged/coobjc)。
* 如果你**发现了 bug**，并且可以提供可稳定复现的步骤，请开 issue。
* 如果你有**新特性需求**，请开 issue。
* 如果你**想贡献代码**，请提交 PR。

## 0x6 单元测试

coobjc includes a suite of unit tests within the Tests subdirectory. These tests can be run simply be executed the test action on the platform framework you would like to test.

## 0x7 致谢

coobjc 离不开下面这些项目和文章的帮助:

* [Promises](https://github.com/google/promises) - Google 开源的 Objective-C 和 Swift 版本的 Promise 框架
* [libtask](https://swtch.com/libtask/) - 一个简易的协程库
* [movies](https://github.com/KMindeguia/movies) - 一个 iOS 演示项目，我们在 coobjc 的示例中使用了其中的代码
* [v2ex](https://github.com/singro/v2ex) - v2ex.com 的 iOS 客户端项目，我们在 coobjc 的示例中使用了其中的代码
* [tuples](https://github.com/atg/tuples) - Objective-C 元组
* [Swift](https://github.com/apple/swift) - The Swift Programming Language
* [libdispatch](https://github.com/apple/swift-corelibs-libdispatch) - The libdispatch Project, (a.k.a. Grand Central Dispatch), for concurrency on multicore hardware
* [objc4](https://opensource.apple.com/source/objc4/objc4-750.1/) - apple objc framework
* https://blog.csdn.net/qq910894904/article/details/41911175
* http://www.voidcn.com/article/p-fwlohnnc-gc.html
* https://blog.csdn.net/shenlei19911210/article/details/61194617

## 0x8 作者

* [pengyutang125](https://github.com/pengyutang125)
* [NianJi](https://github.com/NianJi)
* [intheway](https://github.com/intheway)
* [ValiantCat](https://github.com/ValiantCat)
* [jmpews](https://github.com/jmpews)

## 0x9贡献代码

* [贡献指南](./CONTRIBUTING_CHINESE.md)

## 0xA 协议

coobjc 使用 Apache 2.0 协议，详情见 [LICENSE](LICENSE) 文件。
