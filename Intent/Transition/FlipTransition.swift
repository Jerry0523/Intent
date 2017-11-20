//
// FlipTransition.swift
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

open class FlipTransition: Transition {
    
    override open var duration: Double {
        get {
            return AppearDuration + FlipDuration
        }
        
        set {
            self.duration = newValue
        }
    }
    
    override var useBaseAnimation: Bool {
        return true
    }
    
    override func present(_ vcToBePresent: UIViewController, fromVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        
        super.present(vcToBePresent, fromVC: fromVC, container: container, context: context)
        let viewToBePresent = (context.view(forKey: .to) ?? vcToBePresent.view)!
        viewToBePresent.removeFromSuperview()
        let contentImg = self.updateContentSnapshot(forView: viewToBePresent)
        let transformView = FlipTransformView.init(frame: container.bounds)
        let shadowView = UIView.init(frame: container.bounds)
        shadowView.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        shadowView.layer.opacity = 0.0;
        
        transformView.prepare(true) {
            
            container.addSubview(shadowView)
            container.addSubview(transformView)
            
            transformView.upperBackLayer.contents = contentImg?.cgImage
            transformView.lowerLayer.contents = contentImg?.cgImage
            
            transformView.appear(true, meanwhile: {
                let shadowAnimation = CABasicAnimation.init(keyPath: "opacity")
                shadowAnimation.fromValue = 0
                shadowAnimation.toValue = 0.4
                shadowView.layer.add(shadowAnimation, forKey: nil)
                shadowView.layer.opacity = 0.4
            }, complete: {
                transformView.open(true, meanwhile: {
                    let shadowAnimation = CABasicAnimation.init(keyPath: "opacity")
                    shadowAnimation.fromValue = 0.4
                    shadowAnimation.toValue = 0.7
                    shadowView.layer.add(shadowAnimation, forKey: nil)
                    shadowView.layer.opacity = 0.7
                }, complete: {
                    transformView.upperFrontLayer.opacity = 0
                    transformView.upperBackLayer.opacity = 1.0
                    transformView.flip(true, meanwhile: {
                        let shadowAnimation = CABasicAnimation.init(keyPath: "opacity")
                        shadowAnimation.fromValue = 0.7
                        shadowAnimation.toValue = 1.0
                        shadowView.layer.add(shadowAnimation, forKey: nil)
                        shadowView.layer.opacity = 1.0
                    }, complete: {
                        transformView.removeFromSuperview()
                        shadowView.removeFromSuperview()
                        let cancelled = context.transitionWasCancelled
                        if !cancelled {
                            container.addSubview(viewToBePresent)
                        }
                        context.completeTransition(!cancelled)
                    })
                })
            })
        }
    }
    
