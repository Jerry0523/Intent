//
// _ModalViewController.swift
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

class _ModalViewController: UIViewController {
    
    private func addContentViewIfNeeded() {
        guard isViewLoaded, let contentVC = childViewControllers.last else {
            return
        }
        let contentView = contentVC.view!
        view.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        constraints.append(NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: contentView.superview, attribute: .left, multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: contentView.superview, attribute: .right, multiplier: 1.0, constant: 0))
        if modalOption.contains(.contentBottom) {
            constraints.append(NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: contentView.superview, attribute: .bottom, multiplier: 1.0, constant: 0))
        } else if modalOption.contains(.contentTop) {
            constraints.append(NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: contentView.superview, attribute: .top, multiplier: 1.0, constant: 0))
        } else {//centered
            constraints.append(NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: contentView.superview, attribute: .centerY, multiplier: 1.0, constant: 0))
        }
        NSLayoutConstraint.activate(constraints)
        contentView.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (modalOption.contains(.dimBlur)) {
            view.addSubview(dimBlurView)
        } else {
            view.addSubview(dimView)
        }
        addContentViewIfNeeded()
    }
    
    override func addChildViewController(_ childController: UIViewController) {
        for childVC in childViewControllers {
            if (isViewLoaded && childVC.isViewLoaded && childVC.view.superview == view) {
                childVC.view.removeFromSuperview()
            }
            childVC.removeFromParentViewController()
        }
        super.addChildViewController(childController)
        addContentViewIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func present() {
        guard let childVC = childViewControllers.last else {
            return
        }
        
        let bottomRootVC = Router.topViewController
        bottomRootVC?.viewWillDisappear(true)
        
        let contentView = childVC.view
        
        if (modalOption.contains(.cancelAnimation)) {
            dimBlurView.effect = UIBlurEffect(style: .dark)
            dimView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        } else {
            transform(forContentView: childVC.view)
            dimBlurView.effect = nil
            dimView.backgroundColor = UIColor.clear
            
            UIView.animate(withDuration: 0.3, animations: {
                self.dimBlurView.effect = UIBlurEffect(style: .dark)
                self.dimView.backgroundColor = UIColor(white: 0, alpha: 0.6)
                contentView?.transform = CGAffineTransform.identity
            })
        }
        
        let targetWindow = Router.topWindow
        targetWindow.rootViewController = self
        targetWindow.isHidden = false
        
        bottomRootVC?.viewDidDisappear(true)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        guard let childVC = childViewControllers.last else {
            return
        }
        
        let bottomRootVC = Router.topViewController
        bottomRootVC?.viewWillAppear(flag)
        
        let completionBlock = {(finished: Bool) -> Void in
            let targetWindow = Router.topWindow
            targetWindow.rootViewController = UIViewController()
            targetWindow.isHidden = true
            bottomRootVC?.viewDidAppear(flag)
            if (completion != nil) {
                completion!()
            }
        }
        
        if (flag) {
            UIView.animate(withDuration: 0.3, animations: {
                self.dimBlurView.effect = nil
                self.dimView.backgroundColor = UIColor.clear
                self.transform(forContentView: childVC.view)
            }, completion: completionBlock)
            
        } else {
            completionBlock(true)
        }
    }
    
    private func transform(forContentView contentView: UIView) {
        if modalOption.contains(.contentBottom) {
            contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.size.height)
        } else if modalOption.contains(.contentTop) {
            contentView.transform = CGAffineTransform(translationX: 0, y: -contentView.bounds.size.height)
        } else {//centered
            contentView.transform = CGAffineTransform(scaleX: 0, y: 0)
        }
    }
    
    @objc private func dismissAnimated() {
        dismiss(animated: true, completion: nil)
    }
    
    var modalOption: Router.RouterConfig.ModalOption = []
    
    private lazy var dimView: UIView = {
        let _dimView = UIView(frame: view.bounds)
        _dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(dismissAnimated))
        _dimView.addGestureRecognizer(tapGes)
        return _dimView
    }()
    
    private lazy var dimBlurView: UIVisualEffectView = {
        let _effectView = UIVisualEffectView(frame: view.bounds)
        _effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(dismissAnimated))
        _effectView.addGestureRecognizer(tapGes)
        return _effectView
    }()
}
