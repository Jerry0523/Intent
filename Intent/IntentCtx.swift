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

open class IntentCtx {
    
    open var routerScheme = Bundle.main.bundleIdentifier ?? "" + ".router"
    
    open var handlerScheme = Bundle.main.bundleIdentifier ?? "" + ".func"
    
    open var actionScheme = Bundle.main.bundleIdentifier ?? "" + ".action"
    
    static open let `default` = IntentCtx()
    
    private var routerDict: [String: Router.Intention] = [:]
    
    private var handlerDict: [String: Handler.Intention] = [:]
    
    private let ioLock: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    private init() {
        
    }
    
    open func fetch(withURL: URL) throws -> (Any?, [String: Any]?)  {
        
        guard let urlComponent = URLComponents.init(url: withURL, resolvingAgainstBaseURL: false),
              let scheme = urlComponent.scheme,
              let host = urlComponent.host else {
            throw IntentError.invalidURL(urlString: withURL.absoluteString)
        }
        
        var obj: Any?
        
        switch scheme {
        case routerScheme:
            let routerObj: Router.Intention? = try fetch(forKey: host)
            obj = routerObj
        case handlerScheme:
            let handlerObj: Handler.Intention? = try fetch(forKey: host)
            obj = handlerObj
        case actionScheme:
            break
        default:
            throw IntentError.invalidScheme(scheme: scheme)
        }
        
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
    
    open func fetch<T>(forKey: String) throws -> T? {
        let _ = ioLock.wait(timeout: DispatchTime.distantFuture)
        defer {
            ioLock.signal()
        }
        
        if T.self == Router.Intention.self {
            return routerDict[forKey] as? T
        } else if T.self == Handler.Intention.self {
            return handlerDict[forKey] as? T
        }
        
        throw IntentError.invalidKey(key: forKey)
    }
    
    private func internal_register<T>(_ obj: T, forKey: String) {
        let _ = ioLock.wait(timeout: DispatchTime.distantFuture)
        defer {
            ioLock.signal()
        }
        if let routerObj = obj as? Router.Intention {
            routerDict[forKey] = routerObj
        } else if let handlerObj = obj as? Handler.Intention {
            handlerDict[forKey] = handlerObj
        }
    }
}

extension IntentCtx {
    
    open func register<T>(_ routerClass: T.Type, forKey: String) where T: UIViewController {
        internal_register(routerClass, forKey: forKey)
    }
    
    open func unregisterRouter(forKey: String) {
        let _ = ioLock.wait(timeout: DispatchTime.distantFuture)
        defer {
            ioLock.signal()
        }
        
        routerDict.removeValue(forKey: forKey)
    }
}

extension IntentCtx {
    
    open func register(_ handlerClosure: @escaping Handler.Intention, forKey: String) {
        internal_register(handlerClosure, forKey: forKey)
    }
    
    open func unregisterHandler(forKey: String) {
        let _ = ioLock.wait(timeout: DispatchTime.distantFuture)
        defer {
            ioLock.signal()
        }
        
        handlerDict.removeValue(forKey: forKey)
    }
}

extension NSObject {
    
    @objc var extra: [String: Any]? {
        get {
            return objc_getAssociatedObject(self, &NSObject.extraKey) as? [String: Any]
        }
    
        set {
            if let extraData = newValue {
                for (key, value) in extraData {
                    let setterKey = key.replacingCharacters(in: Range.init(NSRange.init(location: 0, length: 1), in: key)!, with: String.init(key[..<key.index(key.startIndex, offsetBy: 1)]).uppercased())
                    let setter = NSSelectorFromString("set" + setterKey + ":")
                    if responds(to: setter) {
                        setValue(value, forKey: key)
                    }
                }
            }
            objc_setAssociatedObject(self, &NSObject.extraKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private static var extraKey: Void?
}