    override func dismiss(_ vcToBeDismissed: UIViewController, toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        
        super.dismiss(vcToBeDismissed, toVC: toVC, container: container, context: context)
        
        let viewToBeDismissed = (context.view(forKey: .from) ?? vcToBeDismissed.view)!
        let contentImg = self.updateContentSnapshot(forView: viewToBeDismissed)
        
        viewToBeDismissed.alpha = 0
        
        let transformView = FlipTransformView.init(frame: container.bounds)
        let shadowView = UIView.init(frame: container.bounds)
        shadowView.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        
        container.addSubview(shadowView)
        container.addSubview(transformView)

        transformView.upperBackLayer.contents = contentImg?.cgImage
        transformView.lowerLayer.contents = contentImg?.cgImage
        transformView.prepare(false) {
            transformView.flip(false, meanwhile: {
                let shadowAnimation = CABasicAnimation.init(keyPath: "opacity")
                shadowAnimation.fromValue = 1.0
                shadowAnimation.toValue = 0.7
                shadowAnimation.isRemovedOnCompletion = false
                shadowAnimation.fillMode = kCAFillModeForwards
                shadowView.layer.add(shadowAnimation, forKey: nil)
                shadowView.layer.opacity = 0.7
            }, complete: {
                transformView.upperBackLayer.opacity = 0.0
                transformView.upperFrontLayer.opacity = 1.0
                transformView.open(false, meanwhile: {
                    let shadowAnimation = CABasicAnimation.init(keyPath: "opacity")
                    shadowAnimation.fromValue = 0.7
                    shadowAnimation.toValue = 0.4
                    shadowAnimation.isRemovedOnCompletion = false
                    shadowAnimation.fillMode = kCAFillModeForwards
                    shadowView.layer.add(shadowAnimation, forKey: nil)
                    shadowView.layer.opacity = 0.4
                }, complete: {
                    transformView.appear(false, meanwhile: {
                        let shadowAnimation = CABasicAnimation.init(keyPath: "opacity")
                        shadowAnimation.fromValue = 0.4
                        shadowAnimation.toValue = 0
                        shadowAnimation.isRemovedOnCompletion = false
                        shadowAnimation.fillMode = kCAFillModeForwards
                        shadowView.layer.add(shadowAnimation, forKey: nil)
                        shadowView.layer.opacity = 0
                    }, complete: {
                        transformView.removeFromSuperview()
                        shadowView.removeFromSuperview()
                        let cancelled = context.transitionWasCancelled
                        if cancelled {
                            viewToBeDismissed.alpha = 1.0
                        } else {
                            viewToBeDismissed.removeFromSuperview()
                        }
                        context.completeTransition(!cancelled)
                    })
                })
            })
        }
    }
    
