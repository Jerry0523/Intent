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
    
    @IBOutlet weak var ringBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Intent Demo"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func didTapPresentWithKeyBtn(_ sender: Any) {
        try? Route(path: "test.com/entry")
                .config(.present(fakePushSwitch.isOn ? [.fakePush, .wrapNC] : .wrapNC))
                .submit()
    }
    
    @IBAction func didTapPushWithRingBtn(_ sender: Any) {
        try? Route(path: "test.com/content")
                .input(["stringValue": "This message came from a router", "backgroundColor": UIColor.red, "textColor": UIColor.white])
                .config(.push(nil))
                .transition(RingTransition())
                .submit()
    }
    
    @IBAction func didTapPushWithKeyBtn(_ sender: Any) {
        try? Route(path: "test.com/content")
                .input(["stringValue": "This message came from a router", "backgroundColor": UIColor.red, "textColor": UIColor.white])
                .config(.push(nil))
                .transition(pushAnimationSegmentControl.selectedSegmentIndex == 0 ? nil : SystemTransition(axis: .horizontal, style: .zoom(factor: 0.9)))
                .submit()
    }
    
    @IBAction func didTapShowWithKeyBtn(_ sender: Any) {
        try? Route(path: "test.com/content")
                .input(["stringValue": "Config could be inferred if not provided"])
                .submit()
    }
    
    @IBAction func didTapShowWithURLBtn(_ sender: Any) {
        try? Route(URLString: "route://test.com/content?stringValue=This message came from a url string")
                    .submit()
    }
    
    @IBAction func didTapShowModalWithKeyBtn(_ sender: Any) {
        var opt = Route.Config.PopupOption(rawValue: 0)
        switch modalPositionSegmentControl.selectedSegmentIndex {
        case 0:
            opt = .contentTop
        case 2:
            opt = .contentBottom
        default:
            break
        }
        if let pageId = AppRegistry.shared.id(for: ModalViewController.self) {
            Route({ _ in ModalViewController() }, pageId)
                .config(.popup(opt))
                .submit()
        }
    }
    
    @IBAction func didTapHandlerBtn(_ sender: Any) {
        try? Handler(path: "test.com/showAlert")
                .input(["title": "Hello Alert", "message": "This message came from a handler"])
                .submit()
    }
}

extension EntryViewContoller : RingTransitionDataSource {
    
    func viewForTransition() -> UIView? {
        return ringBtn
    }
}
