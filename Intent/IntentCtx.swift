//
// IntentCtx.swift
//
// Copyright (c) 2015 Jerry Wong
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

open class IntentCtx <T> {
    
    open var scheme: String
    
    public init(scheme: String) {
        self.scheme = scheme
    }
    
    open func unregister(forKey: String) -> T? {
        var ret: T?
        ioQueue.sync(flags: .barrier, execute: {
            ret = dataMap.removeValue(forKey: forKey)
        })
        return ret
    }
    
    open func register(_ obj: T, forKey: String) {
        ioQueue.async(flags: .barrier) {
            self.dataMap[forKey] = obj
        }
    }
    
    open func regsiter(_ objs: [String: T]) {
        ioQueue.async(flags: .barrier) {
            self.dataMap.merge(objs) { (_, new) in new }
        }
    }
    
    open func fetch(forPath: String) throws -> T {
        var ret: T?
        ioQueue.sync {
            ret = dataMap[forPath]
        }
        guard ret != nil else {
            throw IntentError.invalidPath(path: forPath)
        }
        return ret!
    }
    
    open func fetch(withURL: URL) throws -> (T, [String: Any]?, String) {
        guard let urlComponent = URLComponents(url: withURL, resolvingAgainstBaseURL: false),
            let scheme = urlComponent.scheme,
            let host = urlComponent.host else {
                throw IntentError.invalidURL(URLString: withURL.absoluteString)
        }
        
        guard scheme == self.scheme else {
            throw IntentError.invalidScheme(scheme: scheme)
        }
        
        let identifier = host + urlComponent.path
        let obj = try fetch(forPath: identifier)
        
        var param: [String: Any]?
        
        if urlComponent.queryItems != nil {
            var mParam:[String: Any] = [:]
            for item in urlComponent.queryItems! {
                mParam[item.name] = item.value
            }
            if mParam.count > 0 {
                param = mParam
            }
        }

        return (obj, param, scheme + "://" + identifier)
    }
    
    private var dataMap: [String: T] = [:]
    
    private let ioQueue = DispatchQueue(label: "com.jerry.intent", qos: .default, attributes: .concurrent)
    
}

