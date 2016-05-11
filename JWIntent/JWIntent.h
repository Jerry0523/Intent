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

@class UIViewController;

typedef NS_ENUM(NSInteger, JWIntentAction) {
    JWIntentActionAuto    = 0,            // automatically choose an action
    
    JWIntentActionPresent,                //call presentViewController:animated:completion
    JWIntentActionPush,                   //call pushViewController:animated
    JWIntentActionPerformBlock,           //perform block stored in JWIntentContext
};

NS_ASSUME_NONNULL_BEGIN

@interface JWIntent : NSObject

// the parameter passed by intent. In target viewController, you can get extraData by calling self.extraData. In block, it will be passed to block input params.
@property (strong, nonatomic, nullable) NSDictionary *extraData;

@property (assign, nonatomic) JWIntentAction action;    //default is JWIntentActionAuto

/**
 *  Init function.
 *
 *  @param source                   perform the action from source
 *  @param targetClassName          target ViewController class name.
 */
- (instancetype)initWithSource:(UIViewController*) source
               targetClassName:(NSString*) targetClassName;

/**
 *  Init function.
 *
 *  @param source                   perform the action from source
 *  @param targetURLString          targetURLString contains action,extraData. e.g. "router://testHost?extraData={\"name\":\"Jerry\"}" The scheme "router" is equal to JWIntentContext.routerScheme, so we know that it's a router action. The host "testHost" indicates targetClassName, which is registered by the class or app loaded in JWIntentContext mannually. The query part(formatted "extraData={}") indicates the json value of extraData, which will be translated and set automatically. Similarlly, if scheme is equal to JWIntentContext.callBackScheme, we know that it's a perform-block action.
 */
- (instancetype)initWithSource:(UIViewController*) source
               targetURL:(NSString*) targetURLString;

/**
 *  submit the action
 */
- (void)submit;

/**
 *  submit the action with a completion block.
 */
- (void)submitWithCompletion:(void (^ __nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
