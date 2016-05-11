//
//  JWIntentContext.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^JWIntentContextCallBack)(NSDictionary * _Nullable param);

@interface JWIntentContext : NSObject

// moduleName is useful in Swift. We cannot reach the class by className, but moduleName.className in Swift. So if you're doing your stuff with Swift, you have to provide your moduleName.
@property (copy, nonatomic) NSString *moduleName;

// default is "router". Used for identification the action for viewControllers router.
@property (copy, nonatomic) NSString *routerScheme;

// default is "callBack". Used for identification the action for perform-block action.
@property (copy, nonatomic) NSString *callBackScheme;

// singleton
+ (instancetype) sharedContext;

/**
 *  register viewController.
 *
 *  @param vcClassName       the className for target class
 *  @param key               the host for the router, which will be stored as routerScheme://key
 */
+ (void)registerViewController:(NSString*) vcClassName
                        forKey:(NSString*)key;

/**
 *  unregister viewController.
 *
 *  @param key               the host for the router, which will be stored as routerScheme://key
 */
+ (void)removeViewControllerForKey:(NSString*)key;


/**
 *  register block.
 *
 *  @param callBack           the block to be performed.
 *  @param key                the host for the action, which will be stored as callBackScheme://key
 */
+ (void)registerCallBack:(JWIntentContextCallBack) callBack
                  forKey:(NSString*)key;


/**
 *  unregister block.
 *
 *  @param key               the host for the action, which will be stored as callBackScheme://key
 */
+ (void)removeCallBackForKey:(NSString*)key;

@end

@interface NSObject (ExtraData)

@property (strong, nonatomic, nullable) NSDictionary *extraData;

@end

NS_ASSUME_NONNULL_END
