//
//  ContentViewController.swift
//  JWIntentDemo
//
//  Created by Jerry on 2017/11/8.
//  Copyright © 2017年 Jerry Wong. All rights reserved.
//

import UIKit
import Intent

@objcMembers class ContentViewController: UIViewController {
    
    @IBOutlet weak var textLabel: UILabel!
    
    var textColor: UIColor?
    var stringValue: String?
    var backgroundColor: UIColor?
    
    var ringTransition: RingTransition?
    var flipTransition: FlipTransition?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Content View Controller"
        
        textLabel.textColor = textColor ?? UIColor.black
        textLabel.text = stringValue
        view.backgroundColor = backgroundColor ?? UIColor.white
        
        if let transition = pushTransition as? RingTransition {
            ringTransition = transition
            setupVerticalPanGesture()
            
        } else if let transition = pushTransition as? FlipTransition {
            flipTransition = transition
            setupVerticalPanGesture()
        }
    }
    
    private func setupVerticalPanGesture() {
        let ges = UIPanGestureRecognizer.init(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(ges)
        navigationController?.interactivePopGestureRecognizer?.require(toFail: ges)
    }
    
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if let transition = ringTransition {
            transition.handle(interactivePanGesture: sender, beginAction: {
                navigationController?.popViewController(animated: true)
            }, axis: .verticalBottomToTop, threshold: 0.3)
            
        } else if let transition = flipTransition {
            transition.handle(interactivePanGesture: sender, beginAction: {
                navigationController?.popViewController(animated: true)
            }, axis: .verticalTopToBottom, threshold: 0.3)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func switchToEntry(_ sender: Any) {
        var router = try? Router.init(key: "entry")
        router?.config = .switch(nil)
        router?.submit()
    }
}