    private func updateContentSnapshot(forView view: UIView) -> UIImage? {
        if view.bounds.size == CGSize.zero {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        defer {
            UIGraphicsEndImageContext()
        }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private enum GradientShadowLayerPosition {
        
        case top
        case bottom
        
        func colors() -> [Any]? {
            switch self {
            case .top:
                return [UIColor.init(white: 0, alpha: 0.4).cgColor, UIColor.clear.cgColor]
            case .bottom:
                return [UIColor.clear.cgColor, UIColor.init(white: 0, alpha: 0.4).cgColor]
            }
        }
        
        func shadowYOffset() -> CGFloat {
            switch self {
            case .top:
                return 1
            case .bottom:
                return -1
            }
        }
    }
    
    private class FlipTransformView : UIView {
        
        let transformLayer = CATransformLayer.init()
        let lowerLayer = GradientShadowLayer.init(shadowPosition: .top)
        let upperFrontLayer = CALayer.init()
        let upperBackLayer = GradientShadowLayer.init(shadowPosition: .bottom)
        
        override init(frame: CGRect) {
            super.init(frame: frame)
                
            self.layer.addSublayer(transformLayer)
            
            let backgroundColor = UIColor.init(white: 0.9, alpha: 1.0).cgColor
            
            lowerLayer.backgroundColor = backgroundColor
            lowerLayer.contentsRect = CGRect.init(x: 0, y: 0.5, width: 1, height: 0.5)
            lowerLayer.isDoubleSided = false
            transformLayer.addSublayer(lowerLayer)
            
            upperFrontLayer.backgroundColor = backgroundColor
            upperFrontLayer.anchorPoint = CGPoint.init(x: 0.5, y: 0)
            upperFrontLayer.contentsRect = CGRect.init(x: 0, y: 0.5, width: 1, height: 0.5)
            upperFrontLayer.isDoubleSided = false
            transformLayer.addSublayer(upperFrontLayer)
            
            upperBackLayer.backgroundColor = backgroundColor
            upperBackLayer.anchorPoint = CGPoint.init(x: 0.5, y: 1.0)
            upperBackLayer.contentsRect = CGRect.init(x: 0, y: 0, width: 1, height: 0.5)
            upperBackLayer.isDoubleSided = false
            transformLayer.addSublayer(upperBackLayer)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            self.transformLayer.frame = self.bounds
            var sublayerTransform = self.transformLayer.sublayerTransform
            sublayerTransform.m34 = -1.0 / (self.bounds.size.height * 4.7 * 0.5);
            self.transformLayer.sublayerTransform = sublayerTransform;
            
            let upperRect = CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height / 2.0)
            let lowerRect = CGRect.init(x: 0, y: upperRect.size.height, width: upperRect.size.width, height: upperRect.size.height)
            
            lowerLayer.frame = lowerRect
            upperFrontLayer.frame = lowerRect
            self.upperBackLayer.frame = upperRect
        }
        
        func prepare(_ isPresent: Bool, complete: (() -> ())?) {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            CATransaction.setCompletionBlock(complete)
            
            if isPresent {
                upperFrontLayer.transform = CATransform3DIdentity
                upperBackLayer.transform = CATransform3DMakeRotation(-.pi / 2.0, 1.0, 0.0, 0.0)
                upperBackLayer.shadowCover.opacity = 0.5
                lowerLayer.transform = CATransform3DIdentity
                lowerLayer.shadowCover.opacity = 1.0
                
                var transform = self.layer.transform
                transform = CATransform3DScale(transform, ScaleFactor, ScaleFactor, 1.0)
                transform = CATransform3DTranslate(transform, 0, UIScreen.main.bounds.size.height, 0)
                
                self.layer.transform = transform
            } else {
                upperFrontLayer.transform = CATransform3DMakeRotation(.pi / 2.0, 1.0, 0.0, 0.0)
                upperBackLayer.transform = CATransform3DIdentity
                upperBackLayer.shadowCover.opacity = 0.0
                lowerLayer.transform = CATransform3DIdentity
                lowerLayer.shadowCover.opacity = 0.0
                self.layer.transform = CATransform3DIdentity
            }
            
            CATransaction.commit()
        }
        
        func appear(_ isPresent: Bool, meanwhile:(() -> ())?, complete: (() -> ())?) {
            CATransaction.begin()
            CATransaction.setValue(AppearDuration, forKey: kCATransactionAnimationDuration)
            CATransaction.setValue(CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut), forKey: kCATransactionAnimationTimingFunction)
            CATransaction.setCompletionBlock(complete)
            
            var transform = self.layer.transform
            transform = CATransform3DTranslate(transform, 0, (UIScreen.main.bounds.size.height + AppearExtraDistance) * (isPresent ? -1 : 1) , 0);
            let easeInAnimation = CABasicAnimation.init(keyPath: "transform.translation.y")
            easeInAnimation.fromValue = isPresent ? UIScreen.main.bounds.size.height : -AppearExtraDistance
            easeInAnimation.toValue = isPresent ? -AppearExtraDistance : UIScreen.main.bounds.size.height
            self.layer.add(easeInAnimation, forKey: nil)
            self.layer.transform = transform
            
            meanwhile?()
            CATransaction.commit()
        }
        
        func open(_ isPresent: Bool, meanwhile:(() -> ())?, complete: (() -> ())?) {
            CATransaction.begin()
            CATransaction.setValue(FlipDuration / 2.0, forKey: kCATransactionAnimationDuration)
            CATransaction.setValue(CAMediaTimingFunction.init(name: isPresent ? kCAMediaTimingFunctionEaseIn : kCAMediaTimingFunctionEaseOut), forKey: kCATransactionAnimationTimingFunction)
            CATransaction.setCompletionBlock(complete)
            
            let rotateAnimation = CABasicAnimation.init(keyPath: "transform.rotation.x")
            rotateAnimation.fromValue = isPresent ? 0 : .pi / 2.0
            rotateAnimation.toValue = isPresent ? .pi / 2.0 : 0
            upperFrontLayer.add(rotateAnimation, forKey: nil)
            upperFrontLayer.transform = CATransform3DRotate(upperFrontLayer.transform, .pi * 0.5 * (isPresent ? 1 : -1), 1.0, 0, 0);
            
            let opacityLowerAnimation = CABasicAnimation.init(keyPath: "opacity")
            opacityLowerAnimation.fromValue = isPresent ? 1 : 0.5
            opacityLowerAnimation.toValue = isPresent ? 0.5 : 1.0
            lowerLayer.shadowCover.add(opacityLowerAnimation, forKey: nil)
            lowerLayer.shadowCover.opacity = isPresent ? 0.5 : 1.0
            
            meanwhile?()
            CATransaction.commit()
        }
        
        func flip(_ isPresent: Bool, meanwhile:(() -> ())?, complete: (() -> ())?) {
            CATransaction.begin()
            CATransaction.setValue(FlipDuration / 2.0, forKey: kCATransactionAnimationDuration)
            CATransaction.setValue(CAMediaTimingFunction.init(name: isPresent ? kCAMediaTimingFunctionEaseOut : kCAMediaTimingFunctionEaseIn), forKey: kCATransactionAnimationTimingFunction)
            CATransaction.setCompletionBlock(complete)
            
            var transform = self.layer.transform
            
            if isPresent {
                transform = CATransform3DTranslate(transform, 0, AppearExtraDistance, 0);
                transform = CATransform3DScale(transform, 1.0 / ScaleFactor, 1.0 / ScaleFactor, 1.0);
            } else {
                transform = CATransform3DTranslate(transform, 0, -AppearExtraDistance, 0);
                transform = CATransform3DScale(transform, ScaleFactor, ScaleFactor, 1.0);
            }
            
            let transformLayerAnimation = CABasicAnimation.init(keyPath: "transform")
            transformLayerAnimation.fromValue = self.layer.transform
            transformLayerAnimation.toValue = transform
            self.layer.add(transformLayerAnimation, forKey: nil)
            self.layer.transform = transform
            
            let animation = CABasicAnimation.init(keyPath: "transform.rotation.x")
            animation.fromValue = isPresent ? -.pi / 2.0 : 0
            animation.toValue = isPresent ? 0 : -.pi / 2.0
            upperBackLayer.add(animation, forKey: nil)
            upperBackLayer.transform = CATransform3DRotate(upperBackLayer.transform, .pi / 2.0 * (isPresent ? 1 : -1), 1.0, 0, 0);
            
            let opacityAnimation = CABasicAnimation.init(keyPath: "opacity")
            opacityAnimation.fromValue = isPresent ? 0.5 : 0.0
            opacityAnimation.toValue = isPresent ? 0.0 : 0.5
            upperBackLayer.shadowCover.add(opacityAnimation, forKey: nil)
            lowerLayer.shadowCover.add(opacityAnimation, forKey: nil)
            
            upperBackLayer.shadowCover.opacity = isPresent ? 0.0 : 0.5
            lowerLayer.shadowCover.opacity = isPresent ? 0.0 : 0.5
            
            meanwhile?()
            CATransaction.commit()
        }
        
    }
    
    private class GradientShadowLayer : CALayer {
        
        let shadowCover = CAGradientLayer.init()
        var shadowPosition = GradientShadowLayerPosition.top
        
        init(shadowPosition: GradientShadowLayerPosition) {
            super.init()
            self.shadowPosition = shadowPosition
            self.setup()
        }
        
        override init(layer: Any) {
            super.init(layer: layer)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup() {
            shadowCover.colors = shadowPosition.colors()
            self.addSublayer(shadowCover)
            
            self.shadowColor = UIColor.init(white: 0, alpha: 0.6).cgColor
            self.shadowOffset = CGSize.init(width: 0, height: shadowPosition.shadowYOffset())
            self.shadowRadius = 2.0
            self.shadowOpacity = 0.8
        }
        
        override func layoutSublayers() {
            super.layoutSublayers()
            self.shadowCover.frame = self.bounds
            self.shadowPath = UIBezierPath.init(rect: self.bounds).cgPath
        }
    }
}

private let ScaleFactor = CGFloat(0.875)
private let AppearExtraDistance = CGFloat(40.0)
private let AppearDuration = 0.4 * 1.0
private let FlipDuration = 0.8 * 1.0

