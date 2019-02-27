//
//  UIImageView+WebCache.m
//  coobjcBaseExample
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

#import "UIImageView+WebCache.h"
#import "DataService.h"
#import <objc/runtime.h>

@implementation UIImageView (WebCache)

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setImageWithURL:(NSString*)url CO_ASYNC{
    
    objc_setAssociatedObject(self, @selector(setImageWithURL:), url, OBJC_ASSOCIATION_RETAIN);
    
    co_launch(^{
        
        UIImage *image = [[DataService sharedInstance] imageWithURL:url];
        if ([objc_getAssociatedObject(self, @selector(setImageWithURL:)) isEqualToString:url]) {
            self.image = image;
        }
    });
}

@end
