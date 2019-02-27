//
//  NSXMLParser+Coroutine.h
//  cokit
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

#import <Foundation/Foundation.h>
#import <coobjc/coobjc.h>

NS_ASSUME_NONNULL_BEGIN

#define COXMLParserCancelledError 200

typedef NS_ENUM(NSUInteger, COXMLItemType) {
    COXMLItemStart = 1,
    COXMLItemEnd = 2,
    COXMLItemNotation,
    COXMLItemUnparsedEntity,
    COXMLItemAttribute,
    COXMLItemElement,
    COXMLItemInternalEntity,
    COXMLItemExternalEntity,
    COXMLItemDidStartElement,
    COXMLItemDidEndElement,
    COXMLItemDidStartMapping,
    COXMLItemDidEndMapping,
    COXMLItemCharacters,
    COXMLItemIgnorableWhitespace,
    COXMLItemProcessingInstruction,
    COXMLItemComment,
    COXMLItemCDATA,
    COXMLItemError,
};

@interface COXMLItem: NSObject

@property (nonatomic, assign) COXMLItemType itemType;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *publicID;
@property (nonatomic, strong) NSString *systemID;
@property (nonatomic, strong) NSString *notationName;

@property (nonatomic, strong) NSString *attributeName;
@property (nonatomic, strong) NSString *attributeType;
@property (nonatomic, strong) NSString *defaultValue;

@property (nonatomic, strong) NSString *elementName;
@property (nonatomic, strong) NSString *elementModel;

@property (nonatomic, strong) NSString *value;

@property (nonatomic, strong) NSString *namespaceURI;
@property (nonatomic, strong) NSString *qualifiedName;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *attributes;

@property (nonatomic, strong) NSString *mappingPrefix;

@property (nonatomic, strong) NSString *characters;

@property (nonatomic, strong) NSString *whitespaceString;

@property (nonatomic, strong) NSString *target;
@property (nonatomic, strong) NSString *data;

@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSData *CDATABlock;

@property (nonatomic, strong) NSError *error;

+ (instancetype)makeStartItem;
+ (instancetype)makeEndItem;
+ (instancetype)makeErrorItem:(NSError*)error;

@end

@interface NSXMLParser (Coroutine)

- (COCoroutine*)co_parse;

+ (COCoroutine*)co_parseContentsOfURL:(NSURL*)url;

+ (COCoroutine*)co_parseData:(NSData*)data;

+ (COCoroutine*)co_parseStream:(NSInputStream*)stream;

@end

NS_ASSUME_NONNULL_END
