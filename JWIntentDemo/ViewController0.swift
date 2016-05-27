//
//  ViewController0.swift
//  JWIntentDemo
//
//  Created by Jerry on 16/5/10.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import UIKit

class ViewController0: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "VC0"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didPresentVC1(sender: AnyObject) {
        let intent = JWIntent(source: self, targetClassName: "ViewController1")
        intent.extraData = ["backgroundColor":UIColor.lightGrayColor(), "stringValue":"Hello JWIntent", "textColor":UIColor.whiteColor()]
        intent.action = .Present
        
        intent.submit()
    }
    
    @IBAction func didPushVC1(sender: AnyObject) {
        let intent = JWIntent(source: self, targetClassName: "ViewController1")
        intent.extraData = ["backgroundColor":UIColor.lightGrayColor(), "stringValue":"Hello JWIntent", "textColor":UIColor.whiteColor()]
        intent.action = .Push
        
        intent.submit()
    }
    
    @IBAction func didPerformBlock(sender: AnyObject) {
        let intent = JWIntent(source: self, targetURLString: "callBack://testAlert?extraData={\"title\":\"Hello Alert\",\"message\":\"I have a message for you.\"}")
        intent.submitWithCompletion {
            [weak self] in
            self?.title = "Hello VC, I am alert."
        }
    }
    
    @IBAction func didPushByKey(sender: AnyObject) {
        let intent = JWIntent(source: self, targetURLString: "router://vc1?extraData={\"stringValue\":\"Hello JWIntent\"}")
        intent.action = .Push
        intent.submit()
    }
}
