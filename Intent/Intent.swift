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

public protocol Submittable {
    
    func submit(complete: (() -> ())?)
    
}

/// An atstract type with an executable intention
public protocol Intent: Submittable {
    
    associatedtype Config
    
    associatedtype Executor
    
    associatedtype Input
    
    associatedtype Output
    
    typealias Intention = (Input?) -> (Output)
    
    static var defaultCtx: IntentCtx<Self> { get }
    
    var input: Input? { get set }
    
    var config: Config { get set }
    
    var executor: Executor? { get set }
    
    var intention: Intention { get }
    
    init(intention: @escaping Intention)
    
}

public extension Intent {
    
    public init(host: String, ctx: IntentCtx<Self>? = Self.defaultCtx) throws {
        let intention = try (ctx ?? Self.defaultCtx).fetch(forHost: host)
        self.init(intention: intention)
    }
    
    public init(urlString: String, inputParser: (([String: Any]?) -> Input?),ctx: IntentCtx<Self>? = Self.defaultCtx) throws {
        var url = URL(string: urlString)
        if url == nil, let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            url = URL(string: encodedURLString)
        }
        guard let mURL = url else {
            throw IntentError.invalidURL(urlString: urlString)
        }
        do {
            let (intention, param) = try (ctx ?? Self.defaultCtx).fetch(withURL: mURL)
            self.init(intention: intention)
            self.input = inputParser(param)
        } catch {
            throw error
        }
    }
}



public extension Intent where Input == [String: Any] {
    
    public init(urlString: String, ctx: IntentCtx<Self>? = Self.defaultCtx, executor: Executor? = nil) throws {
        do {
            try self.init(urlString: urlString, inputParser: { $0 }, ctx: ctx)
        } catch {
            throw error
        }
    }
    
}
