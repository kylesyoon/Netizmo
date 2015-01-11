//
//  MyLogInViewController.m
//  Metwork
//
//  Created by Kyle Yoon on 11/12/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import "MyLogInViewController.h"

@interface MyLogInViewController ()

@end

@implementation MyLogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.logInView setBackgroundColor:[UIColor whiteColor]];
    NSMutableAttributedString *logoString = [[NSMutableAttributedString alloc] initWithString:@"Netizmo"];
    [logoString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0/255.0 green:180.0/255.0 blue:255.0/255.0 alpha:1.0] range:NSMakeRange(0, 3)];
    [logoString addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(3, 4)];
    [logoString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:36.0] range:NSMakeRange(0, 7)];
    UILabel *logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    logoLabel.attributedText = logoString;
    [self.logInView setLogo:logoLabel];
    self.logInView.emailAsUsername = YES;
    
    [self.logInView dismissButton].hidden = YES;
    [self.logInView.logInButton setBackgroundColor:[UIColor colorWithRed:0.0 green:180.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.logInView.logInButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
    
    [self.logInView.passwordForgottenButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
    [self.logInView.passwordForgottenButton setTitleColor:[UIColor colorWithRed:0.0 green:180.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.signUpButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
    [self.logInView.signUpButton setBackgroundColor:[UIColor darkGrayColor]];
    
    self.logInView.usernameField.keyboardType = UIKeyboardTypeEmailAddress;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.logInView.signUpButton setFrame:CGRectMake(0.0, self.view.frame.size.height - self.logInView.logInButton.frame.size.height, self.view.frame.size.width, self.logInView.logInButton.frame.size.height)];
}


@end
