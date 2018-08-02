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

/// A type that determins the preferred config, which will be used by the router if available.
public protocol PreferredRouterConfig {
    
    var preferredRouterConfig: Router.RouterConfig? { get }
    
}

public struct Router : Intent {
    
    public static var defaultCtx = IntentCtx<Router>(scheme: "router")
    
    public var input: [String : Any]?
    
    public var config: RouterConfig = .auto
    
    public var executor: UIViewController?
    
    public let intention: ([String : Any]?) -> UIViewController
    
    public var transition: Transition?
    
    public func submit(complete: (() -> ())? = nil) {
        DispatchQueue.main.async {
            var executor = self.executor
            if executor == nil {
                executor = Router.topViewController
            }
            assert(executor != nil)
            self.submit(executer: executor!, config: self.config, complete: complete)
        }
    }
    
    public init(intention: @escaping Intention) {
        self.intention = intention
    }
    
    public enum RouterConfig {
        
        case auto
        
        /// call presentViewController:animated:completion:
        case present(PresentOption?)
        
        /// call pushViewController:animated:
        case push(PushOption?)
        
        case `switch`(SwitchOption?)
        
        case modal(ModalOption?)
        
        /// call addChildViewController: and view.addSubview
        case child
        
        fileprivate func autoTransform(forExecuter executer: UIViewController) -> RouterConfig {
            if (executer.navigationController != nil) || (executer is UINavigationController) {
                return .push(nil)
            } else {
                return .present(nil)
            }
        }
        
        public struct PresentOption : OptionSet {
            
            public var rawValue = 0
            
            public init(rawValue: Int) {
                self.rawValue = rawValue
            }
            
            public static let cancelAnimation = PresentOption(rawValue: 1 << 0)
            
            /// wrap destination with a UINavigationController
            public static let wrapNC = PresentOption(rawValue: 1 << 1)
            
            ///present with a push animation
            public static let fakePush = PresentOption(rawValue: 1 << 2)
            
        }
        
        public struct PushOption : OptionSet {
            
            public var rawValue = 0
            
            public init(rawValue: Int) {
                self.rawValue = rawValue
            }
            
            public static let cancelAnimation = PushOption(rawValue: 1 << 0)
            
            ///push item and clear all items before in the stack
            public static let clearTop = PushOption(rawValue: 1 << 1)
            
            ///remove all Target.class in the stack before pushing it
            public static let singleTop = PushOption(rawValue: 1 << 2)
            
            ///push item and remove items before to make sure that there are less equal than two vcs in the stack
            public static let rootTop = PushOption(rawValue: 1 << 3)
            
            ///push item and remove the last item in the stack
            public static let clearLast = PushOption(rawValue: 1 << 4)
        }
        
        public struct SwitchOption : OptionSet {
            
            public var rawValue = 0
            
            public init(rawValue: Int) {
                self.rawValue = rawValue
            }
            
            public static let cancelAnimation = SwitchOption(rawValue: 1 << 0)
            
            ///Iteration is made from the first element by default. Nearest config makes it reversed.
            public static let nearest = SwitchOption(rawValue: 1 << 1)
            
        }
        
        public struct ModalOption : OptionSet {
            
            public var rawValue = 0
            
            public init(rawValue: Int) {
                self.rawValue = rawValue
            }
            
            public static let cancelAnimation = ModalOption(rawValue: 1 << 0)
            
            ///add a dark blur background, default is a alpha-dark background on the top window
            public static let dimBlur = ModalOption(rawValue: 1 << 1)
            
            ///content view will be at bottom, default is centered
            public static let contentBottom = ModalOption(rawValue: 1 << 2)
            
            ///content view will be at top
            public static let contentTop = ModalOption(rawValue: 1 << 3)
            
        }
    }
}

extension Router {
    
    private func submit(executer: UIViewController, config: RouterConfig, complete:(() -> ())?) {
        var newConfig = config
        
        let vc = intention(input)
        if let presetVC = vc as? PreferredRouterConfig, let presetConfig = presetVC.preferredRouterConfig {
            newConfig = presetConfig
        }
        
        if case .auto = config {
            newConfig = config.autoTransform(forExecuter: executer)
        }
        
        vc.extra = input
        
        switch newConfig {
        case .present(let presentOpt):
            exePresent(executer: executer, intentionVC: vc, option: presentOpt ?? [], complete: complete)
        case .push(let pushOpt):
            exePush(executer: executer, intentionVC: vc, option: pushOpt ?? [], complete: complete)
        case .`switch`(let switchOpt):
            exeSwitch(executer: executer, intentionVC: vc, option: switchOpt ?? [], complete: complete)
        case .modal(let modalOpt):
            exeModal(executer: executer, intentionVC: vc, option: modalOpt ?? [], complete: complete)
        case .child:
            exeAddChild(executer: executer, intentionVC: vc, complete: complete)
        default:
            break
        }
    }
    
