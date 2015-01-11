//
//  MWTableViewController.m
//  Metwork
//
//  Created by Kyle Yoon on 11/5/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import "ProfileViewController.h"
#import "MWUser.h"
#import "MyLogInViewController.h"
#import "MySignUpViewController.h"
#import "SettingsTableViewController.h"
#import "EditProfileViewController.h"

@interface ProfileViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property MWUser *user;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *shortDescriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *skillOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *skillTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *skillThreeLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobTitleAndCompanyLabel;
@property (weak, nonatomic) IBOutlet UILabel *topSkillsLabel;
@property BOOL isEditLabelTapped;

@end

@implementation ProfileViewController

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    if (![MWUser currentUser]) {
        NSLog(@"No current user");
        MyLogInViewController *logInViewController = [[MyLogInViewController alloc] init];
        logInViewController.delegate = self;
        MySignUpViewController *signUpViewController = [[MySignUpViewController alloc] init];
        signUpViewController.delegate = self;
        [signUpViewController setFields:PFSignUpFieldsDefault | PFSignUpFieldsAdditional];
        [logInViewController setSignUpController:signUpViewController];
        [self presentViewController:logInViewController animated:YES completion:nil];
        return;
    }
    self.isEditLabelTapped = NO;
    //Show available user information.
    self.user = [MWUser currentUser];
    if ((!self.user.firstName && !self.user.lastName) || ([self.user.firstName isEqualToString:@""] && [self.user.lastName isEqualToString:@""])) {
        NSLog(@"No name");
        self.fullNameLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.fullNameLabel.text = @" Your name ";
        UITapGestureRecognizer *emptyNameTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onEmptyLabelTapped:)];
        emptyNameTap.numberOfTapsRequired = 1;
        self.fullNameLabel.userInteractionEnabled = YES;
        [self.fullNameLabel addGestureRecognizer:emptyNameTap];
    } else {
        self.fullNameLabel.backgroundColor = nil;
        self.fullNameLabel.gestureRecognizers = nil;
        if (!self.user.firstName || [self.user.firstName isEqualToString:@""]) {
            self.fullNameLabel.text = self.user.lastName;
        } else if (!self.user.lastName || [self.user.lastName isEqualToString:@""]) {
            self.fullNameLabel.text = self.user.firstName;
        } else {
            self.fullNameLabel.text = [self.user.firstName stringByAppendingString:[NSString stringWithFormat:@" %@", self.user.lastName]];
        }
    }
    if ((!self.user.jobTitle && !self.user.company) || ([self.user.jobTitle isEqualToString:@""] && [self.user.company isEqualToString:@""])) {
        self.jobTitleAndCompanyLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.jobTitleAndCompanyLabel.text = @" Your job title and company ";
        UITapGestureRecognizer *emptyJobCompanyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onEmptyLabelTapped:)];
        emptyJobCompanyTap.numberOfTapsRequired = 1;
        [self.jobTitleAndCompanyLabel addGestureRecognizer:emptyJobCompanyTap];
        self.jobTitleAndCompanyLabel.userInteractionEnabled = YES;
    } else if (!self.user.company || [self.user.company isEqualToString:@""]) {
        self.jobTitleAndCompanyLabel.gestureRecognizers = nil;
        self.jobTitleAndCompanyLabel.backgroundColor = nil;
        self.jobTitleAndCompanyLabel.text = self.user.jobTitle;
    } else {
        self.jobTitleAndCompanyLabel.gestureRecognizers = nil;
        self.jobTitleAndCompanyLabel.backgroundColor = nil;
        self.jobTitleAndCompanyLabel.text = [self.user.jobTitle stringByAppendingString:[NSString stringWithFormat:@" at %@", self.user.company]];
    }
    if (!self.user.shortDescription || [self.user.shortDescription isEqualToString:@""]) {
        self.shortDescriptionTextView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.shortDescriptionTextView.text = @"Tap to add a short description about yourself.";
        UITapGestureRecognizer *emptyDescriptionTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onEmptyLabelTapped:)];
        emptyDescriptionTap.numberOfTapsRequired = 1;
        [self.shortDescriptionTextView addGestureRecognizer:emptyDescriptionTap];
        self.shortDescriptionTextView.userInteractionEnabled = YES;
    } else {
        self.shortDescriptionTextView.gestureRecognizers = nil;
        self.shortDescriptionTextView.backgroundColor = nil;
        self.shortDescriptionTextView.text = self.user.shortDescription;
    }
    if (!self.user.skillOne || [self.user.skillOne isEqualToString:@""]) {
        self.skillOneLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.skillOneLabel.text = @" Tap to add skill ";
        UITapGestureRecognizer *emptySkillOneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onEmptyLabelTapped:)];
        emptySkillOneTap.numberOfTapsRequired = 1;
        [self.skillOneLabel addGestureRecognizer:emptySkillOneTap];
        self.skillOneLabel.userInteractionEnabled = YES;
    } else {
        self.skillOneLabel.gestureRecognizers = nil;
        self.skillOneLabel.backgroundColor = nil;
        self.skillOneLabel.text = self.user.skillOne;
    }
    if (!self.user.skillTwo || [self.user.skillTwo isEqualToString:@""]) {
        self.skillTwoLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.skillTwoLabel.text = @" Tap to add skill ";
        UITapGestureRecognizer *emptySkillTwoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onEmptyLabelTapped:)];
        emptySkillTwoTap.numberOfTapsRequired = 1;
        [self.skillTwoLabel addGestureRecognizer:emptySkillTwoTap];
        self.skillTwoLabel.userInteractionEnabled = YES;
    } else {
        self.skillTwoLabel.gestureRecognizers = nil;
        self.skillTwoLabel.backgroundColor = nil;
        self.skillTwoLabel.text = self.user.skillTwo;
    }
    if (!self.user.skillThree || [self.user.skillThree isEqualToString:@""]) {
        self.skillThreeLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.skillThreeLabel.text = @" Tap to add skill ";
        UITapGestureRecognizer *emptySkillThreeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onEmptyLabelTapped:)];
        emptySkillThreeTap.numberOfTapsRequired = 1;
        [self.skillThreeLabel addGestureRecognizer:emptySkillThreeTap];
        self.skillThreeLabel.userInteractionEnabled = YES;
    } else {
        self.skillThreeLabel.gestureRecognizers = nil;
        self.skillThreeLabel.backgroundColor = nil;
        self.skillThreeLabel.text = self.user.skillThree;
    }
    if (self.user.profileImageFile) {
        [self.user.profileImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error) {
                NSLog(@"Getting data for profile image error: %@", error);
            } else {
                self.profileImageView.image = [UIImage imageWithData:data];
                self.profileImageView.gestureRecognizers = nil;
            }
        }];
    } else {
        //If there is no profile image, show default.
        self.profileImageView.image = [UIImage imageNamed:@"defaultProfile"];
        UITapGestureRecognizer *emptyPictureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onEmptyLabelTapped:)];
        emptyPictureTap.numberOfTapsRequired = 1;
        [self.profileImageView addGestureRecognizer:emptyPictureTap];
        self.profileImageView.userInteractionEnabled = YES;
    }
}

