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
        self.title = "Content View Controller"
        
        self.textLabel.textColor = self.textColor ?? UIColor.black
        self.textLabel.text = self.stringValue
        self.view.backgroundColor = self.backgroundColor ?? UIColor.white
        
        if let transition = self.pushTransition as? RingTransition {
            self.ringTransition = transition
            self.setupVerticalPanGesture()
            
        } else if let transition = self.pushTransition as? FlipTransition {
            self.flipTransition = transition
            self.setupVerticalPanGesture()
        }
    }
    
    private func setupVerticalPanGesture() {
        let ges = UIPanGestureRecognizer.init(target: self, action: #selector(handlePanGesture(_:)))
        self.view.addGestureRecognizer(ges)
        self.navigationController?.interactivePopGestureRecognizer?.require(toFail: ges)
    }
    
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if let transition = self.ringTransition {
            transition.handle(interactivePanGesture: sender, beginAction: {
                self.navigationController?.popViewController(animated: true)
            }, axis: .verticalBottomToTop, threshold: 0.3)
            
        } else if let transition = self.flipTransition {
            transition.handle(interactivePanGesture: sender, beginAction: {
                self.navigationController?.popViewController(animated: true)
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
