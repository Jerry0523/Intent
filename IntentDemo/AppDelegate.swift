//
//  AppDelegate.swift
//  LearningSwift
//
//  Created by Jerry on 2017/10/17.
//  Copyright © 2017年 com.yihaodian. All rights reserved.
//

import UIKit
import Intent

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GetTopWindow {

    var window: UIWindow?
    
    lazy var topWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.clear
        window.windowLevel = UIWindowLevelNormal + 1
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        window.isHidden = true
        return window
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        IntentDemo.load()
        registerIntent()
        
        window = UIWindow(frame: UIScreen.main.bounds)
    
        window?.rootViewController = UINavigationController(rootViewController: EntryViewContoller())
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func registerIntent() {
        
        Router.defaultCtx.scheme = "router"
        Handler.defaultCtx.scheme = "handler"
        
        Router.defaultCtx.register(ContentViewController.self, forKey: "content")
        Router.defaultCtx.register(EntryViewContoller.self, forKey: "entry")
        Router.defaultCtx.register(ModalViewController.self, forKey: "modal")
        
        Handler.defaultCtx.register({ (param) in
            let title = (param ?? [String: Any]())["title"] as? String ?? ""
            let msg = (param ?? [String: Any]())["message"] as? String ?? ""
            
            let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            Router.topViewController?.present(alertController, animated: true, completion: nil)
            
        }, forKey: "showAlert")
        
    }

}

