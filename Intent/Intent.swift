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
    
    case invalidURL(URLString: String?)
    
    case invalidScheme(scheme: String?)
    
    case invalidPath(path: String?)
    
    case unknown(msg: String)
    
}

/// An atstract type with an executable intention
public protocol Intent {
    
    associatedtype Config
    
    associatedtype Executor
    
    associatedtype Input
    
    associatedtype Output
    
    typealias Intention = (Input?) -> (Output)
    
    static var defaultCtx: IntentCtx<Intention> { get }
    
    var input: Input? { get set }
    
    var config: Config { get set }
    
    var executor: Executor? { get set }
    
    var intention: Intention { get }
    
    var id: String { get }
    
    init(_ intention: @escaping Intention, _ id: String)
    
    func doSubmit(complete: (() -> ())?)
    
}

public extension Intent {
    
    public func submit(complete: (() -> ())? = nil) {
        if let interceptor = try? Interceptor(intent: self) {
            interceptor.input = self
            interceptor.submit {
                self.doSubmit(complete: complete)
            }
        } else {
            doSubmit(complete: complete)
        }
    }
    
}

public extension Intent {
    
    public init(path: String, ctx: IntentCtx<Intention>? = Self.defaultCtx) throws {
        try self.init(URLString: (ctx.self?.scheme)! + "://" + path, inputParser: { _ in return nil }, ctx: ctx)
    }
    
    public init(URLString: String, inputParser: (([String: Any]?) -> Input?), ctx: IntentCtx<Intention>? = Self.defaultCtx) throws {
        var url = URL(string: URLString)
        if url == nil, let encodedURLString = URLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            url = URL(string: encodedURLString)
        }
        guard let mURL = url else {
            throw IntentError.invalidURL(URLString: URLString)
        }
        try self.init(URL: mURL, inputParser: inputParser, ctx: ctx)
    }
    
    public init(URL: URL, inputParser: (([String: Any]?) -> Input?), ctx: IntentCtx<Intention>? = Self.defaultCtx) throws {
        do {
            let (box, param) = try (ctx ?? Self.defaultCtx).fetch(withURL: URL)
            self.init(box.raw, box.id)
            self.input = inputParser(param)
        } catch {
            throw error
        }
    }
}

public extension Intent where Input == [String: Any] {
    
    public init(URLString: String, ctx: IntentCtx<Intention>? = Self.defaultCtx, executor: Executor? = nil) throws {
        do {
            try self.init(URLString: URLString, inputParser: { $0 }, ctx: ctx)
        } catch {
            throw error
        }
    }
    
}
