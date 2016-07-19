//
//  ViewController1.m
//  JWIntentDemo
//
//  Created by Jerry on 16/5/10.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

#import "ViewController1.h"
#import "JWIntent.h"

@interface ViewController1 ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation ViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"VC1";
    
    NSDictionary *extraData = self.extraData;
    
    self.textLabel.textColor = extraData[@"textColor"] ?: [UIColor blackColor];
    self.textLabel.text = extraData[@"stringValue"];
    self.view.backgroundColor = extraData[@"backgroundColor"] ?: [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)presentVC1:(id)sender {
    JWRouter *intent = [[JWRouter alloc] initWithSource:self
                                              routerKey:@"vc0"];
    [intent submit];
}

- (void)dealloc {
    NSLog(@"dealloc");
}

@end
