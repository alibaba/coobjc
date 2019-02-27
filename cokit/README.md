
## 0x0 cokit
The cokit library provides a coroutine wrapper for the Foundation and UIKit system libraries, which relies on the coobjc library to provide a co-processed wrapper for time-consuming methods such as IO, networking, etc.

## 0x1 Install cokit

```plain
pod 'cokit'
pod 'coobjc'
```

## 0x2 Guide

* NSArray + Coroutine

```objc
co_launch(^{
    for (int i = 0; i < 100; i++) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for (int j = 0; j < 10; j++) {
            [list addObject:@(rand() % 1000)];
        }
        NSArray *tmpList = [list copy];
        NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file_%d", i]];

        // async write to file
        await([tmpList co_writeToFile:filePath atomically:YES]);
        
        XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
        
        // async load from file
        NSArray *resultList = await([[NSArray alloc] co_initWithContentsOfFile:filePath]);
        
        XCTAssert(resultList.count == list.count);
        
        for (int j = 0; j < 10; j++) {
            XCTAssert([list[j] intValue] == [resultList[j] intValue]);
        }
        
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
});
```

* NSData + Coroutine

```objc
co_launch(^{
    for (int i = 0; i < 10; i++) {
        NSMutableString *originStr = [[NSMutableString alloc] init];
        for (int j = 0; j < 1024; j++) {
            [originStr appendFormat:@"%c", 'a' + (rand() % 23)];
        }
        
        NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file_%d", i]];

        
        NSData *data = [originStr dataUsingEncoding:NSUTF8StringEncoding];
        
        //async write to file
        await([data co_writeToFile:filePath atomically:YES]);
        
        XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);

        //async load from file
        NSData *resultData = await([[NSData alloc] co_initWithContentsOfFile:filePath]);
        
        XCTAssert(data.length == resultData.length);
        
        NSString *resultStr = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
        
        XCTAssert([resultStr isEqualToString:originStr]);
        
    }
});
```

* NSXMLParser + Coroutine

```c
COCoroutine *parse_generator = [NSXMLParser co_parseContentsOfURL:[NSURL URLWithString:@"http://xxx.xml"]];
co_launch(^{
    COXMLItem *item = nil;
    int testsuitesCount = 0;
    int testsuiteCount = 0;
    int testcaseCount = 0;
    while (1) {
        item = [parse_generator next];
        if (item.itemType == COXMLItemDidStartElement) {
            if ([item.elementName isEqualToString:@"testsuites"]) {
                testsuitesCount++;
            }
            if ([item.elementName isEqualToString:@"testsuite"]) {
                testsuiteCount++;
            }
            if ([item.elementName isEqualToString:@"testcase"]) {
                testcaseCount++;
            }
        }
        NSLog(@"%@", item);
        if (item == nil || item.itemType == COXMLItemError || item.itemType == COXMLItemEnd) {
            break;
        }
    }
    
    XCTAssert(testsuitesCount == 1);
    XCTAssert(testsuiteCount == 4);
    XCTAssert(testcaseCount == 12);
});
```


* NSDictionary + Coroutine

```c
co_launch(^{
    for (int i = 0; i < 101; i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (int j = 0; j < 10; j++) {
            [dict setValue:@(rand() % 1000) forKey:[NSString stringWithFormat:@"key_%d", j]];
        }
        NSDictionary *tmpDict = [dict copy];
        NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file_%d", i]];
        await([tmpDict co_writeToFile:filePath atomically:YES]);
        
        XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
        
        NSDictionary *resultDict = await([[NSDictionary alloc] co_initWithContentsOfFile:filePath]);
        XCTAssert(resultDict.count == tmpDict.count);
    
        for (NSString *key in resultDict) {
            id val1 = resultDict[key];
            id val2 = tmpDict[key];
            XCTAssert([val1 intValue] == [val2 intValue]);
        }
        
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
});
```

* NSFileManager + Coroutine

```c
co_launch(^{
    for (int i = 0; i < 10; i++) {
        NSString *dirName = [NSString stringWithFormat:@"dir_%d", i];
        NSString *dirPath = [[self tempPath] stringByAppendingPathComponent:dirName];
        BOOL ret = [await([[NSFileManager defaultManager] co_createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil]) boolValue];
        
        XCTAssert(ret == YES);
        XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:dirPath]);
        
        id retValue = nil;
        id isDir = nil;
        co_unpack(&retValue, &isDir) = await([[NSFileManager defaultManager] co_fileExistsAtPath:dirPath]);
    
        XCTAssert([retValue boolValue]);
        XCTAssert([isDir boolValue]);
        
        await([[NSFileManager defaultManager] co_removeItemAtPath:dirPath]);
        
        XCTAssert(![[NSFileManager defaultManager] fileExistsAtPath:dirPath]);

        co_unpack(&retValue) = await([[NSFileManager defaultManager] co_fileExistsAtPath:dirPath]);
        
        XCTAssert(![retValue boolValue]);
    }
});
```

