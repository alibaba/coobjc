//
//  co_queuedebugging_support.h
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
//
//  **
//  When set a breakpoint in coroutine's code, we got lldb crash.
//  This is the fix of queue debugging issues.

#ifndef co_queuedebugging_support_h
#define co_queuedebugging_support_h

/**
 Since `backtrace` method could not work in coroutine, we provide the backtrace method in coroutine.
 */
int co_backtrace(void** buffer, int size);

/**
 Rebind the system `backtrace` method, make it get the coroutine's backtrace.
 This method can fix the lldb crash problem.
 */
void co_rebind_backtrace(void);

#endif /* co_queuedebugging_support_h */
