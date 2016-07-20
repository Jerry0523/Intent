//
//  JWRouter.m
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

#import "JWRouter.h"
#import <UIKit/UIKit.h>

@interface JWRouter()

@property (strong, nonatomic) UIViewController *source;
@property (strong, nonatomic) UIViewController *destination;

@end

@implementation JWRouter

@dynamic destination;

- (instancetype)initWithSource:(UIViewController*)source
                     routerKey:(NSString*)routerKey {
    return [self initWithSource:source routerKey:routerKey context:nil];
}

- (instancetype)initWithSource:(UIViewController *)source
                     routerKey:(NSString *)routerKey
                       context:(JWIntentContext *)context {
    if (self = [super init]) {
        self.context = context;
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
    if (self.source.navigationController || [self.source isKindOfClass:[UINavigationController class]]) {
        return JWIntentOptionsPush;
    } else {
        return JWIntentOptionsPresent;
    }
}

- (void)__submitRouterWithCompletion:(void (^)(void))completionBlock {
    UIViewController *sourceViewController = self.source;
    if (self.option & JWIntentOptionsPresent) {
        
        [sourceViewController presentViewController:self.destination
                                           animated:YES
                                         completion:completionBlock];
        
    } else if(self.option & JWIntentOptionsPush) {
        
        UINavigationController *navigationController = [self __autoGetNavigationViewController];
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

- (UINavigationController*)__autoGetNavigationViewController {
    UINavigationController *navigationController = nil;
    if ([self.source isKindOfClass:[UINavigationController class]]) {
        navigationController = (id)self.source;
    } else {
        UIViewController *superViewController = self.source.parentViewController;
        while (superViewController) {
            if ([superViewController isKindOfClass:[UINavigationController class]]) {
                navigationController = (id)superViewController;
                break;
            } else {
                superViewController = superViewController.parentViewController;
            }
        }
    }
    return navigationController;
}

@end
