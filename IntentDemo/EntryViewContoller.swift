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
//        var router = try? Router(key: "content", extra: ["stringValue": "This message came from a router"])
        var router = try? Router(key: "entry")
        router?.config = .present(fakePushSwitch.isOn ? [.fakePush, .wrapNC] : .wrapNC)
        router?.submit()
    }
    
    @IBAction func didTapPushWithRingBtn(_ sender: Any) {
        var router = try? Router(key: "content", param: ["stringValue": "This message came from a router", "backgroundColor": UIColor.red, "textColor": UIColor.white])
        router?.config = .push(nil)
        router?.transition = RingTransition()
        router?.submit()
    }
    
    @IBAction func didTapPushWithKeyBtn(_ sender: Any) {
        var router = try? Router(key: "content", param: ["stringValue": "This message came from a router", "backgroundColor": UIColor.red, "textColor": UIColor.white])
        router?.config = .push(nil)
        if pushAnimationSegmentControl.selectedSegmentIndex == 0 {
            router?.transition = FlipTransition()
        } else if pushAnimationSegmentControl.selectedSegmentIndex == 1 {
            router?.transition = SystemTransition(axis: .horizontal, style: .zoom(factor: 0.9))
        }
        router?.submit()
    }
    
    @IBAction func didTapShowWithKeyBtn(_ sender: Any) {
        let router = try? Router(key: "content", param: ["stringValue": "Config could be inferred if not provided"])
        router?.submit()
    }
    
    @IBAction func didTapShowWithURLBtn(_ sender: Any) {
        let router = try? Router(urlString: "router://content?stringValue=This message came from a url string")
        router?.submit()
    }
    
    @IBAction func didTapShowModalWithKeyBtn(_ sender: Any) {
        var router = Router(intention: { _ in ModalViewController() })
        var modalOption: Router.RouterConfig.ModalOption = []
        if modalPositionSegmentControl.selectedSegmentIndex == 0 {
            modalOption = .contentTop
        } else if modalPositionSegmentControl.selectedSegmentIndex == 2 {
            modalOption = .contentBottom
        }
        router.config = .modal(modalOption)
        router.submit()
    }
    
    @IBAction func didTapHandlerBtn(_ sender: Any) {
        let handler = try? Handler(key: "showAlert", param: ["title": "Hello Alert", "message": "This message came from a handler"])
        handler?.submit()
    }
}

extension EntryViewContoller : RingTransitionDataSource {
    
    func viewForTransition() -> UIView? {
        return ringBtn
    }
}
