//
// SystemTransition.swift
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

public enum SystemTransitionStyle {
    
    case translate(factor: CGFloat)
    
    case zoom(factor: CGFloat)
    
    case translateAndZoom(translateFactor: CGFloat, zoomFactor: CGFloat)
    
    func transform(forView: UIView, axis: UILayoutConstraintAxis) -> CGAffineTransform {
        switch self {
        case .translate(let factor):
            if axis == .vertical {
                return CGAffineTransform(translationX: 0, y: forView.frame.size.height * factor)
            } else {
                return CGAffineTransform(translationX: forView.frame.size.width * factor, y: 0)
            }
        case .zoom(let factor):
            return CGAffineTransform(scaleX: factor, y: factor)
        case .translateAndZoom(let translateFactor, let zoomFactor):
            if axis == .vertical {
                return CGAffineTransform(scaleX: zoomFactor, y: zoomFactor).translatedBy(x: 0, y: forView.frame.size.height * translateFactor)
            } else {
                return CGAffineTransform(scaleX: zoomFactor, y: zoomFactor).translatedBy(x: forView.frame.size.width * translateFactor, y: 0)
            }
        }
    }
}

open class SystemTransition: Transition {
    
    public required init(axis: UILayoutConstraintAxis, style: SystemTransitionStyle) {
        self.axis = axis
        self.style = style
        super.init()
    }
    
    override func present(_ vcToBePresent: UIViewController, fromVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        
        super.present(vcToBePresent, fromVC: fromVC, container: container, context: context)
        
        let viewToBePresent = (context.view(forKey: .to) ?? vcToBePresent.view)!
        let fromView = (context.view(forKey: .from) ?? fromVC.view)!
        
        if axis == .vertical {
            viewToBePresent.transform = CGAffineTransform(translationX: 0, y: viewToBePresent.frame.size.height)
        } else {
            viewToBePresent.transform = CGAffineTransform(translationX: viewToBePresent.frame.size.width, y: 0)
        }
        
        UIView.animate(withDuration: duration, animations: {
            viewToBePresent.transform = .identity
            fromView.transform = self.style.transform(forView: fromView, axis: self.axis)
            self.applyShadow(forView: viewToBePresent)
        }) { (complete) in
            if context.transitionWasCancelled {
                viewToBePresent.removeFromSuperview()
            }
            
            viewToBePresent.transform = .identity
            fromView.transform = .identity
            
            self.removeShadow(forView: viewToBePresent)
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
    
    override func dismiss(_ vcToBeDismissed: UIViewController, toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        
        super.dismiss(vcToBeDismissed, toVC: toVC, container: container, context: context)
        
        let viewToBeDismissed = (context.view(forKey: .from) ?? vcToBeDismissed.view)!
        let toView = (context.view(forKey: .to) ?? toVC.view)!
        toView.transform = style.transform(forView: toView, axis: axis)
        applyShadow(forView: viewToBeDismissed)
                
        UIView.animate(withDuration: duration, animations: {
            toView.transform = .identity
            if self.axis == .vertical {
                viewToBeDismissed.transform = CGAffineTransform(translationX: 0, y: viewToBeDismissed.frame.size.height)
            } else {
                viewToBeDismissed.transform = CGAffineTransform(translationX: viewToBeDismissed.frame.size.width, y: 0)
            }
        }) { (complete) in
            toView.transform = .identity
            if context.transitionWasCancelled {
                toView.removeFromSuperview()
            }
            self.removeShadow(forView: viewToBeDismissed)
            viewToBeDismissed.transform = .identity
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
    
    private func applyShadow(forView: UIView) {
        forView.layer.shadowColor = UIColor.black.cgColor
        forView.layer.shadowRadius = 10.0
        forView.layer.shadowOpacity = 0.5
        forView.layer.shadowOffset = CGSize(width: 0, height: 0)
        forView.layer.shadowPath = UIBezierPath(rect: forView.bounds).cgPath
    }
    
    private func removeShadow(forView: UIView) {
        forView.layer.shadowColor = nil
        forView.layer.shadowRadius = 0.0
        forView.layer.shadowOpacity = 0
        forView.layer.shadowPath = nil
    }
    
    private var axis : UILayoutConstraintAxis
    
    private var style: SystemTransitionStyle
    
}
