//
//  Handler.swift
//  JWKit
//
//  Created by Jerry on 2017/10/30.
//  Copyright © 2017年 com.jerry. All rights reserved.
//

import Foundation

public enum HandlerConfig {
    
    case onMainThread
    
    case onBackgroundThread
    
    func preferredQueue() -> DispatchQueue {
        switch self {
        case .onMainThread:
            return DispatchQueue.main
        case .onBackgroundThread:
            return DispatchQueue.global()
        }
    }
}

public struct Handler : Intent {
    
    public var extra: [String : Any]?
    
    public var config: HandlerConfig = .onMainThread
    
    public var executor: Void?
    
    public var intention: (([String : Any]?) -> ())?
    
    public func submit(complete: (() -> ())? = nil) {
        self.config.preferredQueue().async {
            self.intention?(self.extra)
            complete?()
        }
    }
    
    public init() {
        
    }
}
