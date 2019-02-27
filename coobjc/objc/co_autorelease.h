//
//  co_autorelease.h
//  coobjc
//
//  Copyright © 2018 Alibaba Group Holding Limited All rights reserved.
//  Copyright (c) 1999-2003 Apple Computer, Inc. All Rights Reserved.
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


#ifdef __cplusplus
extern "C" {
#endif //__cplusplus
    
    /**
    If you want to use @autorelease{} in a coroutine, and
     suspend in the scope. Enable this.
     
     @discussion Since a coroutine's calling stack may suspend.
     If you suspend in the @autorelease{} scope, autorelease pool
     may drop by the current runloop, then cause a crash.
     
     So we hook `autoreleasePoolPush` `autoreleasePoolPop`
     `autorelease` try to fix this. If you want suspend in a
     @autorelease{} scope, you may call `co_autoreleaseInit`.
     */
    extern BOOL co_enableAutorelease;
    extern void co_autoreleaseInit(void);
    
    extern void * co_autoreleasePoolPush(void);
    extern void co_autoreleasePoolPop(void *ctxt);
    
    extern void co_autoreleasePoolPrint();
    
    extern id co_autoreleaseObj(id obj);
    
    extern void co_autoreleasePoolDealloc(void *p);
    
#ifdef __cplusplus
}
#endif //__cplusplus

