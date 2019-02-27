//
//  NSXMLParser+Coroutine.m
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

#import "NSXMLParser+Coroutine.h"
#import "COKitCommon.h"

#define CO_XML_CHECK_CANCEL() \
if (!co_isActive) { \
[parser abortParsing]; \
yield_val([COXMLItem makeErrorItem:[NSError  errorWithDomain:NSXMLParserErrorDomain code:COXMLParserCancelledError  userInfo:@{NSLocalizedDescriptionKey:@"parse cancelled"}]]); \
return; \
}

@implementation COXMLItem

+ (instancetype)makeStartItem{
    COXMLItem *item = [[COXMLItem alloc] init];
    item.itemType = COXMLItemStart;
    return item;
}

+ (instancetype)makeEndItem{
    COXMLItem *item = [[COXMLItem alloc] init];
    item.itemType = COXMLItemEnd;
    return item;
}

+ (instancetype)makeErrorItem:(NSError *)error{
    COXMLItem *item = [[COXMLItem alloc] init];
    item.itemType = COXMLItemError;
    item.error = error;
    return item;
}

@end

@interface COXMLParserDelegate: NSObject <NSXMLParserDelegate>

+ (instancetype)sharedDelegate;

@end

@implementation COXMLParserDelegate

+ (instancetype)sharedDelegate{
    static COXMLParserDelegate *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[COXMLParserDelegate alloc] init];
    });
    return instance;
}

// Document handling methods
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    CO_XML_CHECK_CANCEL()
    yield_val([COXMLItem makeStartItem]);
}
// sent when the parser begins parsing of the document.
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    CO_XML_CHECK_CANCEL()
    yield_val([COXMLItem makeEndItem]);
}
// sent when the parser has completed parsing. If this is encountered, the parse was successful.


// DTD handling methods for various declarations.
- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID{
    CO_XML_CHECK_CANCEL()
    COXMLItem *item = [[COXMLItem alloc] init];
    item.name = name;
    item.publicID = publicID;
    item.itemType = COXMLItemNotation;
    item.systemID = systemID;
    yield_val(item);
}

- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID notationName:(nullable NSString *)notationName{
    CO_XML_CHECK_CANCEL()
    COXMLItem *item = [[COXMLItem alloc] init];
    item.itemType = COXMLItemUnparsedEntity;
    item.name = name;
    item.publicID = publicID;
    item.systemID = systemID;
    item.notationName = notationName;
    yield_val(item);
}

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(nullable NSString *)type defaultValue:(nullable NSString *)defaultValue{
    CO_XML_CHECK_CANCEL()
    COXMLItem *item = [[COXMLItem alloc] init];
    item.itemType = COXMLItemAttribute;
    item.attributeName = attributeName;
    item.elementName = elementName;
    item.attributeType = type;
    item.defaultValue = defaultValue;
    yield_val(item);
}

- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model{
    CO_XML_CHECK_CANCEL()
    COXMLItem *item = [[COXMLItem alloc] init];
    item.itemType = COXMLItemElement;
    item.elementName = elementName;
    item.elementModel = model;
    yield_val(item);
}

- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(nullable NSString *)value{
    CO_XML_CHECK_CANCEL()
    COXMLItem *item = [[COXMLItem alloc] init];
    item.itemType = COXMLItemInternalEntity;
    item.name = name;
    item.value = value;
    yield_val(item);
}

- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID{
    CO_XML_CHECK_CANCEL()
    COXMLItem *item = [[COXMLItem alloc] init];
    item.itemType = COXMLItemExternalEntity;
    item.name = name;
    item.publicID = publicID;
    item.systemID = systemID;
    yield_val(item);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict{
    CO_XML_CHECK_CANCEL()
    COXMLItem *item = [[COXMLItem alloc] init];
    item.itemType = COXMLItemDidStartElement;
    item.elementName = elementName;
    item.namespaceURI = namespaceURI;
    item.qualifiedName = qName;
    item.attributes = attributeDict;
    yield_val(item);
}
// sent when the parser finds an element start tag.
// In the case of the cvslog tag, the following is what the delegate receives:
//   elementName == cvslog, namespaceURI == http://xml.apple.com/cvslog, qualifiedName == cvslog
// In the case of the radar tag, the following is what's passed in:
//    elementName == radar, namespaceURI == http://xml.apple.com/radar, qualifiedName == radar:radar
// If namespace processing >isn't< on, the xmlns:radar="http://xml.apple.com/radar" is returned as an attribute pair, the elementName is 'radar:radar' and there is no qualifiedName.

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName{
    CO_XML_CHECK_CANCEL()
    COXMLItem *item = [[COXMLItem alloc] init];
    item.itemType = COXMLItemDidEndElement;
    item.elementName = elementName;
    item.namespaceURI = namespaceURI;
    item.qualifiedName = qName;
    yield_val(item);
}
// sent when an end tag is encountered. The various parameters are supplied as above.

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI{
    CO_XML_CHECK_CANCEL()
    COXMLItem *item = [[COXMLItem alloc] init];
    item.itemType = COXMLItemDidStartMapping;
    item.mappingPrefix = prefix;
    item.namespaceURI = namespaceURI;
    yield_val(item);
}
// sent when the parser first sees a namespace attribute.
// In the case of the cvslog tag, before the didStartElement:, you'd get one of these with prefix == @"" and namespaceURI == @"http://xml.apple.com/cvslog" (i.e. the default namespace)
// In the case of the radar:radar tag, before the didStartElement: you'd get one of these with prefix == @"radar" and namespaceURI == @"http://xml.apple.com/radar"

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix{
    CO_XML_CHECK_CANCEL()
    COXMLItem *item = [[COXMLItem alloc] init];
    item.itemType = COXMLItemDidEndMapping;
    item.mappingPrefix = prefix;
    yield_val(item);
}
// sent when the namespace prefix in question goes out of scope.

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    CO_XML_CHECK_CANCEL()
    COXMLItem *item = [[COXMLItem alloc] init];
    item.itemType = COXMLItemCharacters;
    item.characters = string;
    yield_val(item);
}
// This returns the string of the characters encountered thus far. You may not necessarily get the longest character run. The parser reserves the right to hand these to the delegate as potentially many calls in a row to -parser:foundCharacters:

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString{
    CO_XML_CHECK_CANCEL()
    COXMLItem *item = [[COXMLItem alloc] init];
    item.itemType = COXMLItemIgnorableWhitespace;
    item.whitespaceString = whitespaceString;
    yield_val(item);
}
// The parser reports ignorable whitespace in the same way as characters it's found.

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(nullable NSString *)data{
    CO_XML_CHECK_CANCEL()
    COXMLItem *item = [[COXMLItem alloc] init];
    item.itemType = COXMLItemProcessingInstruction;
    item.target = target;
    item.data = data;
    yield_val(item);
}
// The parser reports a processing instruction to you using this method. In the case above, target == @"xml-stylesheet" and data == @"type='text/css' href='cvslog.css'"

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment{
    CO_XML_CHECK_CANCEL()
    COXMLItem *item = [[COXMLItem alloc] init];
    item.itemType = COXMLItemComment;
    item.comment = comment;
    yield_val(item);
}
// A comment (Text in a <!-- --> block) is reported to the delegate as a single string

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock{
    CO_XML_CHECK_CANCEL()
    COXMLItem *item = [[COXMLItem alloc] init];
    item.itemType = COXMLItemCDATA;
    item.CDATABlock = CDATABlock;
    yield_val(item);
}
//// this reports a CDATA block to the delegate as an NSData.
//
//- (nullable NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(nullable NSString *)systemID{
//    COXMLItem *item = [[COXMLItem alloc] init];
//    item.itemType = COXMLItemExternalEntity;
//    item.name = name;
//    item.systemID = systemID;
//    yield_val(item);
//}
// this gives the delegate an opportunity to resolve an external entity itself and reply with the resulting data.

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    CO_XML_CHECK_CANCEL()
    yield_val([COXMLItem makeErrorItem:parseError]);
}
// ...and this reports a fatal error to the delegate. The parser will stop parsing.

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError{
    CO_XML_CHECK_CANCEL()
    yield_val([COXMLItem makeErrorItem:validationError]);
}
// If validation is on, this will report a fatal validation error to the delegate. The parser will stop parsing.

@end


@implementation NSXMLParser (Coroutine)

- (COCoroutine*)co_parse{
    return co_sequence_onqueue([COKitCommon io_queue], ^{
        self.delegate = [COXMLParserDelegate sharedDelegate];
        [self parse];
    });

}

+ (COCoroutine*)co_parseContentsOfURL:(NSURL*)url{
    return [[[NSXMLParser alloc] initWithContentsOfURL:url] co_parse];
}

+ (COCoroutine*)co_parseData:(NSData*)data{
    return [[[NSXMLParser alloc] initWithData:data] co_parse];
}

+ (COCoroutine*)co_parseStream:(NSInputStream*)stream{
    return [[[NSXMLParser alloc] initWithStream:stream] co_parse];
}

@end
