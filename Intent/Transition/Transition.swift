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

@objc public protocol TransitionDelegate : NSObjectProtocol {
    
    @objc optional func paramToBeSentBeforeTransitionBegin() -> [AnyHashable: Any]? //e.g., when A -> B, before transition, animation will delivery A's param to B
    @objc optional func transitionWillBegin(withParamToBeReceived param: [AnyHashable: Any]?)//e.g., when A -> B, B will receive param sent from A after transition
    
}

open class Transition: NSObject {
    
    open var duration = CATransaction.animationDuration() * 2.0
    open var interactiveController: UIPercentDrivenInteractiveTransition?
    
    public override init() {
        super.init()
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
        
        self.deliveryParamBeforeTransition(sender: self.fromVC, executer: self.toVC)
    }
    
    func dismiss(_ vcToBeDismissed: UIViewController, toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        
        if let finalView = context.view(forKey: .to), let fromView = context.view(forKey: .from) {
            let finalFrame = context.finalFrame(for: toVC)
            finalView.frame = finalFrame
            container.insertSubview(finalView, belowSubview: fromView)
        }
        self.deliveryParamBeforeTransition(sender: self.toVC, executer: self.fromVC)
    }
    
    private func deliveryParamBeforeTransition(sender: UIViewController?, executer: UIViewController?) {
        let executerProtocol = executer as? TransitionDelegate
        let inputParam = (sender as? TransitionDelegate)?.paramToBeSentBeforeTransitionBegin?()
        executerProtocol?.transitionWillBegin?(withParamToBeReceived: inputParam)
    }
    
    var useBaseAnimation: Bool {
        return false
    }
    
    weak var fromVC: UIViewController?
    weak var toVC: UIViewController?
}

extension Transition : UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (self.fromVC != nil) {
            return self
        }
        return nil
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactiveController
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactiveController
    }
    
}

extension Transition : UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let to = transitionContext.viewController(forKey: .to)
        let from = transitionContext.viewController(forKey: .from)
        let container = transitionContext.containerView
        
        if (to == self.toVC) {//present
            self.present(to!, fromVC: from!, container: container, context: transitionContext)
        } else {//dismiss
            self.dismiss(from!, toVC: to!, container: container, context: transitionContext)
        }
    }
    
}

extension Transition {
    
    public func handle(interactivePanGesture recognizer: UIPanGestureRecognizer, axis: UILayoutConstraintAxis, threshold: CGFloat, beginAction: () -> ()) {
        let actionView = recognizer.view
        let refrenceLength = (axis == .vertical ? actionView?.frame.size.height : actionView?.frame.size.width) ?? 0

        assert(refrenceLength > 0)
        assert(threshold > 0 && threshold < 1)
        
        let point = recognizer.translation(in: actionView)
        let per = max((axis == .vertical ? point.y : point.x) / refrenceLength, 0)
        
        switch recognizer.state {
        case .began:
            self.interactiveController = self.useBaseAnimation ? CAPercentDrivenInteractiveTransition.init() : UIPercentDrivenInteractiveTransition.init()
            beginAction()
        case .changed:
            self.interactiveController?.update(per)
        case .ended, .cancelled:
            if per > threshold {
                self.interactiveController?.finish()
            } else {
                self.interactiveController?.cancel()
            }
            self.interactiveController = nil
        default:
            break
        }
    }
}

fileprivate class CAPercentDrivenInteractiveTransition : UIPercentDrivenInteractiveTransition {
    
    private var pausedTime: CFTimeInterval = 0
    private var currentPercent: CGFloat = 0
    private weak var transitionCtx: UIViewControllerContextTransitioning?
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)
        self.transitionCtx = transitionContext
        self.pause(layer: transitionContext.containerView.layer)
    }
    
    override func update(_ percentComplete: CGFloat) {
        self.currentPercent = percentComplete
        self.transitionCtx?.updateInteractiveTransition(percentComplete)
        if self.transitionCtx != nil {
            self.transitionCtx!.containerView.layer.timeOffset = self.pausedTime + CFTimeInterval(self.duration * percentComplete)
        }
    }
    
    override func cancel() {
        self.transitionCtx?.cancelInteractiveTransition()
        if self.transitionCtx != nil {
            let containerLayer = self.transitionCtx!.containerView.layer
            containerLayer.speed = -1.0
            containerLayer.beginTime = CACurrentMediaTime()
            
            let delay = (1.0 - currentPercent) * self.duration + 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay), execute: {
                self.resume(layer: containerLayer)
                self.transitionCtx = nil
            })
        }
    }
    
    override func finish() {
        self.transitionCtx?.finishInteractiveTransition()
        if self.transitionCtx != nil {
            self.resume(layer: self.transitionCtx!.containerView.layer)
            self.transitionCtx = nil
        }
        
    }
    
    private func pause(layer: CALayer) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0
        layer.timeOffset = pausedTime
        self.pausedTime = pausedTime
    }
    
    private func resume(layer: CALayer) {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
}
