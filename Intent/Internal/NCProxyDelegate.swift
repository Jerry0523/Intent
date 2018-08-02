//
// NCProxyDelegate.swift
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

class NCProxyDelegate : NSObject {
    
    weak var target: UINavigationControllerDelegate?
    
    weak var currentTransition: Transition?
    
    class func addProxy(forNavigationController nc: UINavigationController) {
        if (nc.delegate?.isKind(of: classForCoder()) ?? false) {
            return
        }
        
        let proxyDelegate = NCProxyDelegate()
        proxyDelegate.target = nc.delegate
        nc.delegate = proxyDelegate
        
        objc_setAssociatedObject(nc, &NCProxyDelegate.proxyDelegateKey, proxyDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        if nc.interactivePopGestureRecognizer != nil {
            objc_setAssociatedObject(nc.interactivePopGestureRecognizer!, &NCProxyDelegate.instanceNCKey, nc, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    @objc private func handleInteractivePopGesture(recognizer: UIPanGestureRecognizer) {
        currentTransition?.handle(recognizer, gestureDidBegin: {
            let nc: UINavigationController = objc_getAssociatedObject(recognizer, &NCProxyDelegate.instanceNCKey) as! UINavigationController
            nc.popViewController(animated: true)
        })
    }
    
    open override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if target?.responds(to: aSelector) ?? false {
            return target
        }
        return super.forwardingTarget(for: aSelector)
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        return (target?.responds(to:aSelector) ?? false) || super.responds(to: aSelector)
    }
    
    private static var instanceNCKey: Void?
    
    private static var proxyDelegateKey: Void?
    
    private static var oldInteractivePopTargetKey: Void?
}

extension NCProxyDelegate : UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController.pushTransition != nil {
            if objc_getAssociatedObject(navigationController, &NCProxyDelegate.oldInteractivePopTargetKey) == nil {
                let allTargets = navigationController.interactivePopGestureRecognizer?.value(forKey: "_targets") as? NSMutableArray
                objc_setAssociatedObject(navigationController, &NCProxyDelegate.oldInteractivePopTargetKey, allTargets?.firstObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            navigationController.interactivePopGestureRecognizer?.removeTarget(nil, action: nil)
            navigationController.interactivePopGestureRecognizer?.addTarget(self, action: #selector(handleInteractivePopGesture(recognizer:)))
        } else {
            navigationController.interactivePopGestureRecognizer?.removeTarget(nil, action: nil)
            let oldInteractivePopTarget = objc_getAssociatedObject(navigationController, &NCProxyDelegate.oldInteractivePopTargetKey)
            if oldInteractivePopTarget != nil {
                let allTargets = navigationController.interactivePopGestureRecognizer?.value(forKey: "_targets") as? NSMutableArray
                allTargets?.add(oldInteractivePopTarget!)
            }
        }
        currentTransition = viewController.pushTransition
        target?.navigationController?(navigationController, didShow: viewController, animated: animated)
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitionOwner = (operation == .push ? toVC : fromVC)
        let transition = transitionOwner.pushTransition
        if transition != nil {
            return transition
        }
        return target?.navigationController?(navigationController, animationControllerFor:operation, from:fromVC, to:toVC)
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let transition = animationController as? Transition {
            return transition.interactiveController
        }
        return currentTransition?.interactiveController
    }
    
}
