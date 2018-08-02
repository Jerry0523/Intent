//
// _ScreenEdgeDetectorViewController.swift
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

class _ScreenEdgeDetectorViewController : UIViewController, UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViewIfNeeded()
        
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleScreenEdgeGesture(_:)))
        gesture.edges = UIRectEdge.left
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    override func addChildViewController(_ childController: UIViewController) {
        if isViewLoaded {
            for subView in view.subviews {
                subView.removeFromSuperview()
            }
        }
        
        for subVC in childViewControllers {
            subVC.removeFromParentViewController()
        }
        super.addChildViewController(childController)
        addChildViewIfNeeded()
    }
    
    private func addChildViewIfNeeded() {
        if !isViewLoaded {
            return
        }
        
        if let childController = childViewControllers.first {
            childController.view.frame = view.bounds
            childController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(childController.view)
            childController.didMove(toParentViewController: self)
        }
    }
    
    @objc private func handleScreenEdgeGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        presentTransition?.handle(sender, gestureDidBegin: {
            dismiss(animated: true, completion: nil)
        })
    }
}
