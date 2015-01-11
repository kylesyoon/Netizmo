//
//  TermsViewController.m
//  Netizmo
//
//  Created by Kyle Yoon on 12/16/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import "TermsViewController.h"

@interface TermsViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
    [self loadTermsOfUse];
}

- (void)loadTermsOfUse {
    NSString *termsURLString = @"http://netizmo.com/terms.html";
    NSURL *termsURL = [NSURL URLWithString:termsURLString];
    NSURLRequest *termsRequest = [NSURLRequest requestWithURL:termsURL];
    [self.webView loadRequest:termsRequest];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
