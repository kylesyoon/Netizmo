//
//  PrivacyPolicyViewController.m
//  Netizmo
//
//  Created by Kyle Yoon on 12/5/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import "PrivacyPolicyViewController.h"

@interface PrivacyPolicyViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation PrivacyPolicyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
    [self loadPrivacyPolicyPage];
}

- (void)loadPrivacyPolicyPage {
    NSString *privacyPolicyURLString = @"https://www.iubenda.com/privacy-policy/806068";
    NSURL *url = [NSURL URLWithString:privacyPolicyURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
