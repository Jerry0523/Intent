//
// Transition.swift
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

public protocol CustomTransition {
    
    var presentTransition: Transition? { get set }
    
    var pushTransition: Transition? { get set }
    
}

extension UIViewController : CustomTransition {
    
    public var presentTransition: Transition? {
        get {
            return objc_getAssociatedObject(self, &UIViewController.presentTransitionKey) as? Transition
        }
        set {
            objc_setAssociatedObject(self, &UIViewController.presentTransitionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var pushTransition: Transition? {
        get {
            return objc_getAssociatedObject(self, &UIViewController.pushTransitionKey) as? Transition
        }
        set {
            objc_setAssociatedObject(self, &UIViewController.pushTransitionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private static var presentTransitionKey: Void?
    
    private static var pushTransitionKey: Void?
    
}

public protocol TransitionDelegate : NSObjectProtocol {
    
    /// If a VC comfirm to this protocol, it should deal with different roles.
    /// As the sender, it should setup the param, which is an inout dictionary.
    /// As the receiver, it could take use of the param, which is set by the sender.
    func transitionWillBegin(param: inout [AnyHashable: Any]?, role: Transition.TransitionRole)
    
}

open class Transition: NSObject {
    
    open var duration: CFTimeInterval = 0
    
    open var interactiveController: UIPercentDrivenInteractiveTransition?
    
    public override init() {
        super.init()
        duration = preferredDuration
    }
    
    public convenience init(fromVC: UIViewController, toVC: UIViewController) {
        self.init()
        self.fromVC = fromVC
        self.toVC = toVC
    }
    
    func present(_ vcToBePresent: UIViewController, fromVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        
        if let finalView = context.view(forKey: .to) {
            let finalFrame = context.finalFrame(for: vcToBePresent)
            finalView.frame = finalFrame
            container.addSubview(finalView)
        }
        
        deliveryParams(sender: fromVC, receiver: toVC)
    }
    
    func dismiss(_ vcToBeDismissed: UIViewController, toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        
        if let finalView = context.view(forKey: .to), let fromView = context.view(forKey: .from) {
            let finalFrame = context.finalFrame(for: toVC)
            finalView.frame = finalFrame
            container.insertSubview(finalView, belowSubview: fromView)
        }
        deliveryParams(sender: vcToBeDismissed, receiver: fromVC)
    }
    
    private func deliveryParams(sender: UIViewController?, receiver: UIViewController?) {
        let senderProtocol = sender as? TransitionDelegate
        let receiverProtocol = receiver as? TransitionDelegate
        var params: [AnyHashable: Any]?
        senderProtocol?.transitionWillBegin(param: &params, role: .sender)
        receiverProtocol?.transitionWillBegin(param: &params, role: .receiver)
    }
    
    public var preferredDuration: CFTimeInterval {
        return CATransaction.animationDuration() * 2.0
    }
    
    var interactiveControllerType: UIPercentDrivenInteractiveTransition.Type {
        return UIPercentDrivenInteractiveTransition.self
    }
    
    weak var fromVC: UIViewController?
    
    weak var toVC: UIViewController?
}

extension Transition : UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (fromVC != nil) {
            return self
        }
        return nil
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveController
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveController
    }
    
}

extension Transition : UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let to = transitionContext.viewController(forKey: .to)
        let from = transitionContext.viewController(forKey: .from)
        let container = transitionContext.containerView
        
        if (to == toVC) {//present
            present(to!, fromVC: from!, container: container, context: transitionContext)
        } else {//dismiss
            dismiss(from!, toVC: to!, container: container, context: transitionContext)
        }
    }
    
}

extension Transition {
    
    public enum TransitionRole {
        
        case sender
        
        case receiver
        
    }
    
    public enum TransitionGestureAxis {
        
        case horizontalLeftToRight
        
        case horizontalRightToLeft
        
        case verticalTopToBottom
        
        case verticalBottomToTop
        
        func getRefrenceLength(forView view: UIView?) -> CGFloat {
            switch self {
            case .horizontalLeftToRight, .horizontalRightToLeft:
                return view?.frame.size.width ?? 0
            case .verticalTopToBottom, .verticalBottomToTop:
                return view?.frame.size.height ?? 0
            }
        }
        
        func getTranslatePercent(forView view: UIView?, point: CGPoint) -> CGFloat {
            let refrenceLength = getRefrenceLength(forView: view)
            switch self {
            case .horizontalLeftToRight:
                return point.x / refrenceLength
            case .horizontalRightToLeft:
                return -point.x / refrenceLength
            case .verticalTopToBottom:
                return point.y / refrenceLength
            case .verticalBottomToTop:
                return -point.y / refrenceLength
            }
        }
    }
    
    public func handle(_ recognizer: UIPanGestureRecognizer, gestureDidBegin: () -> (), axis: TransitionGestureAxis = .horizontalLeftToRight , completeThreshold: CGFloat = 0.5) {
        let actionView = recognizer.view
        assert(completeThreshold > 0 && completeThreshold < 1)
        
        let point = recognizer.translation(in: actionView)
        let per = axis.getTranslatePercent(forView: actionView, point: point)
        
        if per < 0 && recognizer.isEnabled {
            recognizer.isEnabled = false
        }
        defer {
            recognizer.isEnabled = true
        }
        switch recognizer.state {
        case .began:
            interactiveController = interactiveControllerType.init()
            gestureDidBegin()
        case .changed:
            interactiveController?.update(per)
        case .ended, .cancelled:
            if per > completeThreshold {
                interactiveController?.finish()
            } else {
                interactiveController?.cancel()
            }
            interactiveController = nil
        default:
            break
        }
    }
}
