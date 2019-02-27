//
//  COActorChan.m
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

#import "COActorChan.h"

@interface COActorChan ()
{
    unsigned long enum_state;
}

@property(nonatomic, strong) COActorMessage *lastMessage;

@end

@implementation COActorChan

- (COActorMessage *)next {
    if (self.isCancelled) {
        return nil;
    }
    id obj = [self receive];
    if (![obj isKindOfClass:[COActorMessage class]]) {
        self.lastMessage = nil;
        return nil;
    }
    self.lastMessage = obj;
    return obj;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained _Nullable [_Nonnull])buffer count:(NSUInteger)len {
    
    if (state->state == 0) {
        state->mutationsPtr = &enum_state;
        state->state = enum_state;
    }
    
    NSUInteger count = 0;
    state->itemsPtr = buffer;
    COActorMessage *message = [self next];
    if (message) {
        buffer[0] = message;
        count++;
    }
    
    return count;
}

@end
