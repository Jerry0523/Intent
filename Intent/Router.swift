//
// Router.swift
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

public protocol PreferredRouterConfig {
    
    var preferredRouterConfig: RouterConfig? { get }
    
}

public enum RouterConfig {
    
    case auto
    
    case present(PresentOption?)    //call presentViewController:animated:completion:
    
    case push(PushOption?)       //call pushViewController:animated:
    
    case `switch`(RouterOption?)
    
    case modal(ModalOption?)
    
    case child      //call addChildViewController: and view.addSubview
    
    fileprivate func autoTransform(forExecuter executer: UIViewController) -> RouterConfig {
        if (executer.navigationController != nil) || (executer is UINavigationController) {
            return .push(nil)
        } else {
            return .present(nil)
        }
    }
    
}

public struct Router : Intent {

    public var extra: [String : Any]?
    
    public var config: RouterConfig = .auto
    
    public var executor: UIViewController?
    
    public var intention: UIViewController.Type?
    
    public var transition: Transition?
    
    public func submit(complete: (() -> ())? = nil) {
        DispatchQueue.main.async {
            var executor = self.executor
            if executor == nil {
                executor = Router.topViewController
            }
            assert(executor != nil)
            assert(self.intention != nil)
            
            self.submit(executer: executor!, config: self.config, complete: complete)
        }
    }
    
    public init() {
        
    }
}

extension Router {
    
    public static var backImageName = "navigation_back"
    
    public static var topViewController: UIViewController? {
        get {
            let keyWindow = UIApplication.shared.keyWindow
            var topVC = keyWindow?.rootViewController
            while topVC?.presentedViewController != nil {
                topVC = topVC?.presentedViewController
            }
            
            while let topAbility = topVC as? GetTopViewController {
                topVC = topAbility.topViewController
            }
            
            return topVC
        }
    }
    
    public static var topWindow: UIWindow {
        get {
            let appDelegate = UIApplication.shared.delegate as? GetTopWindow
            assert(appDelegate != nil, "AppDelegate should confirm to GetTopWindow Protocol")
            return appDelegate!.topWindow
        }
    }
    
}

extension Router {
    
    private func submit(executer: UIViewController, config: RouterConfig, complete:(() -> ())?) {
        var newConfig = config
        
        guard let vc = self.intention?.init() else {
            return
        }
        if let presetVC = vc as? PreferredRouterConfig, let presetConfig = presetVC.preferredRouterConfig {
            newConfig = presetConfig
        }
        
        if case .auto = config {
            newConfig = config.autoTransform(forExecuter: executer)
        }
        
        vc.extra = extra
        
        switch newConfig {
        case .present(let presentOpt):
            self.exePresent(executer: executer, intentionVC: vc, option: presentOpt ?? [], complete: complete)
        case .push(let pushOpt):
            self.exePush(executer: executer, intentionVC: vc, option: pushOpt ?? [], complete: complete)
        case .`switch`(let switchOpt):
            self.exeSwitch(executer: executer, intentionVC: vc, option: switchOpt ?? [], complete: complete)
        case .modal(let modalOpt):
            self.exeModal(executer: executer, intentionVC: vc, option: modalOpt ?? [], complete: complete)
        case .child:
            self.exeAddChild(executer: executer, intentionVC: vc, complete: complete)
        default:
            break
        }
    }
    
    private func exePresent(executer: UIViewController, intentionVC: UIViewController, option: PresentOption, complete:(() -> ())?) {
        let animated = !option.contains(.cancelAnimation)
        var targetDest = intentionVC
        if option.contains(.wrapNC) {
            targetDest = UINavigationController.init(rootViewController: intentionVC)
            var items = Array<UIBarButtonItem>()
            
            let backItem = UIBarButtonItem.init(image: UIImage.init(named: Router.backImageName), style: .plain, target: targetDest, action: #selector(UIViewController.internal_dismiss))
            if #available(iOS 11.0, *) {
                backItem.imageInsets = UIEdgeInsets.init(top: 0, left: -8, bottom: 0, right: 8)
            } else {
                backItem.imageInsets = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: -8)
                let negativeSeperator = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
                negativeSeperator.width = -16
                items.append(negativeSeperator)
            }
            items.append(backItem)
            intentionVC.navigationItem.leftBarButtonItems = items
        }
        
        var mTransition = self.transition
        
        if option.contains(.fakePush) {
            let containerVC = ScreenEdgeDetectorViewController.init()
            containerVC.addChildViewController(targetDest)
            targetDest = containerVC
            
            mTransition = SystemTransition.init(axis: .horizontal, style: .translate(factor: -0.28))
            mTransition?.duration = CATransaction.animationDuration() * 1.5
        }
        
