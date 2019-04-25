//
//  Errors.swift
//  coswift
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

import Foundation

public enum COError: String, LocalizedError {
    
    
    case promiseCancelled = "Promise was cancelled"
    case coroutineCancelled = "Coroutine was cancelled"
    case invalidCoroutine = "The operation requires execute in coroutine"
    case generatorCancelled = "The generator is cancelled"
    case generatorClosed = "The generator is closed"
    case notGenerator = "The current coroutine is not a generator"
    case chanReceiveFailUnknown = "Channel receive fails unknown"

    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        get {
            return self.rawValue
        }
    }
}

