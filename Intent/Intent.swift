//
// Intent.swift
//
// Copyright (c) 2015 Jerry Wong
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public enum IntentError : Error {
    
    case invalidURL(urlString: String?)
    
    case invalidScheme(scheme: String?)
    
    case invalidKey(key: String?)
    
}

/// An atstract type with an intention that is executable
public protocol Intent {
    
    associatedtype Config
    
    associatedtype Executor
    
    associatedtype Intention
    
    static var defaultCtx: IntentCtx<Self> { get }
    
    var extra: [String: Any]? { get set }
    
    var config: Config { get set }
    
    var executor: Executor? { get set }
    
    var intention: Intention! { get set }
    
    func submit(complete: (() -> ())?)
    
    init()
    
    init(intention: Intention, executor: Executor?, extra: [String: Any]?)
    
    init(key: String, ctx: IntentCtx<Self>?, executor: Executor?, extra: [String: Any]?) throws
    
    init(urlString: String, ctx: IntentCtx<Self>?, executor: Executor?) throws
    
}

public extension Intent {
    
    public init(intention: Intention, executor: Executor? = nil, extra: [String: Any]? = nil) {
        self.init()
        self.executor = executor
        self.intention = intention
        self.extra = extra
    }
    
    public init(key: String, ctx: IntentCtx<Self>? = Self.defaultCtx, executor: Executor? = nil, extra: [String: Any]? = nil) throws {
        self.init()
        
        let mCtx = (ctx ?? Self.defaultCtx)
        
        let intention = try mCtx.fetch(forKey: key)
        
        self.executor = executor
        self.intention = intention
        self.extra = extra
    }
    
    public init(urlString: String, ctx: IntentCtx<Self>? = Self.defaultCtx, executor: Executor? = nil) throws {
        var url = URL(string: urlString)
        if url == nil, let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            url = URL(string: encodedURLString)
        }
        guard let mURL = url else {
            throw IntentError.invalidURL(urlString: urlString)
        }
        do {
            let (intention, extra) = try (ctx ?? Self.defaultCtx).fetch(withURL: mURL)
            self.init(intention: intention, executor: executor, extra: extra)
        } catch {
            throw error
        }
    }
}