        if animated, let transition = mTransition {
            transition.fromVC = executer
            transition.toVC = targetDest
            targetDest.presentTransition = transition
            targetDest.transitioningDelegate = transition
        }
        executer.present(targetDest, animated: animated, completion: complete)
    }
    
    private func exePush(executer: UIViewController, intentionVC: UIViewController, option: PushOption, complete:(() -> ())?) {
        guard let pushableNC = Router.autoGetPushableViewController(executer: executer) else {
            fatalError("Trying to submit push action with no navigationController")
        }
        
        let animated = !option.contains(.cancelAnimation)
        
        if option.contains(.clearTop) {
            for vc in pushableNC.viewControllers {
                vc.isRemovingFromStack = true
            }
        } else if option.contains(.singleTop) {
            for vc in pushableNC.viewControllers {
                if vc != intentionVC && vc.isMember(of: self.intention!) {
                    vc.isRemovingFromStack = true
                }
            }
        } else if option.contains(.rootTop) {
            for i in 1..<pushableNC.viewControllers.count {
                let vc = pushableNC.viewControllers[i]
                vc.isRemovingFromStack = true
            }
        } else if option.contains(.clearLast) {
            pushableNC.viewControllers.last?.isRemovingFromStack = true
        }
        
        if animated, let transition = self.transition {
            transition.fromVC = executer
            transition.toVC = intentionVC
            intentionVC.pushTransition = transition
            NCProxyDelegate.addProxy(forNavigationController: pushableNC)
        }
        
        let shouldResetHideBottomBarWhenPushed = !intentionVC.hidesBottomBarWhenPushed
        if (shouldResetHideBottomBarWhenPushed) {
            executer.hidesBottomBarWhenPushed = true;
        }
        
        pushableNC.pushViewController(intentionVC, animated: animated)
        
        if (shouldResetHideBottomBarWhenPushed) {
            executer.hidesBottomBarWhenPushed = false;
        }
        
        var vcArray: [UIViewController] = []
        for vc in pushableNC.viewControllers {
            if !vc.isRemovingFromStack {
                vcArray.append(vc)
            }
        }
        pushableNC.setViewControllers(vcArray, animated: false)
        complete?()
    }
    
    private func exeAddChild(executer: UIViewController, intentionVC: UIViewController, complete:(() -> ())?) {
        executer.addChildViewController(intentionVC)
        intentionVC.view.frame = executer.view.bounds
        intentionVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        executer.view.addSubview(intentionVC.view)
        intentionVC.didMove(toParentViewController: executer)
        complete?()
    }
    
    private func exeSwitch(executer: UIViewController, intentionVC: UIViewController, option: RouterOption, complete:(() -> ())?) {
        if (executer.isKind(of: intentionVC.classForCoder)) {
            return
        }
        
        let animated = !option.contains(.cancelAnimation)
        
        executer.viewWillDisappear(animated)
        
        var comparedVC: UIViewController? = executer
        while comparedVC != nil {
            if comparedVC!.switchTo(class: self.intention!) {
                executer.viewDidDisappear(animated)
                break
            } else {
                let parentVC = comparedVC?.parent
                if parentVC != nil {
                    comparedVC = parentVC
                } else {
                    let presenting = comparedVC?.presentingViewController
                    if presenting != nil {
                        comparedVC?.dismiss(animated: animated, completion: nil)
                    }
                    comparedVC = presenting
                }
            }
        }
        complete?()
    }
    
    private func exeModal(executer: UIViewController, intentionVC: UIViewController, option: ModalOption, complete:(() -> ())?) {
        let modalVC = ModalVC.init()
        modalVC.modalOption = option
        modalVC.add(contentVC: intentionVC)
        modalVC.present()
        complete?()
    }
    
    private static func autoGetPushableViewController(executer: UIViewController) -> UINavigationController? {
        var nc: UINavigationController? = executer as? UINavigationController
        if nc == nil {
            var superVC = executer.parent
            while superVC != nil {
                nc = superVC as? UINavigationController
                if nc != nil {
                    break
                } else {
                    superVC = superVC?.parent
                }
            }
        }
        return nc
    }
}

public struct RouterOption : OptionSet {
    
    public var rawValue = 0
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let cancelAnimation = RouterOption(rawValue: 1 << 0)
    
}

public struct PresentOption : OptionSet {
    
    public var rawValue = 0
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let cancelAnimation = PresentOption(rawValue: 1 << 0)
    
    public static let wrapNC = PresentOption(rawValue: 1 << 1)      //wrap destination with UINavigationController
    
    public static let fakePush = PresentOption(rawValue: 1 << 2)    //present with a push animation
    
}

public struct PushOption : OptionSet {
    
    public var rawValue = 0
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let cancelAnimation = PushOption(rawValue: 1 << 0)
    
    public static let clearTop = PushOption(rawValue: 1 << 1)      //push item and clear items before
    
    public static let singleTop = PushOption(rawValue: 1 << 2)    //remove all item.class in stack before pushing it
    
    public static let rootTop = PushOption(rawValue: 1 << 3)    //push item and remove items to make sure that there are less equal than two vcs in stack
    
    public static let clearLast = PushOption(rawValue: 1 << 4)    //push item and remove the last one
}

public struct ModalOption : OptionSet {
    
    public var rawValue = 0
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let cancelAnimation = ModalOption(rawValue: 1 << 0)
    
    public static let dimBlur = ModalOption(rawValue: 1 << 1)      //add a dark blur background, default is a alpha-dark background when on modal window and transparent on top window
    
    public static let contentBottom = ModalOption(rawValue: 1 << 2)    //content view will be placed at bottom, default is centered
    
    public static let contentTop = ModalOption(rawValue: 1 << 3)    //content view will be placed at top
    
}
