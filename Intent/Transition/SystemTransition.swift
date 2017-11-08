//
//  SystemTransition.swift
//  OTSKit
//
//  Created by Jerry on 2017/6/8.
//  Copyright © 2017年 Yihaodian. All rights reserved.
//

import UIKit

public enum SystemTransitionStyle {
    
    case translate(factor: CGFloat)
    
    case zoom(factor: CGFloat)
    
    case translateAndZoom(translateFactor: CGFloat, zoomFactor: CGFloat)
    
    func transform(forView: UIView, axis: UILayoutConstraintAxis) -> CGAffineTransform {
        switch self {
        case .translate(let factor):
            if axis == .vertical {
                return CGAffineTransform.init(translationX: 0, y: forView.frame.size.height * factor)
            } else {
                return CGAffineTransform.init(translationX: forView.frame.size.width * factor, y: 0)
            }
        case .zoom(let factor):
            return CGAffineTransform.init(scaleX: factor, y: factor)
        case .translateAndZoom(let translateFactor, let zoomFactor):
            if axis == .vertical {
                return CGAffineTransform.init(scaleX: zoomFactor, y: zoomFactor).translatedBy(x: 0, y: forView.frame.size.height * translateFactor)
            } else {
                return CGAffineTransform.init(scaleX: zoomFactor, y: zoomFactor).translatedBy(x: forView.frame.size.width * translateFactor, y: 0)
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
        
        self.applyShadow(forView: viewToBePresent)
        
        if self.axis == .vertical {
            viewToBePresent.transform = CGAffineTransform.init(translationX: 0, y: viewToBePresent.frame.size.height)
        } else {
            viewToBePresent.transform = CGAffineTransform.init(translationX: viewToBePresent.frame.size.width, y: 0)
        }
        
        UIView.animate(withDuration: self.duration, animations: {
            viewToBePresent.transform = .identity
            fromView.transform = self.style.transform(forView: fromView, axis: self.axis)
            self.applyShadow(forView: fromView)
            self.removeShadow(forView: viewToBePresent)
        }) { (complete) in
            if context.transitionWasCancelled {
                viewToBePresent.removeFromSuperview()
            }
            
            viewToBePresent.transform = .identity
            fromView.transform = .identity
            
            self.removeShadow(forView: viewToBePresent)
            self.removeShadow(forView: fromView)
            
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
    
    override func dismiss(_ vcToBeDismissed: UIViewController, toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        
        super.dismiss(vcToBeDismissed, toVC: toVC, container: container, context: context)
        
        let viewToBeDismissed = (context.view(forKey: .from) ?? vcToBeDismissed.view)!
        let toView = (context.view(forKey: .to) ?? toVC.view)!
        toView.transform = self.style.transform(forView: toView, axis: self.axis)
        self.applyShadow(forView: toView)
        
        UIView.animate(withDuration: self.duration, animations: {
            toView.transform = .identity
            if self.axis == .vertical {
                viewToBeDismissed.transform = CGAffineTransform.init(translationX: 0, y: viewToBeDismissed.frame.size.height)
            } else {
                viewToBeDismissed.transform = CGAffineTransform.init(translationX: viewToBeDismissed.frame.size.width, y: 0)
            }
            
            self.applyShadow(forView: viewToBeDismissed)
            self.removeShadow(forView: toView)
        }) { (complete) in
            toView.transform = .identity
            if context.transitionWasCancelled {
                toView.removeFromSuperview()
            }
            self.removeShadow(forView: toView)
            self.removeShadow(forView: viewToBeDismissed)
            viewToBeDismissed.transform = .identity
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
    
    private func applyShadow(forView: UIView) {
        forView.layer.shadowColor = UIColor.black.cgColor
        forView.layer.shadowRadius = 20.0
        forView.layer.shadowOpacity = 0.3
        forView.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        forView.layer.shadowPath = UIBezierPath.init(rect: forView.bounds).cgPath
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
