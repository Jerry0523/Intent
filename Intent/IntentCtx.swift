//
//  IntentCtx.swift
//  JWKit
//
//  Created by Jerry on 2017/10/27.
//  Copyright © 2017年 com.jerry. All rights reserved.
//

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
        case self.routerScheme:
            let routerObj: Router.Intention? = try self.fetch(forKey: host)
            obj = routerObj
        case self.handlerScheme:
            let handlerObj: Handler.Intention? = try self.fetch(forKey: host)
            obj = handlerObj
        case self.actionScheme:
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
            return self.routerDict[forKey] as? T
        } else if T.self == Handler.Intention.self {
            return self.handlerDict[forKey] as? T
        }
        
        throw IntentError.invalidKey(key: forKey)
    }
    
    private func internal_register<T>(_ obj: T, forKey: String) {
        let _ = ioLock.wait(timeout: DispatchTime.distantFuture)
        defer {
            ioLock.signal()
        }
        if let routerObj = obj as? Router.Intention {
            self.routerDict[forKey] = routerObj
        } else if let handlerObj = obj as? Handler.Intention {
            self.handlerDict[forKey] = handlerObj
        }
    }
}

extension IntentCtx {
    open func register<T>(_ routerClass: T.Type, forKey: String) where T: UIViewController {
        self.internal_register(routerClass, forKey: forKey)
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
        self.internal_register(handlerClosure, forKey: forKey)
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
                    if self.responds(to: setter) {
                        self.setValue(value, forKey: key)
                    }
                }
            }
            objc_setAssociatedObject(self, &NSObject.extraKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private static var extraKey: Void?
}
