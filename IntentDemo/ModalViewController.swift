//
//  ModalViewController.swift
//  JWIntentDemo
//
//  Created by Jerry on 2017/11/8.
//  Copyright © 2017年 Jerry Wong. All rights reserved.
//

import UIKit
import Intent

class ModalViewController: UIViewController, AssociatedTransitionDataSource {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if presentTransition != nil {
            let ges = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
            imageView.addGestureRecognizer(ges)
        }
    }
    
    func manipulateAssociatedFromView(with work: (UIView) -> ()) {
        guard let associatedTransition = (presentTransition as? AssociatedTransition) else {
            return
        }
        associatedTransition.associatedFromViews.forEach {
            work($0)
        }
    }
    
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let point = sender.translation(in: view)
        let progress = 2.0 * CGFloat(fabsf(Float(point.y))) / view.bounds.height
        let percent = 1 - progress
        
        switch sender.state {
        case .began:
            manipulateAssociatedFromView {
                $0.isHidden = true
            }
        case .changed:
            imageView.transform =  CGAffineTransform(translationX: point.x, y: point.y).scaledBy(x: max(0.5, percent), y: max(0.5, percent))
            view.backgroundColor = UIColor.white.withAlphaComponent(percent)
            titleLabel.alpha = percent
        default:
            manipulateAssociatedFromView {
                $0.isHidden = true
            }
            if progress > 0.3 {
                dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.imageView.transform = .identity
                    self.view.backgroundColor = .white
                    self.titleLabel.alpha = 1.0
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func viewsForTransition() -> [UIView]? {
        return [imageView]
    }
}
