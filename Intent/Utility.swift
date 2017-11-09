//
// Utility.swift
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

public protocol GetTopViewController {
    
    var topViewController: UIViewController? { get }
    
}

public protocol GetTopWindow {
    
    var topWindow: UIWindow { get }
    
}

extension UINavigationController : GetTopViewController {
    
}

extension UITabBarController : GetTopViewController {
    
    public var topViewController: UIViewController? {
        return self.selectedViewController
    }
    
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
    
    func switchTo(index: Int) -> Bool {
        let viewControllers = self.childViewControllers
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
    
    func switchTo<T>(class theClass: T.Type) -> Bool where T: UIViewController {
        let viewControllers = self.childViewControllers
        for i in 0..<viewControllers.count {
            let aVC = viewControllers[i]
            if aVC.classForCoder == theClass && self.switchTo(index: i) {
                return true
            } else if let tbc = aVC as? UITabBarController {
                let hasFound = tbc.switchTo(class: theClass)
                if hasFound && self.switchTo(index: i) {
                    return true
                }
            } else if let nc = aVC as? UINavigationController {
                let hasFound = nc.switchTo(class: theClass)
                if hasFound && self.switchTo(index: i) {
                    return true
                }
            }
        }
        return false
    }
    
    @objc func internal_dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private static var isRemovingFromStackKey: Void?
}

class ModalVC: UIViewController {
    
    func add(contentVC: UIViewController) {
        for childVC in self.childViewControllers {
            if (childVC.isViewLoaded && childVC.view.superview == self.view) {
                childVC.view.removeFromSuperview()
            }
            childVC.removeFromParentViewController()
        }
        self.addChildViewController(contentVC)
        
        let contentView = contentVC.view!
        self.view.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        constraints.append(NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: contentView.superview, attribute: .left, multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: contentView.superview, attribute: .right, multiplier: 1.0, constant: 0))
        if self.modalOption.contains(.contentBottom) {
            constraints.append(NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: contentView.superview, attribute: .bottom, multiplier: 1.0, constant: 0))
        } else if self.modalOption.contains(.contentTop) {
            constraints.append(NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: contentView.superview, attribute: .top, multiplier: 1.0, constant: 0))
        } else {//centered
            constraints.append(NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: contentView.superview, attribute: .centerY, multiplier: 1.0, constant: 0))
        }
        NSLayoutConstraint.activate(constraints)
        contentView.layoutIfNeeded()
    }
    
    func present() {
        guard let childVC = self.childViewControllers.first else {
            return
        }
        
        let bottomRootVC = Router.topViewController
        bottomRootVC?.viewWillDisappear(true)
        
        let contentView = childVC.view
        
        if (self.modalOption.contains(.cancelAnimation)) {
            dimBlurView.effect = UIBlurEffect.init(style: .dark)
            dimView.backgroundColor = UIColor.init(white: 0, alpha: 0.6)
        } else {
            self.applyTransformForAnimation()
            dimBlurView.effect = nil
            dimView.backgroundColor = UIColor.clear
            
            UIView.animate(withDuration: 0.3, animations: {
                self.dimBlurView.effect = UIBlurEffect.init(style: .dark)
                self.dimView.backgroundColor = UIColor.init(white: 0, alpha: 0.6)
                contentView?.transform = CGAffineTransform.identity
            })
        }
        
        let targetWindow = Router.topWindow
        targetWindow.rootViewController = self
        targetWindow.isHidden = false
        
        bottomRootVC?.viewDidDisappear(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.modalOption.contains(.dimBlur)) {
            self.view.addSubview(self.dimBlurView)
        } else {
            self.view.addSubview(self.dimView)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        let bottomRootVC = Router.topViewController
        bottomRootVC?.viewWillAppear(flag)
        
        let completionBlock = {(finished: Bool) -> Void in
            let targetWindow = Router.topWindow
            targetWindow.rootViewController = UIViewController.init()
            targetWindow.isHidden = true
            bottomRootVC?.viewDidAppear(flag)
            if (completion != nil) {
                completion!()
            }
        }

        if (flag) {
            UIView.animate(withDuration: 0.3, animations: {
                self.dimBlurView.effect = nil
                self.dimView.backgroundColor = UIColor.clear
                self.applyTransformForAnimation()
            }, completion: completionBlock)
            
        } else {
            completionBlock(true)
        }
    }
    
    private func applyTransformForAnimation() {
        guard let childVC = self.childViewControllers.first else {
            return
        }
        
        let contentView = childVC.view!
        if self.modalOption.contains(.contentBottom) {
            contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.size.height)
        } else if self.modalOption.contains(.contentTop) {
            contentView.transform = CGAffineTransform(translationX: 0, y: -contentView.bounds.size.height)
        } else {//centered
            contentView.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        }
    }
    
    @objc private func dismissAnimated() {
        self.dismiss(animated: true, completion: nil)
    }
    
    var modalOption: ModalOption = []
    
    private lazy var dimView: UIView = {
        let _dimView = UIView.init(frame: self.view.bounds)
        _dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(dismissAnimated))
        _dimView.addGestureRecognizer(tapGes)
        return _dimView
    }()
    
    private lazy var dimBlurView: UIVisualEffectView = {
        let _effectView = UIVisualEffectView.init(frame: self.view.bounds)
        _effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(dismissAnimated))
        _effectView.addGestureRecognizer(tapGes)
        return _effectView
    }()

}

