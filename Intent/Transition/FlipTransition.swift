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
    
    override public var preferredDuration: CFTimeInterval {
        return 1.2
    }
    
    override var useBaseAnimation: Bool {
        return true
    }
    
    override func present(_ vcToBePresent: UIViewController, fromVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        
        super.present(vcToBePresent, fromVC: fromVC, container: container, context: context)
        let viewToBePresent = (context.view(forKey: .to) ?? vcToBePresent.view)!
        viewToBePresent.removeFromSuperview()
        let contentImg = updateContentSnapshot(forView: viewToBePresent)
        let transformView = FlipTransformView(frame: container.bounds)
        transformView.duration = duration
        let shadowView = UIView(frame: container.bounds)
        shadowView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        shadowView.layer.opacity = 0.0;
        
        func cleanup() {
            transformView.removeFromSuperview()
            shadowView.removeFromSuperview()
            let cancelled = context.transitionWasCancelled
            if !cancelled {
                container.addSubview(viewToBePresent)
            }
            context.completeTransition(!cancelled)
        }
        
        transformView.prepare(isPresent: true)
        
        container.addSubview(shadowView)
        container.addSubview(transformView)
        
        transformView.upperBackLayer.contents = contentImg?.cgImage
        transformView.lowerLayer.contents = contentImg?.cgImage
        
        transformView.move(isPresent: true, next: {
            transformView.open(isPresent: true, next: {
                transformView.flip(isPresent: true, next: {
                    cleanup()
                })
                
                let shadowAnimation = CABasicAnimation(keyPath: "opacity")
                shadowAnimation.fromValue = 0.7
                shadowAnimation.toValue = 1.0
                shadowView.layer.add(shadowAnimation, forKey: MaskDimAnimKey)
                shadowView.layer.opacity = 1.0
            })
            
            let shadowAnimation = CABasicAnimation(keyPath: "opacity")
            shadowAnimation.fromValue = 0.4
            shadowAnimation.toValue = 0.7
            shadowView.layer.add(shadowAnimation, forKey: MaskDimAnimKey)
            shadowView.layer.opacity = 0.7
        })
        
        let shadowAnimation = CABasicAnimation(keyPath: "opacity")
        shadowAnimation.fromValue = 0
        shadowAnimation.toValue = 0.4
        shadowView.layer.add(shadowAnimation, forKey: MaskDimAnimKey)
        shadowView.layer.opacity = 0.4
    }
    
    override func dismiss(_ vcToBeDismissed: UIViewController, toVC: UIViewController, container: UIView, context: UIViewControllerContextTransitioning) {
        
        super.dismiss(vcToBeDismissed, toVC: toVC, container: container, context: context)
        
        let viewToBeDismissed = (context.view(forKey: .from) ?? vcToBeDismissed.view)!
        let contentImg = updateContentSnapshot(forView: viewToBeDismissed)
        
        viewToBeDismissed.alpha = 0
        
        let transformView = FlipTransformView(frame: container.bounds)
        transformView.duration = duration
        let shadowView = UIView(frame: container.bounds)
        shadowView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        
        container.addSubview(shadowView)
        container.addSubview(transformView)
        
        func cleanup() {
            transformView.removeFromSuperview()
            shadowView.removeFromSuperview()
            let cancelled = context.transitionWasCancelled
            if cancelled {
                viewToBeDismissed.alpha = 1.0
            } else {
                viewToBeDismissed.removeFromSuperview()
            }
            context.completeTransition(!cancelled)
        }

        transformView.upperBackLayer.contents = contentImg?.cgImage
        transformView.lowerLayer.contents = contentImg?.cgImage
        transformView.prepare(isPresent: false)
        
        print("flipping", Date())
        transformView.flip(isPresent: false, next: {
            if context.transitionWasCancelled {
                cleanup()
            } else {
                print("opening", Date())
                transformView.open(isPresent: false, next: {
                    if context.transitionWasCancelled {
                        cleanup()
                    } else {
                        print("moving", Date())
                        transformView.move(isPresent: false, next: {
                            cleanup()
                        })
                        
                        let shadowAnimation = CABasicAnimation(keyPath: "opacity")
                        shadowAnimation.fromValue = 0.4
                        shadowAnimation.toValue = 0
                        shadowView.layer.add(shadowAnimation, forKey: MaskDimAnimKey)
                        shadowView.layer.opacity = 0
                    }
                })
                
                let shadowAnimation = CABasicAnimation(keyPath: "opacity")
                shadowAnimation.fromValue = 0.7
                shadowAnimation.toValue = 0.4
                shadowView.layer.add(shadowAnimation, forKey: MaskDimAnimKey)
                shadowView.layer.opacity = 0.4
            }
        })
        
        let shadowAnimation = CABasicAnimation(keyPath: "opacity")
        shadowAnimation.fromValue = 1.0
        shadowAnimation.toValue = 0.7
        shadowView.layer.add(shadowAnimation, forKey: MaskDimAnimKey)
        shadowView.layer.opacity = 0.7
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
    
    enum GradientShadowLayerPosition {
        
        case top
        case bottom
        
        func colors() -> [Any]? {
            switch self {
            case .top:
                return [UIColor(white: 0, alpha: 0.4).cgColor, UIColor.clear.cgColor]
            case .bottom:
                return [UIColor.clear.cgColor, UIColor(white: 0, alpha: 0.4).cgColor]
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
    
    class FlipTransformView : UIView {
        
        let transformLayer = CATransformLayer()
        
        let lowerLayer = GradientShadowLayer(shadowPosition: .top)
        
        let upperFrontLayer = CALayer()
        
        let upperBackLayer = GradientShadowLayer(shadowPosition: .bottom)
        
        var duration: CFTimeInterval = 0
        
        var nextOperation: (() -> ())?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
                
            layer.addSublayer(transformLayer)
            
            let backgroundColor = UIColor(white: 0.9, alpha: 1.0).cgColor
            
            lowerLayer.backgroundColor = backgroundColor
            lowerLayer.contentsRect = CGRect(x: 0, y: 0.5, width: 1, height: 0.5)
            lowerLayer.isDoubleSided = false
            transformLayer.addSublayer(lowerLayer)
            
            upperFrontLayer.backgroundColor = backgroundColor
            upperFrontLayer.anchorPoint = CGPoint(x: 0.5, y: 0)
            upperFrontLayer.contentsRect = CGRect(x: 0, y: 0.5, width: 1, height: 0.5)
            upperFrontLayer.isDoubleSided = false
            transformLayer.addSublayer(upperFrontLayer)
            
            upperBackLayer.backgroundColor = backgroundColor
            upperBackLayer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
            upperBackLayer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 0.5)
            upperBackLayer.isDoubleSided = false
            transformLayer.addSublayer(upperBackLayer)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            transformLayer.frame = bounds
            var sublayerTransform = transformLayer.sublayerTransform
            sublayerTransform.m34 = -1.0 / (bounds.size.height * 4.7 * 0.5)
            transformLayer.sublayerTransform = sublayerTransform;
            
            let upperRect = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height / 2.0)
            let lowerRect = CGRect(x: 0, y: upperRect.size.height, width: upperRect.size.width, height: upperRect.size.height)
            
            lowerLayer.frame = lowerRect
            upperFrontLayer.frame = lowerRect
            upperBackLayer.frame = upperRect
        }
        
        func prepare(isPresent: Bool) {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            if isPresent {
                upperFrontLayer.transform = CATransform3DIdentity
                upperBackLayer.transform = CATransform3DMakeRotation(-.pi / 2.0, 1.0, 0.0, 0.0)
                upperBackLayer.shadowCover.opacity = 0.5
                lowerLayer.transform = CATransform3DIdentity
                lowerLayer.shadowCover.opacity = 1.0
                
                var transform = layer.transform
                transform = CATransform3DScale(transform, ScaleFactor, ScaleFactor, 1.0)
                transform = CATransform3DTranslate(transform, 0, UIScreen.main.bounds.size.height, 0)
                
                layer.transform = transform
            } else {
                upperFrontLayer.transform = CATransform3DMakeRotation(.pi / 2.0, 1.0, 0.0, 0.0)
                upperBackLayer.transform = CATransform3DIdentity
                upperBackLayer.shadowCover.opacity = 0.0
                lowerLayer.transform = CATransform3DIdentity
                lowerLayer.shadowCover.opacity = 0.0
                layer.transform = CATransform3DIdentity
            }
            
            CATransaction.commit()
        }
        
        func move(isPresent: Bool, next: (() -> ())?) {
            
            var transform = layer.transform
            transform = CATransform3DTranslate(transform, 0, (UIScreen.main.bounds.size.height + AppearExtraDistance) * (isPresent ? -1 : 1) , 0);
            
            let moveAnim = CABasicAnimation(keyPath: "transform.translation.y")
            moveAnim.fromValue = isPresent ? UIScreen.main.bounds.size.height : -AppearExtraDistance
            moveAnim.toValue = isPresent ? -AppearExtraDistance : UIScreen.main.bounds.size.height
            moveAnim.duration = AppearDurationFactor * duration
            moveAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            moveAnim.delegate = self
            
            nextOperation = {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                self.layer.transform = transform
                CATransaction.commit()
                next?()
            }
            
            layer.add(moveAnim, forKey: "move")
        }
        
        func open(isPresent: Bool, next: (() -> ())?) {
            
            let M_PI_2 = .pi * 0.5
            let animDuration = OpenDurationFactor * duration
            let timingFunc = CAMediaTimingFunction(name: isPresent ? kCAMediaTimingFunctionEaseIn : kCAMediaTimingFunctionEaseOut)
            
            let opacityLowerAnim = CABasicAnimation(keyPath: "opacity")
            opacityLowerAnim.fromValue = isPresent ? 1 : 0.5
            opacityLowerAnim.toValue = isPresent ? 0.5 : 1.0
            opacityLowerAnim.duration = animDuration
            opacityLowerAnim.timingFunction = timingFunc
            
            let rotateAnim = CABasicAnimation(keyPath: "transform.rotation.x")
            rotateAnim.fromValue = isPresent ? 0 : M_PI_2
            rotateAnim.toValue = isPresent ? M_PI_2 : 0
            rotateAnim.duration = animDuration
            rotateAnim.timingFunction = timingFunc
            rotateAnim.delegate = self
            
            nextOperation = {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                self.upperFrontLayer.transform = CATransform3DRotate(self.upperFrontLayer.transform, CGFloat(M_PI_2 * (isPresent ? 1 : -1)), 1.0, 0, 0);
                self.lowerLayer.shadowCover.opacity = isPresent ? 0.5 : 1.0
                CATransaction.commit()
                next?()
            }
            
            lowerLayer.shadowCover.add(opacityLowerAnim, forKey: "open_opacity")
            upperFrontLayer.add(rotateAnim, forKey: "open")
        }
        
        func flip(isPresent: Bool, next: (() -> ())?) {
            let animDuration = FlipDurationFactor * duration
            let timingFunc = CAMediaTimingFunction(name: isPresent ? kCAMediaTimingFunctionEaseOut : kCAMediaTimingFunctionEaseIn)
            
            var transform = layer.transform
            
            if isPresent {
                transform = CATransform3DTranslate(transform, 0, AppearExtraDistance, 0);
                transform = CATransform3DScale(transform, 1.0 / ScaleFactor, 1.0 / ScaleFactor, 1.0);
            } else {
                transform = CATransform3DTranslate(transform, 0, -AppearExtraDistance, 0);
                transform = CATransform3DScale(transform, ScaleFactor, ScaleFactor, 1.0);
            }
            
            let moveAnim = CABasicAnimation(keyPath: "transform")
            moveAnim.fromValue = layer.transform
            moveAnim.toValue = transform
            moveAnim.duration = animDuration
            moveAnim.timingFunction = timingFunc
            
            let rotateAnim = CABasicAnimation(keyPath: "transform.rotation.x")
            rotateAnim.fromValue = isPresent ? -.pi / 2.0 : 0
            rotateAnim.toValue = isPresent ? 0 : -.pi / 2.0
            rotateAnim.duration = animDuration
            rotateAnim.timingFunction = timingFunc
            rotateAnim.delegate = self
            
            let opacityAnim = CABasicAnimation(keyPath: "opacity")
            opacityAnim.fromValue = isPresent ? 0.5 : 0.0
            opacityAnim.toValue = isPresent ? 0.0 : 0.5
            opacityAnim.duration = animDuration
            opacityAnim.timingFunction = timingFunc
            
            nextOperation = {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                self.layer.transform = transform
                self.upperBackLayer.transform = CATransform3DRotate(self.upperBackLayer.transform, .pi / 2.0 * (isPresent ? 1 : -1), 1.0, 0, 0);
                self.upperBackLayer.shadowCover.opacity = isPresent ? 0.0 : 0.5
                self.lowerLayer.shadowCover.opacity = isPresent ? 0.0 : 0.5
                CATransaction.commit()
                next?()
            }
            
            layer.add(moveAnim, forKey: "flip_move")
            upperBackLayer.add(rotateAnim, forKey: "flip")
            upperBackLayer.shadowCover.add(opacityAnim, forKey: "flip_opacity")
            lowerLayer.shadowCover.add(opacityAnim, forKey: "flip_opacity")
        }
    }
    
    class GradientShadowLayer : CALayer {
        
        let shadowCover = CAGradientLayer()
        var shadowPosition = GradientShadowLayerPosition.top
        
        init(shadowPosition: GradientShadowLayerPosition) {
            super.init()
            self.shadowPosition = shadowPosition
            setup()
        }
        
        override init(layer: Any) {
            super.init(layer: layer)
            if let mirror = layer as? GradientShadowLayer {
                shadowPosition = mirror.shadowPosition
            }
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup() {
            shadowCover.colors = shadowPosition.colors()
            addSublayer(shadowCover)
            
            shadowColor = UIColor(white: 0, alpha: 0.6).cgColor
            shadowOffset = CGSize(width: 0, height: shadowPosition.shadowYOffset())
            shadowRadius = 2.0
            shadowOpacity = 0.8
        }
        
        override func layoutSublayers() {
            super.layoutSublayers()
            shadowCover.frame = bounds
            shadowPath = UIBezierPath(rect: bounds).cgPath
        }
    }
}

extension FlipTransition.FlipTransformView : CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let operation = nextOperation
        nextOperation = nil
        operation?()
    }
    
}

private let ScaleFactor = CGFloat(0.875)

private let AppearExtraDistance = CGFloat(40.0)

private let AppearDurationFactor = 1.0 / 3.0

private let FlipDurationFactor = 1.0 / 3.0

private let OpenDurationFactor = 1.0 / 3.0

private let MaskDimAnimKey = "MaskDimAnimKey"


