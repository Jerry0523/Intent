//
// GetActiveViewController.swift
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

/// A type that determins the active ViewController.
/// UINavigationController and UITabBarController have already confirmed to it.
public protocol GetActiveViewController {
    
    var activeViewController: UIViewController? { get }
    
}

/// A type that determins the modal window.
/// Typically, AppDelegate should comfirm to it.
public protocol GetTopWindow {
    
    var topWindow: UIWindow { get }
    
}

extension Router {
    
    /// The active topViewController for the current key window.
    public static var topViewController: UIViewController? {
        get {
            let keyWindow = UIApplication.shared.keyWindow
            var topVC = keyWindow?.rootViewController
            while topVC?.presentedViewController != nil {
                topVC = topVC?.presentedViewController
            }
            
            while let topAbility = topVC as? GetActiveViewController {
                topVC = topAbility.activeViewController
            }
            
            return topVC
        }
    }
    
    /// The top window for modal ViewControllers.
    public static var topWindow: UIWindow {
        get {
            let appDelegate = UIApplication.shared.delegate as? GetTopWindow
            assert(appDelegate != nil, "AppDelegate should confirm to Protocol GetTopWindow")
            return appDelegate!.topWindow
        }
    }
}

extension UINavigationController : GetActiveViewController {
    
    public var activeViewController: UIViewController? {
        return topViewController
    }
    
}

extension UITabBarController : GetActiveViewController {
    
    public var activeViewController: UIViewController? {
        return selectedViewController
    }
}

extension _ScreenEdgeDetectorViewController : GetActiveViewController {
    
    var activeViewController: UIViewController? {
        return childViewControllers.last
    }
}
