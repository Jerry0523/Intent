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

typedef void(^JWIntentContextHandler)(NSDictionary * _Nullable param,  void (^ _Nullable completion)(void));

@interface JWIntentContext : NSObject

@property (strong, nonatomic) NSString *routerScheme;//default is app bundleDentifier append string ".router"
@property (strong, nonatomic) NSString *handlerScheme;//default is app bundleDentifier append string ".func"

/**
 *  singleton
 *
 */
+ (instancetype) defaultContext;

@end

@interface JWIntentContext(Handler)

/**
 *  register handler, register block with key so that we can perform block via the prescribed key
 *
 *  @param handler
 *  @param key
 *
 */
- (void)registerHandler:(JWIntentContextHandler)handler
                 forKey:(NSString*)key;

/**
 *  unregister handler with key
 *
 *  @param key
 *
 */
- (void)unRegisterHandlerForKey:(NSString*)key;

/**
 *  get handler with key
 *
 *  @param key
 *
 */
- (_Nullable JWIntentContextHandler)handlerForKey:(NSString*)key;

@end

@interface JWIntentContext(Router)

/**
 *  register view controller class so that we can router to it
 *
 *  @param aClass UIViewController subclass
 *  @param key
 *
 */
- (void)registerRouterClass:(Class)aClass
                     forKey:(NSString*)key;

/**
 *  unregister router with key
 *
 *  @param key
 *
 */
- (void)unRegisterRouterClassForKey:(NSString*)key;

/**
 *  get uiviewcontroller class with key
 *
 *  @param key
 *
 */
- (_Nullable Class)routerClassForKey:(NSString*)key;

@end

@interface NSObject (ExtraData)

@property (strong, nonatomic, nullable) NSDictionary *extraData;

@end

NS_ASSUME_NONNULL_END
