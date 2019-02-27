//
//  DataService.swift
//  coSwiftDemo
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
import coswift
import CoreLocation

public class RequestResult {
    var data: Data?
    var response: URLResponse?
    
    init(data: Data?, response: URLResponse?) {
        self.data = data
        self.response = response
    }
}

func co_fetchSomethingAsynchronous() -> Promise<Data?> {
    
    let promise =  Promise<Data?>(constructor: { (fulfill, reject) in
        
        let data: Data? = nil
        let error: Error? = nil
        
        // fetch the data
        
        if error != nil {
            reject(error!)
        } else {
            fulfill(data)
        }
    })
    
    promise.onCancel { (promiseObj) in
        
    }
    
    return promise
}

let someQueue = DispatchQueue(label: "aa")

func co_fetchSomething() -> Chan<String> {
    
    let chan = Chan<String>()
    
    someQueue.async {
        // fetch operations
        chan.send_nonblock(val: "the result")
    }
    return chan
}

func test() {
    
    co_launch {
        let resultStr = try await(channel: co_fetchSomething())
        print("result: \(resultStr)")
    }
    
    co_launch {
        let result = try await(promise: co_fetchSomethingAsynchronous())
        switch result {
        case .fulfilled(let data):
            print("data: \(String(describing: data))")
            break
        case .rejected(let error):
            print("error: \(error)")
        }
    }
}

extension URLSession {
    
    public func dataTask(with url: URL) -> Promise<(Data?, URLResponse?)> {
        
        let promise = Promise<(Data?, URLResponse?)>()
        
        let task = self.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                promise.reject(error: error!)
            } else {
                promise.fulfill(value: (data, response))
            }
        }
        
        promise.onCancel { [weak task] (pro) in
            task?.cancel()
        }
        task.resume()
        return promise
    }
}


public class DataService {
    
    fileprivate let urlPath = "http://www.baidu.com"

    public static let shared = DataService();
    

    public func fetchWeatherData() throws -> String  {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let location = CLLocation(latitude: 0, longitude: 0)
        guard var components = URLComponents(string:urlPath) else {
            throw NSError(domain: "DataService", code: -1, userInfo: [NSLocalizedDescriptionKey : "Invalid URL."])
            
        }
        
        // get appId from Info.plist
        
        let latitude = String(location.coordinate.latitude)
        let longitude = String(location.coordinate.longitude)
        
        components.queryItems = [URLQueryItem(name:"lat", value:latitude),
                                 URLQueryItem(name:"lon", value:longitude),
                                 URLQueryItem(name:"appid", value:"796b6557f59a77fa02db756a30803b95")]
        
        let url = components.url
        
        var ret = ""
        
        
        let result = try await (closure: {
            session.dataTask(with: url!)
        })
        
        switch result {
        case .fulfilled(let (data, response)):
            
            if let data1 = data {
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("response: \(httpResponse)")
                }
                if let str = String(data: data1, encoding: String.Encoding.utf8) {
                    ret = str
                    print("responseString: \(str)")
                }
            }
            
        case .rejected(let error):
            
            print("error: \(error)")
        }
        
        return ret
    }
    
    
    
}
