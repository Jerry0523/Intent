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

@interface JWIntent()

@property (strong, nonatomic) UIViewController *source;
@property (strong, nonatomic) id target;

@end

@implementation JWIntent {
    NSString *_targetClassName;
    NSString *_targetURLString;
}

#pragma mark - Initialize
- (instancetype)initWithSource:(UIViewController*)source
               targetClassName:(NSString*)targetClassName {
    if (self = [super init]) {
        self.source = source;
        _targetClassName = targetClassName;
    }
    return self;
}

- (instancetype)initWithSource:(UIViewController *)source
               targetURLString:(NSString *)targetURLString {
    
    if (self = [super init]) {
        self.source = source;
        _targetURLString = targetURLString;
    }
    return self;
}

#pragma mark - PublicAPI
- (BOOL)submit {
    return [self submitWithCompletion:nil];
}

- (BOOL)submitWithCompletion:(void (^)(void))completion {
    if (!self.target) {
        NSLog(@"trying to submit intent with no target");
        return NO;
    }
    
    if ([self.target isKindOfClass:[UIViewController class]]) {
        if (!self.source) {
            NSLog(@"trying to submit intent with no source");
            return NO;
        }
        [self.target setExtraData:self.extraData];
    }
    
    return [self _submitActionWithCompletion:completion];
}

#pragma mark - Getter & Setter
- (JWIntentContext*)context {
    if (!_context) {
        return [JWIntentContext defaultContext];
    }
    return _context;
}

- (id)target {
    if (!_target) {
        if (_targetClassName) {
            [self _createTargetVCByClassName:_targetClassName];
        } else if(_targetURLString) {
            [self _createTargetByURLString:_targetURLString];
        }
    }
    return _target;
}

#pragma mark - Private
- (void)_createTargetVCByClassName:(NSString*)className {
    if (className.length) {
        Class class = NSClassFromString(className);
        if (!class && self.context.moduleName.length) {
            class = NSClassFromString([NSString stringWithFormat:@"%@.%@", self.context.moduleName, className]);
        }
        if (class) {
            _target = [[class alloc] init];
        }
    }
}

- (void)_createTargetByURLString:(NSString*)urlString {
    NSString *urlEncodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlEncodedString];
    
    NSString *scheme = url.scheme;
    NSString *query = url.query;
    NSString *key = [NSString stringWithFormat:@"%@://%@", scheme, url.host];
    
    if ([scheme isEqualToString:self.context.routerScheme]) {
        NSString *targetClassName = [self.context viewControllerClassNameForKey:key];
        [self _createTargetVCByClassName:targetClassName];
        
    } else if([scheme isEqualToString:self.context.callBackScheme]) {
        _target = [self.context callBackForKey:key];
    }
    [self _setExtraDataByQueryString:query];
}

- (void)_setExtraDataByQueryString:(NSString*)queryString {
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

- (BOOL)_submitActionWithCompletion:(void (^)(void))completion {
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
            
            return [self _submitActionWithCompletion:mAction completion:completion];
        }
            break;
        default:
            return [self _submitActionWithCompletion:self.action completion:completion];
            break;
    }
}

- (BOOL)_submitActionWithCompletion:(JWIntentAction)action completion:(void (^)(void))completion {
    if (action == JWIntentActionPresent) {
        [self.source presentViewController:self.target animated:YES completion:completion];
        return YES;
    } else if(action == JWIntentActionPush) {
        if (!self.source.navigationController) {
            NSLog(@"%@ does not have navigationController", self.source);
            return NO;
        }
        [self.source.navigationController pushViewController:self.target animated:YES];
        if (completion) {
            completion();
        }
        return YES;
    } else if(action == JWIntentActionPerformBlock) {
        JWIntentContextCallBack callBack = self.target;
        if (callBack) {
            callBack(self.extraData, completion);
        }
        return YES;
    }
    
    return NO;
}

@end
