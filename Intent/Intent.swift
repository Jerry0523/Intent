//
//  Intent.swift
//  JWKit
//
//  Created by Jerry on 2017/10/27.
//  Copyright © 2017年 com.jerry. All rights reserved.
//

import Foundation

public enum IntentError : Error {
    
    case invalidURL(urlString: String?)
    
    case invalidScheme(scheme: String?)
    
    case invalidKey(key: String?)
    
    case invalidIntention
    
}

public protocol Intent {
    
    associatedtype Config
    
    associatedtype Executor
    
    associatedtype Intention
    
    var extra: [String: Any]? { get set }
    
    var config: Config { get set }
    
    var executor: Executor? { get set }
    
    var intention: Intention? { get set }
    
    func submit(complete: (() -> ())?)
    
    init()
    
    init(intention: Intention, executor: Executor?, extra: [String: Any]?)
    
    init(key: String, ctx: IntentCtx?, executor: Executor?, extra: [String: Any]?) throws
    
    init(urlString: String, ctx: IntentCtx?, executor: Executor?) throws
}

public extension Intent {
    
    public init(intention: Intention, executor: Executor? = nil, extra: [String: Any]? = nil) {
        self.init()
        self.executor = executor
        self.intention = intention
        self.extra = extra
    }
    
    public init(key: String, ctx: IntentCtx? = IntentCtx.default, executor: Executor? = nil, extra: [String: Any]? = nil) throws {
        self.init()
        
        let mCtx = (ctx ?? IntentCtx.default)
        
        guard let intention: Intention = try mCtx.fetch(forKey: key) else {
            throw IntentError.invalidIntention
        }
        
        self.executor = executor
        self.intention = intention
        self.extra = extra
    }
    
    public init(urlString: String, ctx: IntentCtx? = IntentCtx.default, executor: Executor? = nil) throws {
        var url = URL.init(string: urlString)
        if url == nil, let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            url = URL.init(string: encodedURLString)
        }
        if url == nil {
            throw IntentError.invalidURL(urlString: urlString)
        }
        do {
            let (intention, extra) = try (ctx ?? IntentCtx.default).fetch(withURL: url!)
            let mIntention = intention as? Intention
            if mIntention == nil {
                throw IntentError.invalidIntention
            }
            self.init(intention: mIntention!, executor: executor, extra: extra)
        } catch {
            throw error
        }
    }
}
