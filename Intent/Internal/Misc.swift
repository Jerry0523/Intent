//
// Misc.swift
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

extension NSObject {
    
    @objc var extra: [String: Any]? {
        get {
            return objc_getAssociatedObject(self, &NSObject.extraKey) as? [String: Any]
        }
        
        set {
            if let extraData = newValue {
                for (key, value) in extraData {
                    let setterKey = key.replacingCharacters(in: Range(NSRange(location: 0, length: 1), in: key)!, with: String(key[..<key.index(key.startIndex, offsetBy: 1)]).uppercased())
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

extension UIViewController {
    
    var isRemovingFromStack: Bool {
        get {
            return (objc_getAssociatedObject(self, &UIViewController.isRemovingFromStackKey) as? Bool) ?? false
        }
        
        set {
            objc_setAssociatedObject(self, &UIViewController.isRemovingFromStackKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private static var isRemovingFromStackKey: Void?
}

extension UIViewController {
    
    @objc func internal_dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension IntentCtx where T == ([String : Any]?) -> UIViewController {
    
    open func register<V>(_ class: V.Type, forKey: String) where V: UIViewController {
        let initVCClosure: Router.Intention = {_ in V() }
        register(initVCClosure, forKey: forKey)
    }
    
}

extension IntentError: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .invalidURL(let URLString):
            return "invalid URL \(String(describing: URLString))"
        case .invalidPath(let path):
            return "invalid path \(String(describing: path))"
        case .invalidScheme(let scheme):
            return "invalid scheme \(String(describing: scheme))"
        case .unknown(let msg):
            return msg
        }
    }
}

extension Router {
    
    /// The default back arrow image. Used for .fakePush config.
    public static var backIndicatorImage: UIImage = {
        if let image = UINavigationBar.appearance().backIndicatorImage {
            return image
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 13, height: 21), false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.move(to: CGPoint(x: 11.5, y: 1.5))
        ctx?.addLine(to: CGPoint(x: 2.5, y: 10.5))
        ctx?.addLine(to: CGPoint(x: 11.5, y: 19.5))
        ctx?.setStrokeColor((UINavigationBar.appearance().tintColor ?? UIColor(red: 21.0 / 255.0, green: 126.0 / 255.0, blue: 251.0 / 255.0, alpha: 1.0)).cgColor)
        ctx?.setLineWidth(3.0)
        ctx?.setLineCap(.round)
        ctx?.setLineJoin(CGLineJoin.round)
        ctx?.strokePath()
        
        return UIGraphicsGetImageFromCurrentImageContext()!
    }()
}
