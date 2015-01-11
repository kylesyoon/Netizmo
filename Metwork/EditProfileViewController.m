//
//  ProfilePictureViewController.m
//  Metwork
//
//  Created by Kyle Yoon on 11/12/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import "EditProfileViewController.h"
#import "MWUser.h"

@interface EditProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *jobTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *companyTextField;
@property (weak, nonatomic) IBOutlet UITextField *skillOneTextField;
@property (weak, nonatomic) IBOutlet UITextField *skillTwoTextField;
@property (weak, nonatomic) IBOutlet UITextField *skillThreeTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property UITextField *activeField;
@property (weak, nonatomic) IBOutlet UILabel *textViewLimitLabel;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
    self.textView.delegate = self;
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    self.jobTitleTextField.delegate = self;
    self.companyTextField.delegate = self;
    self.skillOneTextField.delegate = self;
    self.skillTwoTextField.delegate = self;
    self.skillThreeTextField.delegate = self;
    
    MWUser *user = [MWUser currentUser];
    if (user.profileImageFile) {
        [user.profileImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error) {
                NSLog(@"Getting data for profile image error: %@", error);
            } else {
                self.imageView.image = [UIImage imageWithData:data];
            }
        }];
    } else {
        //If there is no profile image, show default.
        self.imageView.image = [UIImage imageNamed:@"defaultProfile"];
    }
    self.firstNameTextField.text = user.firstName;
    self.lastNameTextField.text = user.lastName;
    self.textView.text = user.shortDescription;
    self.jobTitleTextField.text = user.jobTitle;
    self.companyTextField.text = user.company;
    self.skillOneTextField.text = user.skillOne;
    self.skillTwoTextField.text = user.skillTwo;
    self.skillThreeTextField.text = user.skillThree;
    self.textViewLimitLabel.text = [NSString stringWithFormat:@"%lu/90", (unsigned long)self.textView.text.length];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidLayoutSubviews {
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2;
    self.imageView.clipsToBounds = YES;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 780);
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
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
    NSLog(@"delegate textfield: %@", textField);
    NSLog(@"Activefield : %@", self.activeField);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    self.textViewLimitLabel.text = [NSString stringWithFormat:@"%lu/90", (unsigned long)newLength];
    if (newLength > 90) {
        self.textViewLimitLabel.text = @"90/90";
    }
    return (newLength <= 90);
}

- (IBAction)onChangeTapped:(id)sender {
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Change your profile picture" message:@"Choose a photo that others can easily identify you by." preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take a photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertController *noCameraAlert = [UIAlertController alertControllerWithTitle:@"No camera detected" message:@"You can only choose this option with a device that has a camera." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [noCameraAlert dismissViewControllerAnimated:YES completion:nil];
            }];
            [noCameraAlert addAction:okayAction];
            [self presentViewController:noCameraAlert animated:YES completion:nil];
        } else {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.imagePicker animated:YES completion:nil];
        }
    }];
    UIAlertAction *choosePhotoFromLibrary = [UIAlertAction actionWithTitle:@"Choose photo from Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:takePhotoAction];
    [alertController addAction:choosePhotoFromLibrary];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(selectedImage, 0.1f);
    PFFile *imageFile = [PFFile fileWithName:@"profile" data:imageData];
    [MWUser currentUser].profileImageFile = imageFile;
    [[MWUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Image saving error: %@", error);
        } else {
            self.imageView.image = selectedImage;
        }
    }];
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSaveTapped:(id)sender {
    [self dismissKeyboard];
    MWUser *user = [MWUser currentUser];
    user.firstName = [self.firstNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];;
    user.lastName = [self.lastNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    user.shortDescription = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    user.jobTitle = [self.jobTitleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    user.company = [self.companyTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    user.skillOne = [self.skillOneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    user.skillTwo = [self.skillTwoTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    user.skillThree = [self.skillThreeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"User profile edit saving error: %@", error);
        } else {
            NSLog(@"Save successful");
            UIAlertView *savedChanges = [[UIAlertView alloc] initWithTitle:@"Saved Changes" message:@"Your changes have been saved." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [savedChanges show];
        }
    }];
}

@end
