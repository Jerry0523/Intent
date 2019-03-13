//
// IndexSwitchable.swift
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

protocol IndexSwitchable {
    
    func switchTo(_ index: UInt) -> Bool
    
}

extension UIViewController {
    
    fileprivate func withChildViewController(at index: UInt) -> UIViewController? {
        let viewControllers = children
        if index < viewControllers.count  {
            return viewControllers[Int(index)]
        }
        return nil
    }
    
}

extension UITabBarController: IndexSwitchable {
    
    func switchTo(_ index: UInt) -> Bool {
        if let selectedVC = withChildViewController(at: index) {
            selectedVC.viewWillAppear(true)
            selectedIndex = Int(index)
            selectedVC.viewDidAppear(true)
            return true
        }
        return false
    }
    
}

extension UINavigationController: IndexSwitchable {
    
    func switchTo(_ index: UInt) -> Bool {
        if let selectedVC = withChildViewController(at: index) {
            selectedVC.viewWillAppear(true)
            popToViewController(selectedVC, animated: true)
            selectedVC.viewDidAppear(true)
            return true
        }
        return false
    }
    
}

extension UIViewController {
    
    func switchTo<T>(class theClass: T.Type, isReversed: Bool) -> Bool where T: UIViewController {
        let viewControllers = children
        let bounds = 0..<viewControllers.count
        let indexes = isReversed ? Array(bounds.reversed()) : Array(bounds)
        let selfIndexSwitchable = self as? IndexSwitchable
        for i in indexes {
            let aVC = viewControllers[i]
            if let selfIndexSwitchable = selfIndexSwitchable,
                aVC.classForCoder == theClass,
                selfIndexSwitchable.switchTo(UInt(i)) {
                return true
            } else if aVC is IndexSwitchable {
                let hasFound = aVC.switchTo(class: theClass, isReversed: isReversed)
                if hasFound {
                    if let selfIndexSwitchable = selfIndexSwitchable {
                        _ = selfIndexSwitchable.switchTo(UInt(i))
                    }
                    return true
                }
            }
        }
        return false
    }
}
