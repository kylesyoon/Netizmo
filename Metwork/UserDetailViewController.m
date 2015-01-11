//
//  UserDetailViewController.m
//  Metwork
//
//  Created by Kyle Yoon on 11/11/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import "UserDetailViewController.h"

@interface UserDetailViewController () <UIScrollViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *needTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobTitleAndCompanyLabel;
@property (weak, nonatomic) IBOutlet UITextView *shortDescriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *skillOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *skillTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *skillThreeLabel;
@property BOOL isSaved;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *topSkillsLabel;


@end

@implementation UserDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isSaved = NO;
    PFQuery *savedUserQuery = [MWUser query];
    [savedUserQuery whereKey:@"savedUser" equalTo:self.selectedUser];
    [savedUserQuery whereKey:@"objectId" equalTo:[MWUser currentUser].objectId];
    [savedUserQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (error) {
            NSLog(@"Querying relation error: %@", error);
        } else {
            if (number != 0) {
                self.isSaved = YES;
                self.saveButton.title = @"Unsave";
            }
        }
    }];
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2;
    self.imageView.clipsToBounds = YES;
    
    if (self.selectedUser.need.length == 0) {
        self.needTextView.hidden = YES;
    }
    self.needTextView.text = self.selectedUser.need;
    [self resizeFontToFillTextView];
    [self.selectedUser.profileImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.imageView.image = [UIImage imageWithData:data];
    }];
    self.fullNameLabel.text = [self.selectedUser.firstName stringByAppendingString:[NSString stringWithFormat:@" %@", self.selectedUser.lastName]];
    self.shortDescriptionTextView.text = self.selectedUser.shortDescription;
    self.jobTitleAndCompanyLabel.text = [self.selectedUser.jobTitle stringByAppendingString:[NSString stringWithFormat:@" at %@", self.selectedUser.company]];
    if ((!self.selectedUser.skillOne || [self.selectedUser.skillOne isEqualToString:@""]) && (!self.selectedUser.skillTwo || [self.selectedUser.skillTwo isEqualToString:@""]) && (!self.selectedUser.skillThree || [self.selectedUser.skillThree isEqualToString:@""])) {
        self.topSkillsLabel.hidden = YES;
    } else {
        self.topSkillsLabel.hidden = NO;
        self.skillOneLabel.text = self.selectedUser.skillOne;
        self.skillTwoLabel.text = self.selectedUser.skillTwo;
        self.skillThreeLabel.text = self.selectedUser.skillThree;
    }
}

- (void)viewDidLayoutSubviews {
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 670);
}

- (IBAction)onSavedTapped:(id)sender {
    if (self.isSaved == YES) {
        self.saveButton.enabled = NO;
        PFRelation *unSaved = [[MWUser currentUser] relationForKey:@"savedUser"];
        [unSaved removeObject:self.selectedUser];
        [[MWUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Saving objectIds error: %@", error);
            } else {
                self.saveButton.enabled = YES;
                NSLog(@"Successful save!");
                UIAlertView *removedUser = [[UIAlertView alloc] initWithTitle:@"Removed User" message:[NSString stringWithFormat:@"%@ %@ has been removed from your saved users.", self.selectedUser.firstName, self.selectedUser.lastName] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [removedUser show];
            }
        }];
        self.saveButton.title = @"Save";
    } else {
        self.saveButton.enabled = NO;
        PFRelation *saved = [[MWUser currentUser] relationForKey:@"savedUser"];
        [saved addObject:self.selectedUser];
        [[MWUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Saving relation error: %@", error);
            } else {
                NSLog(@"Sucessful save");
                self.saveButton.enabled = YES;
                UIAlertView *savedUser = [[UIAlertView alloc] initWithTitle:@"Saved User" message:[NSString stringWithFormat:@"%@ %@ has been added to your saved users.", self.selectedUser.firstName, self.selectedUser.lastName] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [savedUser show];
            }
        }];
        self.saveButton.title = @"Unsave";
    }
    self.isSaved = !self.isSaved;
}

- (void)resizeFontToFillTextView {
    CGFloat fontSize = 72.0;
    while (fontSize > 12.0 && [self.needTextView sizeThatFits:(CGSizeMake(self.needTextView.frame.size.width, FLT_MAX))].height >= self.needTextView.frame.size.height) {
        fontSize -= 1.0;
        self.needTextView.font = [self.needTextView.font fontWithSize:fontSize];
    }
}



@end
