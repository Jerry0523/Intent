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
    
    @objc func internal_dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    private static var isRemovingFromStackKey: Void?
}

class ModalVC: UIViewController {
    
    private func addContentViewIfNeeded() {
        
        guard isViewLoaded, let contentVC = childViewControllers.last else {
            return
        }
        
        let contentView = contentVC.view!
        view.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        constraints.append(NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: contentView.superview, attribute: .left, multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: contentView.superview, attribute: .right, multiplier: 1.0, constant: 0))
        if modalOption.contains(.contentBottom) {
            constraints.append(NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: contentView.superview, attribute: .bottom, multiplier: 1.0, constant: 0))
        } else if modalOption.contains(.contentTop) {
            constraints.append(NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: contentView.superview, attribute: .top, multiplier: 1.0, constant: 0))
        } else {//centered
            constraints.append(NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: contentView.superview, attribute: .centerY, multiplier: 1.0, constant: 0))
        }
        NSLayoutConstraint.activate(constraints)
        contentView.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (modalOption.contains(.dimBlur)) {
            view.addSubview(dimBlurView)
        } else {
            view.addSubview(dimView)
        }
        addContentViewIfNeeded()
    }
    
    override func addChildViewController(_ childController: UIViewController) {
        for childVC in childViewControllers {
            if (isViewLoaded && childVC.isViewLoaded && childVC.view.superview == view) {
                childVC.view.removeFromSuperview()
            }
            childVC.removeFromParentViewController()
        }
        super.addChildViewController(childController)
        addContentViewIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func present() {
        guard let childVC = childViewControllers.last else {
            return
        }
        
        let bottomRootVC = Router.topViewController
        bottomRootVC?.viewWillDisappear(true)
        
        let contentView = childVC.view
        
        if (modalOption.contains(.cancelAnimation)) {
            dimBlurView.effect = UIBlurEffect(style: .dark)
            dimView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        } else {
            transform(forContentView: childVC.view)
            dimBlurView.effect = nil
            dimView.backgroundColor = UIColor.clear
            
            UIView.animate(withDuration: 0.3, animations: {
                self.dimBlurView.effect = UIBlurEffect(style: .dark)
                self.dimView.backgroundColor = UIColor(white: 0, alpha: 0.6)
                contentView?.transform = CGAffineTransform.identity
            })
        }
        
        let targetWindow = Router.topWindow
        targetWindow.rootViewController = self
        targetWindow.isHidden = false
        
        bottomRootVC?.viewDidDisappear(true)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        guard let childVC = childViewControllers.last else {
            return
        }
        
        let bottomRootVC = Router.topViewController
        bottomRootVC?.viewWillAppear(flag)
        
        let completionBlock = {(finished: Bool) -> Void in
            let targetWindow = Router.topWindow
            targetWindow.rootViewController = UIViewController()
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
                self.transform(forContentView: childVC.view)
            }, completion: completionBlock)
            
        } else {
            completionBlock(true)
        }
    }
    
    private func transform(forContentView contentView: UIView) {
        if modalOption.contains(.contentBottom) {
            contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.size.height)
        } else if modalOption.contains(.contentTop) {
            contentView.transform = CGAffineTransform(translationX: 0, y: -contentView.bounds.size.height)
        } else {//centered
            contentView.transform = CGAffineTransform(scaleX: 0, y: 0)
        }
    }
    
    @objc private func dismissAnimated() {
        dismiss(animated: true, completion: nil)
    }
    
    var modalOption: Router.RouterConfig.ModalOption = []
    
    private lazy var dimView: UIView = {
        let _dimView = UIView(frame: view.bounds)
        _dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(dismissAnimated))
        _dimView.addGestureRecognizer(tapGes)
        return _dimView
    }()
    
    private lazy var dimBlurView: UIVisualEffectView = {
        let _effectView = UIVisualEffectView(frame: view.bounds)
        _effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(dismissAnimated))
        _effectView.addGestureRecognizer(tapGes)
        return _effectView
    }()

}

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
        currentTransition?.handle(interactivePanGesture: recognizer, beginAction: {
            let nc: UINavigationController = objc_getAssociatedObject(recognizer, &NCProxyDelegate.instanceNCKey) as! UINavigationController
            nc.popViewController(animated: true)
        })
    }
    
    open override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        if aSelector == #selector(navigationController(_:didShow:animated:)) ||
            aSelector == #selector(navigationController(_:animationControllerFor:from:to:)) ||
            aSelector == #selector(navigationController(_:interactionControllerFor:)) {
            return true
        }
        return target?.responds(to:aSelector) ?? false
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

class ScreenEdgeDetectorViewController : UIViewController, UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViewIfNeeded()
        
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleScreenEdgeGesture(_:)))
        gesture.edges = UIRectEdge.left
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    override func addChildViewController(_ childController: UIViewController) {
        if isViewLoaded {
            for subView in view.subviews {
                subView.removeFromSuperview()
            }
        }
        
        for subVC in childViewControllers {
            subVC.removeFromParentViewController()
        }
        super.addChildViewController(childController)
        addChildViewIfNeeded()
    }
    
    private func addChildViewIfNeeded() {
        if !isViewLoaded {
            return
        }
        
        if let childController = childViewControllers.first {
            childController.view.frame = view.bounds
            childController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(childController.view)
            childController.didMove(toParentViewController: self)
        }
    }
    
    @objc private func handleScreenEdgeGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        presentTransition?.handle(interactivePanGesture: sender, beginAction: {
            dismiss(animated: true, completion: nil)
        })
    }
}

extension ScreenEdgeDetectorViewController : GetActiveViewController {
    
    var activeViewController: UIViewController? {
        return childViewControllers.last
    }
    
}
