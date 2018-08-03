//
// Handler.swift
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

public enum HandlerConfig {
    
    case onMainQueue
    
    case onGlobalQueue
    
    case onSpecificQueue(queue: DispatchQueue)
    
    var queue: DispatchQueue {
        get {
            switch self {
            case .onMainQueue:
                return DispatchQueue.main
            case .onGlobalQueue:
                return DispatchQueue.global()
            case .onSpecificQueue(let queue):
                return queue
            }
        }
    }
}

public final class Handler : Intent {
 
    public static var defaultCtx = IntentCtx<Handler>(scheme: "handler")

    public var input: [String : Any]?

    public var config: HandlerConfig = .onMainQueue

    public var executor: Void?
    
    public var intention: ([String : Any]?) -> ()

    public func submit(complete: (() -> ())? = nil) {
        config.queue.async {
            self.intention(self.input)
            complete?()
        }
    }

    public init(intention: @escaping Intention) {
        self.intention = intention
    }
}

public extension Handler {
    
    public func config(_ config: HandlerConfig) -> Handler {
        self.config = config
        return self
    }
    
    public func input(_ input: [String : Any]) -> Handler {
        self.input = input
        return self
    }
}
