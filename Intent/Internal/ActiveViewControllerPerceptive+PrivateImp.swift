//
// ActiveViewControllerPerceptive+PrivateImp.swift
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

extension Route {
    
    /// The active topViewController for the current key window.
    public static var topViewController: UIViewController? {
        get {
            let keyWindow = UIApplication.shared.keyWindow
            var topVC = keyWindow?.rootViewController
            while topVC?.presentedViewController != nil {
                topVC = topVC?.presentedViewController
            }
            
            while let topAbility = topVC as? ActiveViewControllerPerceptive {
                topVC = topAbility.activeViewController
            }
            
            return topVC
        }
    }
    
    /// The top window for modal ViewControllers.
    public static var topWindow: UIWindow {
        get {
            let appDelegate = UIApplication.shared.delegate as? TopWindowPerceptive
            assert(appDelegate != nil, "AppDelegate should confirm to Protocol TopWindowPerceptive")
            return appDelegate!.topWindow
        }
    }
}

extension _ScreenEdgeDetectorViewController : ActiveViewControllerPerceptive {
    
    var activeViewController: UIViewController? {
        return children.last
    }
}
