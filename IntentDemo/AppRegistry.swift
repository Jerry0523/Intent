//
//  AppRegistry.swift
//  IntentDemo
//
//  Created by Jerry Wong on 2019/3/13.
//  Copyright © 2019 Jerry Wong. All rights reserved.
//

import Intent
import UIKit

class AppRegistry {
    
    static let shared = AppRegistry()
    
    ///key: host, value: id
    private(set) var routeRegistry = [String: String]()
    
    ///key: class string, value: id
    private(set) var routeRegistryMapped = [String: String]()
    
    func id<T>(for vClass: T.Type) -> String? where T: UIViewController {
        return routeRegistryMapped[NSStringFromClass(vClass)]
    }
    
    func load() {
        
        Route.defaultCtx.scheme = "route"
        Handler.defaultCtx.scheme = "handler"
        
        let routeConfig = ["test.com/content": ContentViewController.self,
                        "test.com/entry": EntryViewContoller.self,
                        "test.com/modal": ModalViewController.self]
        
        routeRegistry = Route.defaultCtx.register(routeConfig)
        routeRegistryMapped = routeRegistry.reduce(routeRegistryMapped, {
            var ret = $0
            ret[NSStringFromClass(routeConfig[$1.key]!)] = $1.value
            return ret
        })
        
        Interceptor.defaultCtx.register({ (input) -> (Bool) in
            if let route = input as? Route {
                if route.transition != nil {
                    if let msg = route.input?["stringValue"] as? String {
                        route.input?["stringValue"] = msg + "\n" + "The background color has been changed by the interceptor"
                    }
                    route.input?["backgroundColor"] = UIColor.purple
                }
                return true
            }
            return true
        }, forPath: routeRegistry["test.com/content"]!)
        
        Handler.defaultCtx.register({ (param) in
            let title = (param ?? [String: Any]())["title"] as? String ?? ""
            let msg = (param ?? [String: Any]())["message"] as? String ?? ""
            
            let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            Route.topViewController?.present(alertController, animated: true, completion: nil)
            
        }, forPath: "test.com/showAlert")
    }
    
}
