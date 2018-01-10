//
// RingTransition.swift
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

@objc public protocol RingTransitionDataSource : NSObjectProtocol {
    
    @objc optional func viewForTransition() -> UIView?
    
}

open class RingTransition: Transition {
    
    override func present(_ vcToBePresent: UIViewController, fromVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        
        super.present(vcToBePresent, fromVC: fromVC, container: container, context: context)
        
        guard let actionView = (fromVC as? RingTransitionDataSource)?.viewForTransition?() else {
            context.completeTransition(true)
            return
        }
        
        let actionRect = actionView.superview!.convert(actionView.frame, to: container)
        let actionCenter = CGPoint(x: actionRect.midX, y: actionRect.midY)
        
        let containerWidth = container.frame.size.width
        let containerHeight = container.frame.size.height
        
        var endCenter = CGPoint.zero
        
        if actionCenter.x < containerWidth * 0.5 {
            endCenter = actionCenter.y < containerHeight * 0.5 ? CGPoint(x: containerWidth, y: containerHeight) : CGPoint(x: containerWidth, y: 0)
        } else {
            endCenter = actionCenter.y < containerHeight * 0.5 ? CGPoint(x: 0, y: containerHeight) : CGPoint(x: 0, y: 0)
        }
        
        let finalRectHalfDistance = max(fabs(endCenter.x - actionCenter.x), fabs(endCenter.y - actionCenter.y))
        let finalRect = CGRect(x: actionCenter.x - finalRectHalfDistance, y: actionCenter.y - finalRectHalfDistance, width: finalRectHalfDistance * 2.0, height: finalRectHalfDistance * 2.0)
        
        startPath = UIBezierPath(ovalIn: actionRect)
        endPath = UIBezierPath(ovalIn: finalRect)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = endPath?.cgPath
        
        let viewToBePresent = (context.view(forKey: .to) ?? vcToBePresent.view)!
    
        viewToBePresent.layer.mask = maskLayer
        
        CATransaction.begin()
        CATransaction.setValue(duration, forKey: kCATransactionAnimationDuration)
        CATransaction.setValue(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), forKey: kCATransactionAnimationTimingFunction)
        CATransaction.setCompletionBlock {
            viewToBePresent.layer.mask = nil
            context.completeTransition(!context.transitionWasCancelled)
        }
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = startPath?.cgPath
        pathAnimation.toValue = endPath?.cgPath
        maskLayer.add(pathAnimation, forKey: RingAnimKey)
        
        CATransaction.commit()
    }
    
    override func dismiss(_ vcToBeDismissed: UIViewController, toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        
        super.dismiss(vcToBeDismissed, toVC: toVC, container: container, context: context)
        
        if startPath == nil || endPath == nil {
            context.completeTransition(true)
            return
        }
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = endPath?.cgPath
        
        let viewToBeDismissed = (context.view(forKey: .from) ?? vcToBeDismissed.view)!
        
        viewToBeDismissed.layer.mask = maskLayer
        
        CATransaction.begin()
        CATransaction.setValue(duration, forKey: kCATransactionAnimationDuration)
        CATransaction.setValue(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), forKey: kCATransactionAnimationTimingFunction)
        CATransaction.setCompletionBlock {
            viewToBeDismissed.layer.mask = nil
            context.completeTransition(!context.transitionWasCancelled)
            maskLayer.removeAnimation(forKey: RingAnimInvertKey)
        }
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = endPath?.cgPath
        pathAnimation.toValue = startPath?.cgPath
        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.fillMode = kCAFillModeForwards
        maskLayer.add(pathAnimation, forKey: RingAnimInvertKey)
    
        CATransaction.commit()
    }
    
    private var startPath: UIBezierPath?
    private var endPath: UIBezierPath?
    
    override var useBaseAnimation: Bool {
        return true
    }
}

private let RingAnimKey = "ringAnimation"
private let RingAnimInvertKey = "ringInvertAnimation"
