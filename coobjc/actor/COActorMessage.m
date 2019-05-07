//
//  COActorMessage.m
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

#import "COActorMessage.h"

extern NSError *co_getError(void);

@interface COActorMessage ()

@property(nonatomic, strong) COActorCompletable *completableObj;

@end

@implementation COActorMessage

- (instancetype)initWithType:(id)type
                    completable:(COActorCompletable *)completable {
    self = [super init];
    if (self) {
        _type = type;
        _completableObj = completable;
    }
    return self;
}

- (void (^)(id))complete {
    COActorCompletable *completable = _completableObj;
    return ^(id val){
        if (completable) {
            if (val) {
                [completable fulfill:val];
            }
            else{
                NSError *error = co_getError();
                if (error) {
                    [completable reject:error];
                }
                else{
                    [completable fulfill:val];
                }
            }
        }
    };
}

- (NSString*)stringType {
    if ([_type isKindOfClass:[NSString class]]) {
        return _type;
    }
    return [_type stringValue];
}

- (int)intType {
    return [_type intValue];
}

- (NSUInteger)uintType {
    return [_type unsignedIntegerValue];
}

- (double)doubleType {
    return [_type doubleValue];
}

- (float)floatType {
    return [_type floatValue];
}

- (NSDictionary*)dictType {
    if ([_type isKindOfClass:[NSMutableDictionary class]]) {
        return [_type copy];
    }
    else if([_type isKindOfClass:[NSDictionary class]]){
        return _type;
    }
    return nil;
}

- (NSArray*)arrayType {
    if ([_type isKindOfClass:[NSMutableArray class]]) {
        return [_type copy];
    }
    else if([_type isKindOfClass:[NSArray class]]){
        return _type;
    }
    return nil;
}
@end