```c
co_launch(^{
    NSString *testJSONPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
    
    NSData *data = await([NSData co_dataWithContentsOfFile:testJSONPath]);
    
    XCTAssert(data.length > 0);
    
    NSDictionary *dict = await([NSJSONSerialization co_JSONObjectWithData:data options:0]);
    
    XCTAssert([dict isKindOfClass:[NSDictionary class]]);
    
    NSDictionary *dict1 = dict[@"glossary"];
    XCTAssert(dict1.count > 0);
    
    NSDictionary *dict2 = dict1[@"GlossDiv"];
    XCTAssert(dict2.count > 0);
    
    NSDictionary *dict3 = dict2[@"GlossList"];
    XCTAssert(dict3.count > 0);
    
});
```

* NSKeyedArchieve + Coroutine

```c
co_launch(^{
    for (int i = 0; i < 100; i++) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for (int j = 0; j < 10; j++) {
            [list addObject:@(rand() % 1000)];
        }
        NSArray *tmpList = [list copy];
        NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file_%d", i]];
        await([NSKeyedArchiver co_archiveRootObject:tmpList toFile:filePath]);
        
        XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
        
        NSArray *resultList = await([NSKeyedUnarchiver co_unarchiveObjectWithFile:filePath]);
        
        XCTAssert(resultList.count == list.count);
        
        for (int j = 0; j < 10; j++) {
            XCTAssert([list[j] intValue] == [resultList[j] intValue]);
        }
        
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
});
```

* NSString + Coroutine

```c
co_launch(^{
    for (int i = 0; i < 101; i++) {
        NSMutableString *mutlContent = [[NSMutableString alloc] init];
        for (int j = 0; j < 10; j++) {
            [mutlContent appendFormat:@"%d_", rand()];
        }
        NSString *tmpStr = [mutlContent copy];
        NSString *filePath = [[self tempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"file_%d", i]];
        await([tmpStr co_writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding]);
        
        XCTAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
        
        NSString *retStr = nil;
        
        co_unpack(&retStr) = await([NSString co_stringWithContentsOfFile:filePath]);
        
        XCTAssert([retStr isEqualToString:tmpStr]);
        
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
});
```

* NSURLConnection + Coroutine

```c
co_launch(^{
    NSURLResponse *response = nil;
    NSData *data = nil;
    co_unpack(&response, &data) = await([NSURLConnection co_sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/DaveGamble/cJSON/master/tests/inputs/test1"]]]);
    
    XCTAssert(response != nil);
    XCTAssert(data.length > 0);
    
    NSDictionary *dict = await([NSJSONSerialization co_JSONObjectWithData:data options:0]);
    
    XCTAssert(dict.count > 0);
    XCTAssert([(NSDictionary*)dict[@"glossary"] count] > 0);
});
```

* NSURLSession + Coroutine

```c
co_launch(^{
    NSURLResponse *response = nil;
    NSData *data = nil;
    co_unpack(&data, &response) = await([[NSURLSession sharedSession] co_dataTaskWithURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/DaveGamble/cJSON/master/tests/inputs/test1"]]);
    
    XCTAssert(response != nil);
    XCTAssert(data.length > 0);
    
    NSDictionary *dict = await([NSJSONSerialization co_JSONObjectWithData:data options:0]);
    
    XCTAssert(dict.count > 0);
    XCTAssert([(NSDictionary*)dict[@"glossary"] count] > 0);
});
```

* NSUserDefaults + Coroutine

```plain
co_launch(^{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    await([defaults co_setInteger:1000 forKey:@"int1"]);
    
    NSInteger val = [defaults co_integerForKey:@"int1"];
    XCTAssert(1000 == val);
    
    await([defaults co_setBool:YES forKey:@"bool1"]);
    BOOL val1 = [defaults co_boolForKey:@"bool1"];
    XCTAssert(val1 == YES);
    
    await([defaults co_setDouble:10.0 forKey:@"double1"]);
    double double1 = [defaults co_doubleForKey:@"double1"];
    XCTAssert(fabs(double1 - 10) <= 0.00001);
    
    await([defaults co_setObject:@"hello world" forKey:@"string1"]);
    NSString *string1 = await([defaults co_objectForKey:@"string1"]);
    XCTAssert([string1 isEqualToString:@"hello world"]);
    
});
```

* UIAlertController+Coroutine

```plain
co_launch(^{
    NSString *title = NSLocalizedString(@"A Short Title Is Best", nil);
    NSString *message = NSLocalizedString(@"A message should be a short, complete sentence.", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitleOne = NSLocalizedString(@"Choice One", nil);
    NSString *otherButtonTitleTwo = NSLocalizedString(@"Choice Two", nil);
    
    UIAlertController *alertController = [UIAlertController co_alertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles: otherButtonTitleOne, otherButtonTitleTwo, nil];
    
    NSString *result = await([alertController co_presentFromController:self]);
    
    
    NSLog(@"The %@ alert's action occured.", result);
});
```

* UIImagePickerController+Coroutine

```plain
co_launch(^{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    COImagePickerResult *result = await([controller co_presentFromController:self]);
    if (result) {
        self.imageView.image = result.originalImage;
    }
});
```


