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
        let intent = JWRouter(source: self, routerKey: "vc1")
        intent.extraData = ["backgroundColor":UIColor.redColor(), "stringValue":"Hello JWIntent", "textColor":UIColor.whiteColor()]
        intent.option = .Present
        
        intent.submit()
    }
    
    @IBAction func didPushVC1(sender: AnyObject) {
        let intent = JWRouter(source: self, routerKey: "vc1")
        intent.extraData = ["backgroundColor":UIColor.darkGrayColor(), "stringValue":"Hello JWIntent", "textColor":UIColor.whiteColor()]
        intent.option = .Push
        
        intent.submit()
    }
    
    @IBAction func didPushByURL(sender: AnyObject) {
        let intent = JWIntent(URLString: "router://vc1?extraData={\"stringValue\":\"I AM FROM URL\"}", context: nil)
        intent.submit()
    }
    
    @IBAction func didPerformBlock(sender: AnyObject) {
        let intent = JWHandler(handlerKey: "testAlert")
        intent.extraData = ["title":"Hello Alert", "message":"I have a message for you."]
        intent.submitWithCompletion {
            [weak self] in
            self?.title = "Hello VC, I am alert."
        }
    }
}
