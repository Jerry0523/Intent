//
//  JWHandler.m
//  JWIntent
//
//  Created by Jerry on 16/7/20.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
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

#import "JWHandler.h"

@interface JWHandler()

@property (copy, nonatomic) JWIntentContextHandler destination;

@end

@implementation JWHandler

@dynamic destination;

- (instancetype)initWithHandlerKey:(NSString*)handlerKey {
    return [self initWithHandlerKey:handlerKey context:nil];
}

- (instancetype)initWithHandlerKey:(NSString*)handlerKey
                           context:(nullable JWIntentContext*)context {
    if (self = [super init]) {
        self.context = context;
        self.destination = [self.context handlerForKey:handlerKey];
    }
    return self;
}

- (void)submitWithCompletion:(void (^)(void))completion {
    [super submitWithCompletion:completion];
    
    JWIntentContextHandler block = (JWIntentContextHandler)self.destination;
    block(self.extraData, completion);
}

@end
