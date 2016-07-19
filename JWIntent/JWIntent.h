//
//  JWIntent.h
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

#import "JWIntentContext.h"

typedef NS_OPTIONS(NSUInteger, JWIntentOptions) {
    JWIntentOptionsPresent      = 1 << 0,
    JWIntentOptionsPush         = 2 << 0,
};

NS_ASSUME_NONNULL_BEGIN

@class UIViewController;

@interface JWIntent : NSObject

@property (strong, nonatomic, readonly) id destination;

/**
 *  the parameter passed by intent. 
 *  In target viewController, you can get extraData by calling self.extraData.
 *  In block, it will be passed to block input params.
 *
 */
@property (strong, nonatomic, nullable) NSDictionary *extraData;

/**
 *  if not set, will use [JWIntentContext defaultContext]
 *
 */
@property (strong, nonatomic, null_resettable) JWIntentContext *context;


@property (assign, nonatomic) JWIntentOptions option;

/**
 *  Init function.
 *
 *  @param destinationURLString
 *  @param context
 *
 *  destinationURLString contains action,extraData.
 *  e.g. "router://testHost?extraData={\"name\":\"Jerry\"}"
 *  The scheme "router" is equal to JWIntentContext.routerScheme, so we know that it's a router action.
 *  The host "testHost" indicates targetClassName, which is registered by the class or app loaded in JWIntentContext mannually.
 *  The query part(formatted "extraData={}") indicates the json value of extraData, which will be translated and set automatically.
 *  Similarlly, if scheme is equal to JWIntentContext.handlerScheme, we know that it's a perform-block action.
 */
+ (instancetype)intentWithURLString:(NSString*)destinationURLString
                            context:(nullable JWIntentContext*)context;

/**
 *  submit the action
 */
- (void)submit;

/**
 *  submit the action with a completion block.
 */
- (void)submitWithCompletion:(void (^ __nullable)(void))completionBlock;

@end

@interface JWRouter : JWIntent

/**
 *  Init function.
 *
 *  @param source        if not set, will auto iterate window and get a UIViewController to perform router
 *  @param routerKey     used to create destination UIViewController stored in context
 *
 */
- (instancetype)initWithSource:(nullable UIViewController*)source
                     routerKey:(NSString*)routerKey;

@end

@interface JWHandler : JWIntent

/**
 *  Init function.
 *
 *  @param handlerKey     used to create destination handler stored in context
 *
 */
- (instancetype)initWithHandlerKey:(NSString*)handlerKey;

@end

NS_ASSUME_NONNULL_END
