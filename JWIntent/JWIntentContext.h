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

typedef void(^JWIntentContextCallBack)(NSDictionary * _Nullable param,  void (^ _Nullable completion)(void));

@interface JWIntentContext : NSObject

// moduleName is useful in Swift. We cannot reach the class by className, but moduleName.className in Swift. So if you're doing your stuff with Swift, you have to provide your moduleName.
@property (copy, nonatomic) NSString *moduleName;

// default is "router". Used for identification the action for viewControllers router.
@property (copy, nonatomic) NSString *routerScheme;

// default is "callBack". Used for identification the action for perform-block action.
@property (copy, nonatomic) NSString *callBackScheme;

// singleton
+ (instancetype) defaultContext;

/**
 *  register viewController.
 *
 *  @param vcClassName       the className for target class
 *  @param shortKey          the host for the router,shortKey,e.g., "login", which will be stored as routerScheme://key
 */
- (void)registerViewControllerClassName:(NSString*) vcClassName
                                 forKey:(NSString*)shortKey;

/**
 *  unregister viewController.
 *
 *  @param key               shortKey
 */
- (void)removeViewControllerClassNameForKey:(NSString*)shortKey;


/**
 *  register block.
 *
 *  @param callBack           the block to be performed.
 *  @param shortKey           the host for the action,shortKey,e.g.,"action", which will be stored as callBackScheme://key
 */
- (void)registerCallBack:(JWIntentContextCallBack) callBack
                  forKey:(NSString*)shortKey;


/**
 *  unregister block.
 *
 *  @param key               shortKey
 */
- (void)removeCallBackForKey:(NSString*)shortKey;

/**
 *  get the regist viewcontroller class name.
 *
 *  @param key               the full key,e.g.,"routerScheme://key"
 */
- (nullable NSString*)viewControllerClassNameForKey:(NSString *)fullKey;

/**
 *  get the regist callback block
 *
 *  @param key               the full key,e.g.,"callBackScheme://key"
 */
- (nullable JWIntentContextCallBack)callBackForKey:(NSString*)fullKey;

@end

@interface NSObject (ExtraData)

@property (strong, nonatomic, nullable) NSDictionary *extraData;

@end

NS_ASSUME_NONNULL_END
