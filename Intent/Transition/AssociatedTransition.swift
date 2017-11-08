//
//  AssociatedTransition.swift
//  OTSKit
//
//  Created by Jerry on 2017/6/7.
//  Copyright © 2017年 Yihaodian. All rights reserved.
//

import UIKit

@objc public protocol AssociatedTransitionDataSource : NSObjectProtocol {
    
    @objc optional func viewsForTransition() -> [UIView]?
    @objc optional func fixedDestFrames(withRefrence: [UIView]?) -> [CGRect]?
    
}

open class AssociatedTransition: Transition {
    
    override func present(_ vcToBePresent: UIViewController, fromVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        
        super.present(vcToBePresent, fromVC: fromVC, container: container, context: context)
        
        let viewToBePresent = (context.view(forKey: .to) ?? vcToBePresent.view)!
        
        viewToBePresent.alpha = 0
        viewToBePresent.layoutIfNeeded()
        
        var fromViews: [UIView]? = nil
        var toViews: [UIView]? = nil
        var fixedFrames: [CGRect]? = nil
        
        self.calculate(fromViews: &fromViews, toViews: &toViews, fixedFrames: &fixedFrames, isPresent: true)
        var snapshotViewArray = [UIView]()
        
        for aView in toViews! {
            aView.isHidden = true
        }
        
        for i in 0..<fromViews!.count {
            let aView = fromViews![i]
            let snapshotView = self.createSnapshotView(referenceView: aView, referenceFrame: .zero, containerView: container)
            snapshotViewArray.append(snapshotView)
            container.addSubview(snapshotView)
        }
        
        var fixedFramesCount = fixedFrames?.count
        if fixedFramesCount == nil {
            fixedFramesCount = 0
        }
        
        UIView.animate(withDuration: self.duration, animations: {
            viewToBePresent.alpha = 1.0
            for i in 0..<snapshotViewArray.count {
                let snapShotView = snapshotViewArray[i]
                let desView = toViews![i]
                var desRect = CGRect.zero
                if fixedFramesCount! > i {
                    desRect = desView.superview!.convert(fixedFrames![i], to: container)
                } else {
                    desRect = desView.superview!.convert(desView.frame, to: container)
                }
                snapShotView.frame = desRect
            }

        }) { (finished) in
            viewToBePresent.alpha = 1.0
            for snapshotView in snapshotViewArray {
                snapshotView.removeFromSuperview()
            }
            
            for aView in toViews! {
                aView.isHidden = false
            }
            
            for aView in fromViews! {
                aView.isHidden = false
            }
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
    
    override func dismiss(_ vcToBeDismissed: UIViewController, toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        
        super.dismiss(vcToBeDismissed, toVC: toVC, container: container, context: context)
        
        let viewToBeDismissed = (context.view(forKey: .from) ?? vcToBeDismissed.view)!
        
        var fromViews: [UIView]? = nil
        var toViews: [UIView]? = nil
        var fixedFrames: [CGRect]? = nil
        
        self.calculate(fromViews: &fromViews, toViews: &toViews, fixedFrames: &fixedFrames, isPresent: false)
        var snapshotViewArray = [UIView]()
        
        for aView in fromViews! {
            aView.isHidden = true
        }
        
        for i in 0..<toViews!.count {
            let aView = toViews![i]
            let snapshotView = self.createSnapshotView(referenceView: aView, referenceFrame: .zero, containerView: container)
            snapshotViewArray.append(snapshotView)
            container.addSubview(snapshotView)
        }
        
        UIView.animate(withDuration: self.duration, animations: {
            viewToBeDismissed.alpha = 0
            for i in 0..<snapshotViewArray.count {
                let snapShotView = snapshotViewArray[i]
                let desView = fromViews![i]
                snapShotView.frame = desView.superview!.convert(desView.frame, to: container)
            }
            
        }) { (finished) in
            viewToBeDismissed.alpha = 1.0            
            for snapshotView in snapshotViewArray {
                snapshotView.removeFromSuperview()
            }
            
            for aView in toViews! {
                aView.isHidden = false
            }
            
            for aView in fromViews! {
                aView.isHidden = false
            }
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
    
    private func calculate(fromViews: inout [UIView]?, toViews: inout [UIView]?, fixedFrames: inout [CGRect]?, isPresent: Bool) {
        var mFromViews = (self.fromVC as? AssociatedTransitionDataSource)?.viewsForTransition?()
        var mToViews = (self.toVC as? AssociatedTransitionDataSource)?.viewsForTransition?()
        
        guard mFromViews != nil && mToViews != nil else {
            return
        }
        
        if mFromViews!.count < mToViews!.count {
            mToViews = (mToViews! as NSArray).subarray(with: NSMakeRange(0, mFromViews!.count)) as? [UIView]
        } else if mFromViews!.count > mToViews!.count {
            mFromViews = (mFromViews! as NSArray).subarray(with: NSMakeRange(0, mToViews!.count)) as? [UIView]
        }
        
        fromViews = mFromViews
        toViews = mToViews
        
        let fixedFramesOwner = (isPresent ? self.toVC : self.fromVC) as? AssociatedTransitionDataSource
        fixedFrames = fixedFramesOwner?.fixedDestFrames?(withRefrence: (isPresent ? mFromViews : mToViews))
    }
    
    private func createSnapshotView(referenceView: UIView, referenceFrame: CGRect, containerView: UIView) -> UIView {
        var snapshotView: UIView? = nil
        if !referenceFrame.equalTo(CGRect.zero) {
            var offsetX: CGFloat = 0
            var offsetY: CGFloat = 0
            let scrollView = referenceView as? UIScrollView
            if scrollView != nil {
                offsetX = scrollView!.contentOffset.x
                offsetY = scrollView!.contentOffset.y
            }
            
            snapshotView = referenceView.resizableSnapshotView(from: CGRect.init(x: (referenceView.frame.size.width - referenceFrame.size.width) * 0.5 + offsetX, y: (referenceView.frame.size.height - referenceFrame.size.height) * 0.5 + offsetY, width: referenceFrame.size.width, height: referenceFrame.size.height), afterScreenUpdates: false, withCapInsets: UIEdgeInsets.zero)
            snapshotView!.frame = referenceView.superview!.convert(referenceFrame, to: containerView)
        } else {
            snapshotView = referenceView.snapshotView(afterScreenUpdates: false)
            snapshotView!.frame = referenceView.superview!.convert(referenceView.frame, to: containerView)
        }
        
        referenceView.isHidden = true
        return snapshotView!
    }
}