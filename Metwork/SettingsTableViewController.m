//
//  SettingsTableViewController.m
//  Metwork
//
//  Created by Kyle Yoon on 11/12/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "MWUser.h"

@interface SettingsTableViewController ()

@property NSArray *settingsArray;

@end

@implementation SettingsTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if (self.isEditLabelTapped) {
        [self performSegueWithIdentifier:@"myProfileSegue" sender:nil];
        self.isEditLabelTapped = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settingsArray = [NSArray arrayWithObjects:@"My Profile", @"Saved Users", @"Terms Of Use", @"Privacy Policy", @"Log Out", nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.settingsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSString *cellName = [self.settingsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = cellName;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    if (indexPath.row != self.settingsArray.count - 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (self.view.frame.size.height - 64) / 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"myProfileSegue" sender:nil];
            break;
        case 1:
            [self performSegueWithIdentifier:@"savedUsersSegue" sender:nil];
            break;
        case 2:
            [self performSegueWithIdentifier:@"termsSegue" sender:nil];
            break;
        case 3:
            [self performSegueWithIdentifier:@"policySegue" sender:nil];
            break;
        default:
            //Set last one to be default.
            [MWUser logOut];
            NSLog(@"Successful logout, current user: %@", [MWUser currentUser]);
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
    }
}

- (IBAction)onCloseTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
