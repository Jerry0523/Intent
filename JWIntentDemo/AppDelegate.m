//
//  AppDelegate.m
//  JWIntentDemo
//
//  Created by Jerry on 16/5/10.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

#import "AppDelegate.h"
#import "JWRouter.h"
#import "JWIntentDemo-Swift.h"

@interface AppDelegate ()

@property (strong, nonatomic) UIAlertController *alertController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self registerRouter];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    JWRouter *intent = [[JWRouter alloc] initWithSource:nil routerKey:@"vc0"];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:intent.destination];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

- (void)registerRouter {
    
    JWIntentContext *defaultContext = [JWIntentContext defaultContext];
    defaultContext.routerScheme = @"router";
    defaultContext.handlerScheme = @"handler";

    [defaultContext registerRouterClass:NSClassFromString(@"JWIntentDemo.ViewController0") forKey:@"vc0"];
    [defaultContext registerRouterClass:NSClassFromString(@"ViewController1") forKey:@"vc1"];
   
    
    __weak typeof(self) weakSelf = self;
    
    [defaultContext registerHandler:^(NSDictionary *param, void (^completion)(void)) {
        NSString *title = param[@"title"];
        NSString *msg = param[@"message"];
        
        __strong typeof(weakSelf) self = weakSelf;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:NULL]];
        
        UIViewController *topVC = self.window.rootViewController;
        while (topVC.presentedViewController) {
            topVC = topVC.presentedViewController;
        }
        [topVC presentViewController:alertController animated:YES completion:completion];
        
    } forKey:@"testAlert"];
}

@end
