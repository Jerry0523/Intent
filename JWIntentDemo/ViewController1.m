//
//  ViewController1.m
//  JWIntentDemo
//
//  Created by Jerry on 16/5/10.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

#import "ViewController1.h"
#import "JWRouter.h"

@interface ViewController1 ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@end

@implementation ViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"VC1";
    
    NSDictionary *extraData = self.extraData;
    
    self.textLabel.textColor = extraData[@"textColor"] ?: [UIColor blackColor];
    self.textLabel.text = extraData[@"stringValue"];
    self.view.backgroundColor = extraData[@"backgroundColor"] ?: [UIColor whiteColor];
    
    self.closeButton.hidden = (self.navigationController != nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)presentVC1:(id)sender {
    JWRouter *intent = [[JWRouter alloc] initWithSource:self
                                              routerKey:@"vc0"];
    [intent submit];
}

- (IBAction)didPressDismissButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    NSLog(@"dealloc");
}

@end
