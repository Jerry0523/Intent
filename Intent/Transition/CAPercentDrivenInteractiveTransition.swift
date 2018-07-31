//
//
// CAPercentDrivenInteractiveTransition.swift
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

class CAPercentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    private var pausedTime: CFTimeInterval = 0
    
    private var currentPercent: CGFloat = 0
    
    private weak var transitionCtx: UIViewControllerContextTransitioning?
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        transitionCtx = transitionContext
        pause(layer: transitionContext.containerView.layer)
        super.startInteractiveTransition(transitionContext)
    }
    
    override func update(_ percentComplete: CGFloat) {
        currentPercent = percentComplete
        transitionCtx?.updateInteractiveTransition(percentComplete)
        if transitionCtx != nil {
            transitionCtx!.containerView.layer.timeOffset = pausedTime + CFTimeInterval(duration * percentComplete)
        }
    }
    
    override func cancel() {
        transitionCtx?.cancelInteractiveTransition()
        if transitionCtx != nil {
            let containerLayer = transitionCtx!.containerView.layer
            containerLayer.speed = -1.0
            containerLayer.beginTime = CACurrentMediaTime()
            
            let delay = (1.0 - currentPercent) * duration + 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay), execute: {
                self.resume(layer: containerLayer)
                self.transitionCtx = nil
            })
        }
    }
    
    override func finish() {
        transitionCtx?.finishInteractiveTransition()
        if transitionCtx != nil {
            resume(layer: transitionCtx!.containerView.layer)
            transitionCtx = nil
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
