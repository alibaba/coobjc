//
//  co_tuple.h
//  coobjc
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

@interface COTuple : NSObject<NSCopying, NSFastEnumeration>

// Creation
- (id)init; // Empty tuple
- (id)initWithArray:(NSArray*)arr;
- (id)initWithObjects:(id)objects, ...;

// Getting an object at an index
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (id)objectAtIndex:(int)idx;

@end

@interface COTuple1<Value1>: COTuple

@end

@interface COTuple2<Value1, Value2>: COTuple

@end

@interface COTuple3<Value1, Value2, Value3>: COTuple

@end

@interface COTuple4<Value1, Value2, Value3, Value4>: COTuple

@end

@interface COTuple5<Value1, Value2, Value3, Value4, Value5>: COTuple

@end

@interface COTuple6<Value1, Value2, Value3, Value4, Value5, Value6>: COTuple

@end

@interface COTuple7<Value1, Value2, Value3, Value4, Value5, Value6, Value7>: COTuple

@end

@interface COTuple8<Value1, Value2, Value3, Value4, Value5, Value6, Value7, Value8>: COTuple

@end



@interface COTupleUnpack : NSObject

@property(nonatomic, strong) COTuple *tuple;

- (instancetype)initWithPointers:(int)startIndex, ...;


@end

id co_tupleSentinel(void);

void** co_unpackSentinel(void);

#define co_tuple(...) [[COTuple alloc] initWithObjects:__VA_ARGS__, co_tupleSentinel()]
#define co_unpack(...) [[COTupleUnpack alloc] initWithPointers:0, __VA_ARGS__, co_unpackSentinel()].tuple