- (void)onEmptyLabelTapped:(UITapGestureRecognizer *)tap {
    NSLog(@"Tap recognized");
    self.isEditLabelTapped = YES;
    [self performSegueWithIdentifier:@"settingsSegue" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"settingsSegue"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        SettingsTableViewController *settingsTableViewController = [navigationController.viewControllers objectAtIndex:0];
        settingsTableViewController.isEditLabelTapped = self.isEditLabelTapped;
    }
}

#pragma mark - Log in/Sign up

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    if (![signUpController.signUpView.passwordField.text isEqualToString:signUpController.signUpView.additionalField.text]) {
        UIAlertController *passwordNotMatch = [UIAlertController alertControllerWithTitle:@"Passwords do not match" message:@"Please make sure that your passwords match." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [passwordNotMatch dismissViewControllerAnimated:YES completion:nil];
        }];
        [passwordNotMatch addAction:okayAction];
        [signUpController presentViewController:passwordNotMatch animated:YES completion:nil];
        return NO;
    } else {
        return YES;
    }
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    MWUser *newUser = (MWUser *)user;
    [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Sign up error: %@", error);
        } else {
            NSLog(@"Successful sign up! Current user: %@", [MWUser currentUser]);
            [self dismissViewControllerAnimated:YES completion:^{
                UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                UINavigationController *setUpNavigationController = [myStoryboard instantiateViewControllerWithIdentifier:@"setUpNavigationController"];
                [self presentViewController:setUpNavigationController animated:YES completion:nil];
            }];
        }
    }];
    
}

@end
