//
//  BasicInfoViewController.m
//  Metwork
//
//  Created by Kyle Yoon on 11/14/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import "SetUpBasicInfoViewController.h"
#import "MWUser.h"

@interface SetUpBasicInfoViewController () <UIScrollViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *jobTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *companyTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property UITextField *activeField;

@end

@implementation SetUpBasicInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    self.jobTitleTextField.delegate = self;
    self.companyTextField.delegate = self;
    self.activeField.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidLayoutSubviews {
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 570);
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification *)aNotification {
    NSLog(@"CALLED");
    NSLog(@"Active field is: %@", self.activeField);
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

- (IBAction)onDoneTapped:(id)sender {
    if (self.firstNameTextField.text.length != 0 && self.lastNameTextField.text.length != 0 && self.jobTitleTextField.text.length != 0 && self.companyTextField.text.length) {
        MWUser *user = [MWUser currentUser];
        user.firstName = [self.firstNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        user.lastName = [self.lastNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        user.jobTitle = [self.jobTitleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        user.company = [self.companyTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"User basic info saving error: %@", error);
            } else {
                NSLog(@"Successful save");
            }
        }];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIAlertView *missingInfoAlert = [[UIAlertView alloc] init];
        missingInfoAlert.title = @"Missing Information";
        missingInfoAlert.message = @"Please make sure you have filled out all fields.";
        [missingInfoAlert addButtonWithTitle:@"Okay"];
        [missingInfoAlert show];
    }
}

- (void)dismissKeyboard {
    NSLog(@"Gesture action called");
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.firstNameTextField) {
        [self.firstNameTextField resignFirstResponder];
        [self.lastNameTextField becomeFirstResponder];
    } else if (textField == self.lastNameTextField) {
        [self.lastNameTextField resignFirstResponder];
        [self.jobTitleTextField becomeFirstResponder];
    } else if (textField == self.jobTitleTextField) {
        [self.jobTitleTextField resignFirstResponder];
        [self.companyTextField becomeFirstResponder];
    } else {
        [self.companyTextField resignFirstResponder];
        [self onDoneTapped:nil];
    }
    return YES;
}


@end
