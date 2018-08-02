//
// UIViewController+Switch.swift
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

extension UIViewController {
    
    func switchTo(index: Int) -> Bool {
        let viewControllers = childViewControllers
        if index >= 0 && index < viewControllers.count {
            let selectedVC = viewControllers[index]
            selectedVC.viewWillAppear(true)
            if let tbc = self as? UITabBarController {
                tbc.selectedIndex = index
            } else if let nc = self as? UINavigationController {
                nc.popToViewController(selectedVC, animated: true)
            }
            selectedVC.viewDidAppear(true)
            return true
        } else {
            return false
        }
    }
    
    func switchTo<T>(class theClass: T.Type, isReversed: Bool) -> Bool where T: UIViewController {
        let viewControllers = childViewControllers
        let bounds = 0..<viewControllers.count
        let indexes = isReversed ? Array(bounds.reversed()) : Array(bounds)
        for i in indexes {
            let aVC = viewControllers[i]
            if aVC.classForCoder == theClass && switchTo(index: i) {
                return true
            } else if let tbc = aVC as? UITabBarController {
                let hasFound = tbc.switchTo(class: theClass, isReversed: isReversed)
                if hasFound && switchTo(index: i) {
                    return true
                }
            } else if let nc = aVC as? UINavigationController {
                let hasFound = nc.switchTo(class: theClass, isReversed: isReversed)
                if hasFound && switchTo(index: i) {
                    return true
                }
            }
        }
        return false
    }
}
