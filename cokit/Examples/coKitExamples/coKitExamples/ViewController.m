//
//  ViewController.m
//  coKitExamples
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

#import "ViewController.h"
#import <cokit/NSXMLParser+Coroutine.h>
#import <coobjc/coobjc.h>

//@interface Channel: NSObject
//
//@property (nonatomic, strong) NSString *title;
//@property (nonatomic, strong) NSString *link;
//@property (nonatomic, strong) NSString *desc;
//@property (nonatomic, strong) NSMutableArray *images;
//@property (nonatomic, strong) NSMutableArray *items;
//
//@end
//
//@interface Image: NSObject
//
//@property (nonatomic, strong) NSString *url;
//@property (nonatomic, strong) NSString *link;
//
//@end
//
//@interface Item: NSObject
//
//@property (nonatomic, strong) NSString *title;
//@property (nonatomic, strong) NSString *link;
//@property (nonatomic, strong) NSString *desc;
//
//@end




@interface ViewController ()<NSXMLParserDelegate>

//// 0: 初始化状态, 1: 处于channel中, 2: 处于image中, 3: 处于item中, 4: url, 5: title, 6: description, 7: link
//@property (nonatomic, assign) int state;
//@property (nonatomic, strong) NSMutableArray *states;
//@property (nonatomic, strong) Channel *curChannel;
//@property (nonatomic, strong) Image *curImage;
//@property (nonatomic, strong) Item *curItem;
//@property (nonatomic, strong) NSString *content;

@end

@implementation ViewController

//- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict{
//    if ([elementName isEqualToString:@"channel"]) {
//        self.state = 1;
//        _curChannel = [[Channel alloc] init];
//    }
//    else if([elementName isEqualToString:@"image"]){
//        [self.states addObject:@(self.state)];
//        self.state = 2;
//        _curImage = [[Image alloc] init];
//        [_curChannel.images addObject:_curImage];
//    }
//    //...
//}
//- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
//    self.content = string;
//}
//- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName{
//    //...
//    if([elementName isEqualToString:@"link"]){
//        self.state = [[self.states lastObject] intValue];
//        [self.states removeLastObject];
//        if(self.state == 1){
//            _curChannel.link = self.content;
//        }
//        else if (self.state == 2) {
//            _curImage.link = self.content;
//        }
//        else if(self.state == 3){
//            _curItem.link = self.content;
//        }
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    NSData *data = nil;
//    COCoroutine *xml_generator = [NSXMLParser co_parseData:data];
//    
//    co_launch(^{
//        COXMLItem *item = nil;
//        Channel *chanel = [[Channel alloc] init];
//        NSMutableDictionary *image = nil;
//        NSMutableDictionary *dataItem = nil;
//        while (1) {
//            item = [xml_generator next];
//            if (item.itemType == COXMLItemDidStartElement && [item.elementName isEqualToString:@"image"]) {
//                image = [[NSMutableDictionary alloc] init];
//            }
//            if (item.itemType == COXMLItemDidEndElement && [item.elementName isEqualToString:@"image"]) {
//                [chanel.images addObject:image];
//                image = nil;
//            }
//            if (item.itemType == COXMLItemDidStartElement && [item.elementName isEqualToString:@"item"]) {
//                dataItem = [[NSMutableDictionary alloc] init];
//            }
//            //...
//        }
//    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
