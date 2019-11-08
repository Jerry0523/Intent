//
// Route.swift
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

/// A type that determins the preferred config, which will be used by the Route if available.
public protocol PreferredRouteConfig {
    
    var preferredRouteConfig: Route.RouteConfig? { get }
    
}

public final class Route : Intent {
    
    public typealias Intention = ([String : Any]?) -> UIViewController
    
    public static var defaultCtx = IntentCtx<Intention>(scheme: "Route")
    
    public var input: [String : Any]?
    
    public var config: RouteConfig = .auto
    
    public var executor: UIViewController?
    
    public let intention: Intention
    
    public let id: String
    
    public var transition: Transition?
    
    public func doSubmit(complete: (() -> ())? = nil) {
        DispatchQueue.main.async {
            self.submit(config: self.config, complete: complete)
        }
    }
    
    public init(_ id: String = AnonymousId, _ intention: @escaping Intention) {
        self.intention = intention
        self.id = id
    }
    
    public enum RouteConfig {
        
        case auto
        
        /// call presentViewController:animated:completion:
        case present(PresentOption?, UIModalPresentationStyle)
        
        /// call pushViewController:animated:
        case push(PushOption?)
        
        case `switch`(SwitchOption?)
        
        case popup(PopupOption?)
        
        /// call addChildViewController: and view.addSubview
        case asChild
        
        fileprivate func autoTransform(forExecuter executer: UIViewController) -> RouteConfig {
            if (executer.navigationController != nil) || (executer is UINavigationController) {
                return .push(nil)
            } else {
                return .present(nil, .fullScreen)
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
        
        public struct PopupOption : OptionSet {
            
            public var rawValue = 0
            
            public init(rawValue: Int) {
                self.rawValue = rawValue
            }
            
            public static let cancelAnimation = PopupOption(rawValue: 1 << 0)
            
            ///add a dark blur background, default is a alpha-dark background on the top window
            public static let dimBlur = PopupOption(rawValue: 1 << 1)
            
            ///content view will be at bottom, default is centered
            public static let contentBottom = PopupOption(rawValue: 1 << 2)
            
            ///content view will be at top
            public static let contentTop = PopupOption(rawValue: 1 << 3)
            
        }
    }
}

extension Route {
    
    private func prepare(config: inout RouteConfig) -> (executor: UIViewController, output: UIViewController) {
        var mExecutor = executor
        if mExecutor == nil {
            mExecutor = Route.topViewController
        }
        assert(mExecutor != nil)

        let vc = intention(input)
        if let presetVC = vc as? PreferredRouteConfig, let presetConfig = presetVC.preferredRouteConfig {
            config = presetConfig
        }
        
        if case .auto = config {
            config = config.autoTransform(forExecuter: mExecutor!)
        }
        
        vc.extra = input
        return (mExecutor!, vc)
    }
    
    private func submit(config: RouteConfig, complete:(() -> ())?) {
        var newConfig = config
        let (mExecutor, vc) = prepare(config: &newConfig)
        switch newConfig {
        case .present(let presentOpt, let presentStyle):
            exePresent(executer: mExecutor, intentionVC: vc, option: presentOpt ?? [], presentStyle: presentStyle, complete: complete)
        case .push(let pushOpt):
            exePush(executer: mExecutor, intentionVC: vc, option: pushOpt ?? [], complete: complete)
        case .`switch`(let switchOpt):
            exeSwitch(executer: mExecutor, intentionVC: vc, option: switchOpt ?? [], complete: complete)
        case .popup(let popupOpt):
            exePopup(executer: mExecutor, intentionVC: vc, option: popupOpt ?? [], complete: complete)
        case .asChild:
            exeAddChild(executer: mExecutor, intentionVC: vc, complete: complete)
        default:
            break
        }
    }
    
    private func exePresent(executer: UIViewController, intentionVC: UIViewController, option: RouteConfig.PresentOption, presentStyle: UIModalPresentationStyle, complete:(() -> ())?) {
        let animated = !option.contains(.cancelAnimation)
        var targetDest = intentionVC
        if option.contains(.wrapNC) {
            targetDest = UINavigationController(rootViewController: intentionVC)
            var items = Array<UIBarButtonItem>()
            
            let backItem = UIBarButtonItem(image: Route.backIndicatorImage, style: .plain, target: targetDest, action: #selector(UIViewController.internal_dismiss))
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
            containerVC.addChild(targetDest)
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
        targetDest.modalPresentationStyle = presentStyle
        executer.present(targetDest, animated: animated, completion: {
            complete?()
        })
    }
    
    private func exePush(executer: UIViewController, intentionVC: UIViewController, option: RouteConfig.PushOption, complete:(() -> ())?) {
        
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
        executer.addChild(intentionVC)
        intentionVC.view.frame = executer.view.bounds
        intentionVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        executer.view.addSubview(intentionVC.view)
        intentionVC.didMove(toParent: executer)
        complete?()
    }
    
    private func exeSwitch(executer: UIViewController, intentionVC: UIViewController, option: RouteConfig.SwitchOption, complete:(() -> ())?) {
        
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
    
    private func exePopup(executer: UIViewController, intentionVC: UIViewController, option: RouteConfig.PopupOption, complete:(() -> ())?) {
        let popupVC = _PopupViewController()
        popupVC.popupOption = option
        popupVC.addChild(intentionVC)
        popupVC.present()
        complete?()
    }
}

public extension Route {
    
    func transition(_ transition: Transition?) -> Route {
        self.transition = transition
        return self
    }
    
    func input(_ input: [String : Any]) -> Route {
        self.input = input
        return self
    }
    
    func config(_ config: RouteConfig) -> Route {
        self.config = config
        return self
    }
    
    func executor(_ executor: UIViewController) -> Route {
        self.executor = executor
        return self
    }
    
}

private let NavigationBarLayoutMargin = CGFloat(16.0)