class NCProxyDelegate : NSObject {
    
    weak var target: UINavigationControllerDelegate?
    weak var currentTransition: Transition?
    
    class func addProxy(forNavigationController nc: UINavigationController) {
        if (nc.delegate?.isKind(of: self.classForCoder()) ?? false) {
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
        self.currentTransition?.handle(interactivePanGesture: recognizer, axis: .horizontal, threshold: 0.5, beginAction: {
            let nc: UINavigationController = objc_getAssociatedObject(recognizer, &NCProxyDelegate.instanceNCKey) as! UINavigationController
            nc.popViewController(animated: true)
        })
    }
    
    open override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return self.target
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        if aSelector == #selector(navigationController(_:didShow:animated:)) ||
            aSelector == #selector(navigationController(_:animationControllerFor:from:to:)) ||
            aSelector == #selector(navigationController(_:interactionControllerFor:)) {
            return true
        }
        return self.target?.responds(to:aSelector) ?? false
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
        self.currentTransition = viewController.pushTransition
        self.target?.navigationController?(navigationController, didShow: viewController, animated: animated)
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitionOwner = (operation == .push ? toVC : fromVC)
        let transition = transitionOwner.pushTransition
        if transition != nil {
            return transition
        }
        return self.target?.navigationController?(navigationController, animationControllerFor:operation, from:fromVC, to:toVC)
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let transition = animationController as? Transition {
             return transition.interactiveController
        }
        return self.currentTransition?.interactiveController
    }
    
}

class ScreenEdgeDetectorViewController : UIViewController, UIGestureRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChildViewIfNeeded()
        
        let gesture = UIScreenEdgePanGestureRecognizer.init(target: self, action: #selector(handleScreenEdgeGesture(_:)))
        gesture.edges = UIRectEdge.left
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
    }
    
    override func addChildViewController(_ childController: UIViewController) {
        if self.isViewLoaded {
            for subView in self.view.subviews {
                subView.removeFromSuperview()
            }
        }
        
        for subVC in self.childViewControllers {
            subVC.removeFromParentViewController()
        }
        super.addChildViewController(childController)
        self.addChildViewIfNeeded()
    }
    
    private func addChildViewIfNeeded() {
        if !self.isViewLoaded {
            return
        }
        
        if let childController = self.childViewControllers.first {
            childController.view.frame = self.view.bounds
            childController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(childController.view)
            childController.didMove(toParentViewController: self)
        }
    }
    
    @objc private func handleScreenEdgeGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        self.presentTransition?.handle(interactivePanGesture: sender, axis: .horizontal, threshold: 0.5, beginAction: {
            self.dismiss(animated: true, completion: nil)
        })
    }
}

extension ScreenEdgeDetectorViewController : GetTopViewController {
    
    var topViewController: UIViewController? {
        return self.childViewControllers.last
    }
    
}