    private func exePresent(executer: UIViewController, intentionVC: UIViewController, option: RouterConfig.PresentOption, complete:(() -> ())?) {
        let animated = !option.contains(.cancelAnimation)
        var targetDest = intentionVC
        if option.contains(.wrapNC) {
            targetDest = UINavigationController(rootViewController: intentionVC)
            var items = Array<UIBarButtonItem>()
            
            let backItem = UIBarButtonItem(image: Router.backIndicatorImage, style: .plain, target: targetDest, action: #selector(UIViewController.internal_dismiss))
            if #available(iOS 11.0, *) {
                backItem.imageInsets = UIEdgeInsets(top: 0, left: -NavigationBarLayoutMargin * 0.5, bottom: 0, right: NavigationBarLayoutMargin * 0.5)
            } else {
                backItem.imageInsets = UIEdgeInsets(top: 0, left: NavigationBarLayoutMargin * 0.5, bottom: 0, right: -NavigationBarLayoutMargin * 0.5)
                let negativeSeperator = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
                negativeSeperator.width = -NavigationBarLayoutMargin
                items.append(negativeSeperator)
            }
            items.append(backItem)
            intentionVC.navigationItem.leftBarButtonItems = items
        }
        
        var mTransition = transition
        
        if option.contains(.fakePush) {
            let containerVC = _ScreenEdgeDetectorViewController()
            containerVC.addChildViewController(targetDest)
            targetDest = containerVC
            
            mTransition = SystemTransition(axis: .horizontal, style: .translate(factor: -0.28))
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
    
    private func exePush(executer: UIViewController, intentionVC: UIViewController, option: RouterConfig.PushOption, complete:(() -> ())?) {
        
        func autoGetPushableViewController(executer: UIViewController) -> UINavigationController? {
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
        
        guard let pushableNC = autoGetPushableViewController(executer: executer) else {
            fatalError("Trying to submit push action with no navigationController")
        }
        
        let animated = !option.contains(.cancelAnimation)
        
        if option.contains(.clearTop) {
            for vc in pushableNC.viewControllers {
                vc.isRemovingFromStack = true
            }
        } else if option.contains(.singleTop) {
            for vc in pushableNC.viewControllers {
                if vc != intentionVC && vc.isMember(of: type(of: intentionVC)) {
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
        
        if animated, let transition = transition {
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
    
    private func exeSwitch(executer: UIViewController, intentionVC: UIViewController, option: RouterConfig.SwitchOption, complete:(() -> ())?) {
        
        if (executer.isKind(of: intentionVC.classForCoder)) {
            return
        }
        
        let animated = !option.contains(.cancelAnimation)
        
        executer.viewWillDisappear(animated)
        
        if option.contains(.nearest) {
            var comparedVC: UIViewController? = executer
            while comparedVC != nil {
                if comparedVC!.switchTo(class: type(of: intentionVC), isReversed: option.contains(.nearest)) {
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
        } else {
            //If we have found the target VC when we iterate over the VCs on the key window, we should dismiss the later ones.
            func clearPresentViewControllerStack(array: [UIViewController]) {
                guard array.count > 0 else {
                    return
                }
                var mutableVCArray = array
                let topVC = mutableVCArray.removeLast()
                topVC.dismiss(animated: (mutableVCArray.count > 0 ? false : animated), completion: {
                    clearPresentViewControllerStack(array: mutableVCArray)
                })
            }
            
            var comparedVC: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
            while comparedVC != nil {
                if comparedVC!.switchTo(class: type(of: intentionVC), isReversed: option.contains(.nearest)) {
                    executer.viewDidDisappear(animated)
                    var vcArray = Array<UIViewController>()
                    while comparedVC?.presentedViewController != nil {
                        vcArray.append((comparedVC?.presentedViewController)!)
                        comparedVC = comparedVC?.presentedViewController
                    }
                    clearPresentViewControllerStack(array: vcArray)
                    break
                } else {
                    comparedVC = comparedVC?.presentedViewController
                }
            }
        }
        complete?()
    }
    
    private func exeModal(executer: UIViewController, intentionVC: UIViewController, option: RouterConfig.ModalOption, complete:(() -> ())?) {
        let modalVC = _ModalViewController()
        modalVC.modalOption = option
        modalVC.addChildViewController(intentionVC)
        modalVC.present()
        complete?()
    }
}

private let NavigationBarLayoutMargin = CGFloat(16.0)
