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

open class IntentCtx <T: Intent> {
    
    open var scheme: String
    
    public init(scheme: String) {
        self.scheme = scheme
    }
    
    open func unregister(forKey: String) -> T.Intention? {
        let _ = ioLock.wait(timeout: DispatchTime.distantFuture)
        defer {
            ioLock.signal()
        }
        return dataMap.removeValue(forKey: forKey)
    }
    
    open func register(_ obj: T.Intention, forKey: String) {
        let _ = ioLock.wait(timeout: DispatchTime.distantFuture)
        defer {
            ioLock.signal()
        }
        dataMap[forKey] = obj
    }
    
    open func regsiter(_ objs: [String: T.Intention]) {
        let _ = ioLock.wait(timeout: DispatchTime.distantFuture)
        defer {
            ioLock.signal()
        }
        dataMap.merge(objs) { (_, new) in new }
    }
    
    open func fetch(forKey: String) throws -> T.Intention {
        let _ = ioLock.wait(timeout: DispatchTime.distantFuture)
        defer {
            ioLock.signal()
        }
        guard let obj = dataMap[forKey] else {
            throw IntentError.invalidKey(key: forKey)
        }
        return obj
    }
    
    open func fetch(withURL: URL) throws -> (T.Intention, [String: Any]?) {
        guard let urlComponent = URLComponents(url: withURL, resolvingAgainstBaseURL: false),
            let scheme = urlComponent.scheme,
            let host = urlComponent.host else {
                throw IntentError.invalidURL(urlString: withURL.absoluteString)
        }
        
        guard scheme == self.scheme else {
            throw IntentError.invalidScheme(scheme: scheme)
        }
        
        let obj = try fetch(forKey: host)
        
        var param:[String: Any]?
        
        if urlComponent.queryItems != nil {
            var mParam:[String: Any] = [:]
            for item in urlComponent.queryItems! {
                mParam[item.name] = item.value
            }
            if mParam.count > 0 {
                param = mParam
            }
        }

        return (obj, param)
    }
    
    private var dataMap: [String: T.Intention] = [:]
    
    private let ioLock: DispatchSemaphore = DispatchSemaphore(value: 1)
    
}

