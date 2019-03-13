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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Content View Controller"
        
        textLabel.textColor = textColor ?? UIColor.black
        textLabel.text = stringValue
        view.backgroundColor = backgroundColor ?? UIColor.white
        
        if let transition = pushTransition as? RingTransition {
            ringTransition = transition
            setupVerticalPanGesture()
            
        }
    }
    
    private func setupVerticalPanGesture() {
        let ges = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(ges)
        navigationController?.interactivePopGestureRecognizer?.require(toFail: ges)
    }
    
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if let transition = ringTransition {
            transition.handle(sender, gestureDidBegin: {
                self.navigationController?.popViewController(animated: true)
            }, axis: .verticalTopToBottom, completeThreshold: 0.3)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func switchToEntry(_ sender: Any) {
        try? Route(path: "test.com/entry")
                .config(.switch(nil))
                .submit()
    }
}
