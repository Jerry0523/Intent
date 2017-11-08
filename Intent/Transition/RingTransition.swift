//
//  RingTransition.swift
//  OTSKit
//
//  Created by Jerry on 2017/6/29.
//  Copyright © 2017年 Yihaodian. All rights reserved.
//

import UIKit

@objc public protocol RingTransitionDataSource : NSObjectProtocol {
    
    @objc optional func viewForTransition() -> UIView?
    
}

open class RingTransition: Transition, CAAnimationDelegate {
    
    override func present(_ vcToBePresent: UIViewController, fromVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        
        super.present(vcToBePresent, fromVC: fromVC, container: container, context: context)
        
        guard let actionView = (self.fromVC as? RingTransitionDataSource)?.viewForTransition?() else {
            context.completeTransition(true)
            return
        }
        
        let actionRect = actionView.superview!.convert(actionView.frame, to: container)
        let actionCenter = CGPoint.init(x: actionRect.midX, y: actionRect.midY)
        
        let containerWidth = container.frame.size.width
        let containerHeight = container.frame.size.height
        
        var endCenter = CGPoint.zero
        
        if actionCenter.x < containerWidth * 0.5 {
            endCenter = actionCenter.y < containerHeight * 0.5 ? CGPoint.init(x: containerWidth, y: containerHeight) : CGPoint.init(x: containerWidth, y: 0)
        } else {
            endCenter = actionCenter.y < containerHeight * 0.5 ? CGPoint.init(x: 0, y: containerHeight) : CGPoint.init(x: 0, y: 0)
        }
        
        let finalRectHalfDistance = max(fabs(endCenter.x - actionCenter.x), fabs(endCenter.y - actionCenter.y))
        let finalRect = CGRect.init(x: actionCenter.x - finalRectHalfDistance, y: actionCenter.y - finalRectHalfDistance, width: finalRectHalfDistance * 2.0, height: finalRectHalfDistance * 2.0)
        
        self.startPath = UIBezierPath.init(ovalIn: actionRect)
        self.endPath = UIBezierPath.init(ovalIn: finalRect)
        
        let maskLayer = CAShapeLayer.init()
        maskLayer.path = self.endPath?.cgPath
        
        let viewToBePresent = (context.view(forKey: .to) ?? vcToBePresent.view)!
    
        viewToBePresent.layer.mask = maskLayer
        
        let pathAnimation = CABasicAnimation.init(keyPath: "path")
        pathAnimation.fromValue = self.startPath?.cgPath
        pathAnimation.toValue = self.endPath?.cgPath
        pathAnimation.duration = self.duration
        pathAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        pathAnimation.delegate = self
        
        maskLayer.add(pathAnimation, forKey: "ringAnimation")
        
        self.clearFunction = {
            viewToBePresent.layer.mask = nil
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
    
    override func dismiss(_ vcToBeDismissed: UIViewController, toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        
        super.dismiss(vcToBeDismissed, toVC: toVC, container: container, context: context)
        
        if self.startPath == nil || self.endPath == nil {
            context.completeTransition(true)
            return
        }
        
        let maskLayer = CAShapeLayer.init()
        maskLayer.path = self.startPath?.cgPath
        
        let viewToBeDismissed = (context.view(forKey: .from) ?? vcToBeDismissed.view)!
        
        viewToBeDismissed.layer.mask = maskLayer
        
        let pathAnimation = CABasicAnimation.init(keyPath: "path")
        pathAnimation.fromValue = self.endPath?.cgPath
        pathAnimation.toValue = self.startPath?.cgPath
        pathAnimation.duration = self.duration
        pathAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        pathAnimation.delegate = self
        
        maskLayer.add(pathAnimation, forKey: "ringInvertAnimation")
        
        self.clearFunction = {
            UIView.performWithoutAnimation {
                viewToBeDismissed.layer.mask = nil
            }
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
    
    // MARK: - CAAnimationDelegate
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.clearFunction?()
        self.clearFunction = nil
    }
    
    private var startPath: UIBezierPath?
    private var endPath: UIBezierPath?
    
    private var clearFunction: (()-> Swift.Void)?
    
    override var useBaseAnimation: Bool {
        return true
    }
}
