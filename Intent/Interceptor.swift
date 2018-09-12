//
// Interceptor.swift
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

public final class Interceptor: Intent {

    public static var defaultCtx = IntentCtx<(Any?) -> (Bool)>(scheme: "interceptor")
    
    public var input: Any?
    
    public var config = Void.self
    
    public var executor: Void?
    
    public var intention: (Any?) -> (Bool)
    
    public var identifier: Identifier?
    
    public init(intention: @escaping Intention) {
        self.intention = intention
    }
    
    convenience init<T>(intent: T) throws where T: Intent {
        guard let identifier = intent.identifier?.absolute else {
            throw IntentError.unknown(msg: "no interceptor found for \(intent)")
        }
        try self.init(path: identifier)
    }
    
    public func makeIdentifier(forPath: String) -> Identifier? {
        return Identifier(path: forPath, absolute: forPath)
    }
    
    public func doSubmit(complete: (() -> ())?) {
        let ret = intention(input)
        if ret {
            complete?()
        }
    }
    
}
