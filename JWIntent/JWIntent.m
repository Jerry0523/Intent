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
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@interface JWIntent()

@property (strong, nonatomic) id source;
@property (strong, nonatomic) id destination;

@end

@implementation JWIntent

#pragma mark - Initialize
+ (instancetype)intentWithURLString:(NSString*)destinationURLString
                            context:(JWIntentContext*)context {
    
    if (!context) {
        context = [JWIntentContext defaultContext];
    }
    
    NSString *urlEncodedString = [destinationURLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlEncodedString];
    NSString *scheme = url.scheme;
    NSString *query = url.query;
    NSString *host = url.host;
    
    JWIntent *aIntent = nil;
    if ([scheme isEqualToString:context.routerScheme]) {
        aIntent = [[JWRouter alloc] initWithSource:nil routerKey:host];
    } else if([scheme isEqualToString:context.handlerScheme]) {
        aIntent = [[JWHandler alloc] initWithHandlerKey:host];
    }
    
    if (aIntent) {
        [aIntent __setExtraDataByQueryString:query];
    }
    return aIntent;
}

#pragma mark - PublicAPI
- (void)submit {
    [self submitWithCompletion:nil];
}

- (void)submitWithCompletion:(void (^)(void))completionBlock {
    NSAssert(self.destination, @"Trying to submit intent with no destination");
}

#pragma mark - Getter & Setter
- (JWIntentContext*)context {
    if (!_context) {
        return [JWIntentContext defaultContext];
    }
    return _context;
}

#pragma mark - Private
- (void)__setExtraDataByQueryString:(NSString*)queryString {
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
                self.extraData = [NSJSONSerialization JSONObjectWithData:[value dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options:NSJSONReadingMutableLeaves
                                                                   error:NULL];
            }
        }
    }
}

@end

@implementation JWRouter

- (instancetype)initWithSource:(nullable id)source
                     routerKey:(NSString*)routerKey {
    if (self = [super init]) {
        self.source = source;
        Class routerClass = [self.context routerClassForKey:routerKey];
        if (routerClass) {
            self.destination = [[routerClass alloc] init];
        }
    }
    return self;
}

- (void)submitWithCompletion:(void (^)(void))completionBlock {
    [super submitWithCompletion:completionBlock];
    
    if (!self.source) {
        self.source = [self __autoGetRootSourceViewController];
    }
    
    if (!(self.option & JWIntentOptionsPresent ||
          self.option & JWIntentOptionsPush)) {
        self.option = self.option | [self __autoGetActionOptions];
    }
    
    [self __submitRouterWithCompletion:completionBlock];
}

- (void)setExtraData:(NSDictionary *)extraData {
    [super setExtraData:extraData];
    if ([self.destination isKindOfClass:[NSObject class]]) {
        ((NSObject*)self.destination).extraData = extraData;
    }
}

#pragma mark - Private
- (JWIntentOptions)__autoGetActionOptions {
    if (![self.source isKindOfClass:[UIViewController class]]) {
        return 0;
    }
    
    UIViewController *sourceViewController = self.source;
    
    if (sourceViewController.navigationController || [sourceViewController isKindOfClass:[UINavigationController class]]) {
        return JWIntentOptionsPush;
    } else {
        return JWIntentOptionsPresent;
    }
}

- (void)__submitRouterWithCompletion:(void (^)(void))completionBlock {
    UIViewController *sourceViewController = self.source;
    if (self.option & JWIntentOptionsPresent) {
        [sourceViewController presentViewController:self.destination animated:YES completion:completionBlock];
    } else if(self.option & JWIntentOptionsPush) {
        UINavigationController *navigationController = nil;
        if ([sourceViewController isKindOfClass:[UINavigationController class]]) {
            navigationController = (id)sourceViewController;
        } else {
            UIViewController *superViewController = sourceViewController.parentViewController;
            while (superViewController) {
                if ([superViewController isKindOfClass:[UINavigationController class]]) {
                    navigationController = (id)superViewController;
                    break;
                } else {
                    superViewController = superViewController.parentViewController;
                }
            }
        }
        
        NSAssert(navigationController, @"Trying to submit push action with no navigationController");
        [navigationController pushViewController:self.destination animated:YES];
        if (completionBlock) {
            completionBlock();
        }
    }
}

- (UIViewController*)__autoGetRootSourceViewController {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *topVC = keyWindow.rootViewController;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

@end

@implementation JWHandler

- (instancetype)initWithHandlerKey:(NSString*)handlerKey {
    if (self = [super init]) {
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
