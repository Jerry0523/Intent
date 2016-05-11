//
//  JWIntent.m
//  JWIntent
//
//  Created by Jerry on 16/4/22.
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

#import "JWIntent.h"
#import <UIKit/UIKit.h>

@interface JWIntentContext()

+ (nullable NSString*)viewControllerForKey:(NSString*)key;
+ (nullable JWIntentContextCallBack)callBackForKey:(NSString*)key;

@end

@interface JWIntent()

@property (strong, nonatomic) UIViewController *source;
@property (strong, nonatomic) id target;

@end

@implementation JWIntent

#pragma mark - Initialize
- (instancetype)initWithSource:(UIViewController*)source
               targetClassName:(NSString*)targetClassName {
    if (self = [super init]) {
        self.source = source;
        [self p_createTargetVCByClassName:targetClassName];
    }
    return self;
}

- (instancetype)initWithSource:(UIViewController *)source
                     targetURL:(NSString *)targetURLString {
    
    if (self = [super init]) {
        self.source = source;
        NSString *urlEncodedString = [targetURLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *url = [NSURL URLWithString:urlEncodedString];
        
        JWIntentContext *context = [JWIntentContext sharedContext];
        NSString *scheme = url.scheme;
        NSString *query = url.query;
        NSString *key = [NSString stringWithFormat:@"%@://%@", scheme, url.host];
        
        if ([scheme isEqualToString:context.routerScheme]) {
            NSString *targetClassName = [JWIntentContext viewControllerForKey:key];
            [self p_createTargetVCByClassName:targetClassName];
            
        } else if([scheme isEqualToString:context.callBackScheme]) {
            self.target = [JWIntentContext callBackForKey:key];
        }
        [self p_setExtraDataByQueryString:query];
    }
    return self;
}

#pragma mark - PublicAPI
- (void)submit {
    [self submitWithCompletion:nil];
}

- (void)submitWithCompletion:(void (^)(void))completion {
    if ([self.target isKindOfClass:[UIViewController class]]) {
        NSAssert(self.source != nil, @"trying to submit intent with no source");
        [self.target setExtraData:self.extraData];
    }
    
    NSAssert(self.target != nil, @"trying to submit intent with no target");
    [self p_submitActionWithCompletion:completion];
}

#pragma mark - Private
- (void)p_createTargetVCByClassName:(NSString*)className {
    if (className.length) {
        Class class = NSClassFromString(className);
        if (!class && [JWIntentContext sharedContext].moduleName.length) {
            class = NSClassFromString([NSString stringWithFormat:@"%@.%@", [JWIntentContext sharedContext].moduleName, className]);
        }
        if (class) {
            self.target = [[class alloc] init];
        }
    }
}

- (void)p_setExtraDataByQueryString:(NSString*)queryString {
    if (!queryString.length) {
        return;
    }
    queryString = [queryString stringByRemovingPercentEncoding];
    
    NSArray *components = [queryString componentsSeparatedByString:@"&"];
    
    for (NSString *component in components) {
        NSArray *parts = [component componentsSeparatedByString:@"="];
        if (parts.count >= 2) {
            NSString *key = parts[0];
            NSString *value = [component substringFromIndex:key.length + 1];
            if ([key isEqualToString:@"extraData"]) {
                self.extraData = [NSJSONSerialization JSONObjectWithData:[value dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:NULL];
            }
        }
    }
}

- (void)p_submitActionWithCompletion:(void (^)(void))completion {
    switch (self.action) {
        case JWIntentActionAuto: {
            JWIntentAction mAction;
            
            if ([self.target isKindOfClass:[UIViewController class]]) {
                if (self.source.navigationController) {
                    mAction = JWIntentActionPush;
                } else {
                    mAction = JWIntentActionPresent;
                }
            } else {
                mAction = JWIntentActionPerformBlock;
            }
            
            [self p_submitActionWithCompletion:mAction completion:completion];
        }
            break;
        default:
            [self p_submitActionWithCompletion:self.action completion:completion];
            break;
    }
}

- (void)p_submitActionWithCompletion:(JWIntentAction)action completion:(void (^)(void))completion {
    if (action == JWIntentActionPresent) {
        [self.source presentViewController:self.target animated:YES completion:completion];
    } else if(action == JWIntentActionPush) {
        NSAssert(self.source.navigationController != nil, @"%@ does not have navigationController", self.source);
        [self.source.navigationController pushViewController:self.target animated:YES];
        if (completion) {
            completion();
        }
    } else if(action == JWIntentActionPerformBlock) {
        JWIntentContextCallBack callBack = self.target;
        if (callBack) {
            callBack(self.extraData);
        }
        if (completion) {
            completion();
        }
    }
}

@end
