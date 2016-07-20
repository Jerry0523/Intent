//
//  JWRouter.h
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

#import "JWIntent.h"

@class UIViewController;

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, JWIntentOptions) {
    JWIntentOptionsPresent      = 1 << 0,   //call presentViewController:animated:completion:
    JWIntentOptionsPush         = 2 << 0,   //call pushViewController:animated:
};

@interface JWRouter : JWIntent

@property (assign, nonatomic) JWIntentOptions option;

/**
 *  Init function.
 *
 *  @param source        if not set, will auto iterate window and get a UIViewController to perform router
 *  @param routerKey     used to create destination UIViewController stored in context
 *
 */
- (instancetype)initWithSource:(nullable UIViewController*)source
                     routerKey:(NSString*)routerKey;

/**
 *  Init function.
 *
 *  @param source        if not set, will auto iterate window and get a UIViewController to perform router
 *  @param routerKey     used to create destination UIViewController stored in context
 *  @param context       if NULL, will use default context
 *
 */
- (instancetype)initWithSource:(nullable UIViewController*)source
                     routerKey:(NSString*)routerKey
                       context:(nullable JWIntentContext*)context;

@end

NS_ASSUME_NONNULL_END