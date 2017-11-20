//
//  EntryViewContoller.swift
//  JWIntentDemo
//
//  Created by Jerry on 2017/11/8.
//  Copyright © 2017年 Jerry Wong. All rights reserved.
//

import UIKit
import Intent

class EntryViewContoller: UIViewController {
    
    
    @IBOutlet weak var fakePushSwitch: UISwitch!
    
    @IBOutlet weak var pushAnimationSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var modalPositionSegmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Intent Demo"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func didTapPresentWithKeyBtn(_ sender: Any) {
        var router = try? Router.init(key: "content", extra: ["stringValue": "This message came from a router"])
        router?.config = .present(fakePushSwitch.isOn ? [.fakePush, .wrapNC] : .wrapNC)
        router?.submit()
    }
    
    @IBAction func didTapPushWithKeyBtn(_ sender: Any) {
        var router = try? Router.init(key: "content", extra: ["stringValue": "This message came from a router", "backgroundColor": UIColor.red, "textColor": UIColor.white])
        router?.config = .push(nil)
        if pushAnimationSegmentControl.selectedSegmentIndex == 0 {
            router?.transition = FlipTransition.init()
        } else if pushAnimationSegmentControl.selectedSegmentIndex == 1 {
            router?.transition = SystemTransition.init(axis: .horizontal, style: .zoom(factor: 0.8))
        } else if pushAnimationSegmentControl.selectedSegmentIndex == 2 {
            router?.transition = RingTransition.init()
        }
        router?.submit()
    }
    
    @IBAction func didTapShowWithKeyBtn(_ sender: Any) {
        let router = try? Router.init(key: "content", extra: ["stringValue": "Config could be inferred if not provided"])
        router?.submit()
    }
    
    @IBAction func didTapShowWithURLBtn(_ sender: Any) {
        let router = try? Router.init(urlString: "router://content?stringValue=This message came from a url string")
        router?.submit()
    }
    
    @IBAction func didTapShowModalWithKeyBtn(_ sender: Any) {
        var router = Router(intention: ModalViewController.self)
        var modalOption: ModalOption = []
        if self.modalPositionSegmentControl.selectedSegmentIndex == 0 {
            modalOption = .contentTop
        } else if self.modalPositionSegmentControl.selectedSegmentIndex == 2 {
            modalOption = .contentBottom
        }
            
        router.config = .modal(modalOption)
        router.submit()
    }
    
    @IBAction func didTapHandlerBtn(_ sender: Any) {
        let handler = try? Handler.init(key: "showAlert", extra: ["title": "Hello Alert", "message": "This message came form a handler"])
        handler?.submit()
    }
}

extension EntryViewContoller : RingTransitionDataSource {
    
    func viewForTransition() -> UIView? {
        return self.view.viewWithTag(112)
    }
}
