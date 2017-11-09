//
//  ContentViewController.swift
//  JWIntentDemo
//
//  Created by Jerry on 2017/11/8.
//  Copyright © 2017年 Jerry Wong. All rights reserved.
//

import UIKit

@objcMembers class ContentViewController: UIViewController {
    
    @IBOutlet weak var textLabel: UILabel!
    
    var textColor: UIColor?
    var stringValue: String?
    var backgroundColor: UIColor?
    
    var ringTransition: RingTransition?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Content View Controller"
        
        self.textLabel.textColor = self.textColor ?? UIColor.black
        self.textLabel.text = self.stringValue
        self.view.backgroundColor = self.backgroundColor ?? UIColor.white
        
        if let transition = self.pushTransition as? RingTransition {
            self.ringTransition = transition
            let ges = UIPanGestureRecognizer.init(target: self, action: #selector(handlePanGesture(_:)))
            self.view.addGestureRecognizer(ges)
            self.navigationController?.interactivePopGestureRecognizer?.require(toFail: ges)
        }
        
    }
    
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        self.ringTransition?.handle(interactivePanGesture: sender, axis: .vertical, threshold: 0.5, beginAction: {
            self.navigationController?.popViewController(animated: true)
        })
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
