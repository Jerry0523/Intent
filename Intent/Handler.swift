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
    
    public static var defaultCtx = IntentCtx<Handler>(scheme: "handler")
    
    public var param: [String : Any]?
    
    public var config: HandlerConfig = .onMainThread
    
    public var executor: Void?
    
    public var intention: (([String : Any]?) -> ())!
    
    public func submit(complete: (() -> ())? = nil) {
        config.preferredQueue().async {
            self.intention?(self.param)
            complete?()
        }
    }
    
    public init() {
        
    }
}
