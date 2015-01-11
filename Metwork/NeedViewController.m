//
//  NeedViewController.m
//  Metwork
//
//  Created by Kyle Yoon on 11/11/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import "NeedViewController.h"
#import "UsersTableViewController.h"
#import "BLECentral.h"
#import "BLEPeripheral.h"
#import "MWUser.h"

@interface NeedViewController () <UITextViewDelegate>

@property BLECentral *BLECentral;
@property BLEPeripheral *BLEPeripheral;
@property CGPoint originalCenter;
@property (weak, nonatomic) IBOutlet UILabel *textViewLimitLabel;
@property (weak, nonatomic) IBOutlet UITextView *needTextView;

@end

@implementation NeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.originalCenter = self.view.center;
    self.needTextView.delegate = self;

    //Previous need is displayed.
    self.needTextView.text = [MWUser currentUser].need;
    self.textViewLimitLabel.text = [NSString stringWithFormat:@"%lu/100", (unsigned long)self.needTextView.text.length];
    [self registerForKeyboardNotifications];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}


#pragma mark - Keyboard methods

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification *)keyboardNotification {
//    NSDictionary *keyboardInfo = [keyboardNotification userInfo];
//    CGSize keyboardSize = [[keyboardInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.15 animations:^{
        self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y - 90);
    }];
}

- (void)keyboardWillBeHidden:(NSNotification *)keyboardNotification {
    [UIView animateWithDuration:0.15 animations:^{
        self.view.center = self.originalCenter;
    }];
}

- (void)dismissKeyboard {
    [self.needTextView resignFirstResponder];
}

#pragma mark - Max char. count method

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    self.textViewLimitLabel.text = [NSString stringWithFormat:@"%lu/100", (unsigned long)newLength];
    if (newLength > 100) {
        self.textViewLimitLabel.text = @"100/100";
    }
    return (newLength <= 100);
}

#pragma mark - BLE methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UsersTableViewController *usersTableViewController = segue.destinationViewController;
    usersTableViewController.BLEPeripheral = self.BLEPeripheral;
    usersTableViewController.BLECentral = self.BLECentral;
    [self.needTextView resignFirstResponder];
}

- (IBAction)onNextTapped:(id)sender {
    if (self.needTextView.text.length == 0) {
        UIAlertController *needRequiredAlert = [UIAlertController alertControllerWithTitle:@"Missing Information" message:@"Let others what you are looking for at this event, even if it's just fun!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [needRequiredAlert dismissViewControllerAnimated:YES completion:nil];
        }];
        [needRequiredAlert addAction:okayAction];
        [self presentViewController:needRequiredAlert animated:YES completion:nil];
        return;
    }
    [MWUser currentUser].need = [self.needTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [[MWUser currentUser] saveInBackgroundWithBlock:nil];
    self.BLECentral = [BLECentral sharedInstance];
    self.BLEPeripheral = [BLEPeripheral sharedInstance];
    [self.BLECentral startScanning];
    [self.BLEPeripheral startAdvertising];
    [self performSegueWithIdentifier:@"startNetworkingSegue" sender:nil];
}

- (IBAction)onCancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.BLEPeripheral stopAdvertising];
    [self.BLECentral stopScanning];
}

@end
