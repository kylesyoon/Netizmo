//
//  MySignUpViewController.m
//  Metwork
//
//  Created by Kyle Yoon on 11/12/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import "MySignUpViewController.h"

@interface MySignUpViewController ()

@end

@implementation MySignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.signUpView setBackgroundColor:[UIColor whiteColor]];
    NSMutableAttributedString *logoString = [[NSMutableAttributedString alloc] initWithString:@"Netizmo"];
    [logoString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0/255.0 green:180.0/255.0 blue:255.0/255.0 alpha:1.0] range:NSMakeRange(0, 3)];
    [logoString addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(3, 4)];
    [logoString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:36.0] range:NSMakeRange(0, 7)];
    UILabel *logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    logoLabel.attributedText = logoString;
    [self.signUpView setLogo:logoLabel];
    
    self.signUpView.emailAsUsername = YES;
    self.signUpView.usernameField.keyboardType = UIKeyboardTypeEmailAddress;
    
    [self.signUpView.additionalField setEnabled:YES];
    [self.signUpView.additionalField setPlaceholder:@"Confirm Password"];
    self.signUpView.additionalField.secureTextEntry = YES;
    
    [self.signUpView.signUpButton setBackgroundColor:[UIColor colorWithRed:0.0 green:180.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.signUpView.signUpButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.signUpView.additionalField setFrame:CGRectMake(self.signUpView.passwordField.frame.origin.x, self.signUpView.passwordField.frame.origin.y + self.signUpView.passwordField.frame.size.height, self.signUpView.passwordField.frame.size.width, self.signUpView.passwordField.frame.size.height)];
}



@end
