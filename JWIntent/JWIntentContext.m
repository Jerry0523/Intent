//
//  JWIntentContext.m
//  JWIntentDemo
//
//  Created by Jerry on 16/5/10.
//  copyright (c) 2016 Jerry Wong jerrywong0523@icloud.com
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

#import "JWIntentContext.h"
#import <objc/runtime.h>

@implementation JWIntentContext {
    NSMutableDictionary *_callBackDict;
    NSMutableDictionary *_routerDict;
}

+ (instancetype) defaultContext {
    static dispatch_once_t once;
    static JWIntentContext * _singleton;
    dispatch_once(&once, ^{
        _singleton = [[self alloc] init];
    });
    return _singleton;
}

- (instancetype)init {
    if (self = [super init]) {
        self.routerScheme = @"router";
        self.callBackScheme = @"callBack";
        
        _callBackDict = @{}.mutableCopy;
        _routerDict = @{}.mutableCopy;
    }
    return self;
}

- (void)registerViewControllerClassName:(NSString*) vcClassName
                        forKey:(NSString*)key {
    @synchronized (_routerDict) {
        [_routerDict setObject:vcClassName forKey:[NSString stringWithFormat:@"%@://%@", self.routerScheme, key]];
    }
    
}

- (void)removeViewControllerClassNameForKey:(NSString*)key {
    @synchronized (_routerDict) {
        [_routerDict removeObjectForKey:[NSString stringWithFormat:@"%@://%@", self.routerScheme, key]];
    }
}

- (NSString*)viewControllerClassNameForKey:(NSString *)key {
    @synchronized (_routerDict) {
        return [_routerDict objectForKey:key];
    }
}

- (void)registerCallBack:(JWIntentContextCallBack) callBack
                  forKey:(NSString*)key {
    @synchronized (_callBackDict) {
        NSString *callBackKey = [NSString stringWithFormat:@"%@://%@", self.callBackScheme, key];
        [_callBackDict setObject:callBack forKey:callBackKey];
    }
}

- (void)removeCallBackForKey:(NSString*)key {
    @synchronized (_callBackDict) {
        NSString *callBackKey = [NSString stringWithFormat:@"%@://%@", self.callBackScheme, key];
        [_callBackDict removeObjectForKey:callBackKey];
    }
}

- (JWIntentContextCallBack)callBackForKey:(NSString*)key {
    @synchronized (_callBackDict) {
       return [_callBackDict objectForKey:key];
    }
}

@end

@implementation NSObject (ExtraData)

- (void)setExtraData:(NSDictionary*)extraData {
    if (extraData) {
        objc_setAssociatedObject(self, objc_unretainedPointer(self), extraData,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (NSDictionary*)extraData {
    return objc_getAssociatedObject(self, objc_unretainedPointer(self));
}

@end
