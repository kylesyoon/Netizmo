//
//  SavedUsersTableViewController.m
//  Metwork
//
//  Created by Kyle Yoon on 11/18/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import "SavedUsersTableViewController.h"
#import "UserTableViewCell.h"
#import "UserDetailViewController.h"
#import "MWUser.h"

@interface SavedUsersTableViewController ()

@property NSMutableArray *savedUsers;
@property UILabel *noSavedUsersLabel;

@end

@implementation SavedUsersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    PFRelation *savedRelation = [[MWUser currentUser] relationForKey:@"savedUser"];
    PFQuery *savedUserQuery = [savedRelation query];
    [savedUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Saved user query error: %@", error);
        } else {
            self.savedUsers = [NSMutableArray arrayWithArray:objects];
            NSLog(@"Found objects: %@", objects);
            if (objects.count == 0) {
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                self.noSavedUsersLabel = [[UILabel alloc] init];
                self.noSavedUsersLabel.text = @"No saved users";
                self.noSavedUsersLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
                self.noSavedUsersLabel.textColor = [UIColor darkGrayColor];
                [self.noSavedUsersLabel sizeToFit];
                self.noSavedUsersLabel.center = CGPointMake(self.view.center.x, self.view.center.y - 44);
                [self.view addSubview:self.noSavedUsersLabel];
            }
            [self.tableView reloadData];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.savedUsers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
    headerView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.75];
    MWUser *user = [self.savedUsers objectAtIndex:section];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 2.5, 40, 40)];
    imageView.layer.cornerRadius = imageView.frame.size.width / 2;
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [user.profileImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        imageView.image = [UIImage imageWithData:data];
    }];
    
    UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(50, 12, self.view.frame.size.width - 75, 20)];
    userName.text = [user.firstName stringByAppendingString:[NSString stringWithFormat:@" %@", user.lastName]];
    userName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    
    [headerView addSubview:imageView];
    [headerView addSubview:userName];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MWUser *user = [self.savedUsers objectAtIndex:indexPath.section];
    
    cell.userJobTitleAndCompany.text = [user.jobTitle stringByAppendingString:[NSString stringWithFormat:@" at %@", user.company]];
    cell.userNeed.text = user.need;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFRelation *unSaved = [[MWUser currentUser] relationForKey:@"savedUser"];
        MWUser *unSavedUser = [self.savedUsers objectAtIndex:indexPath.section];
        [unSaved removeObject:unSavedUser];
        [[MWUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Saving objectIds error: %@", error);
            } else {
                NSLog(@"Successful save!");
                [self.savedUsers removeObject:unSaved];
                UIAlertView *removedUser = [[UIAlertView alloc] initWithTitle:@"Removed User" message:[NSString stringWithFormat:@"%@ %@ has been removed from your saved users.", unSavedUser.firstName, unSavedUser.lastName] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [removedUser show];
            }
        }];
        [self.tableView reloadData];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Unsave";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UserDetailViewController *userDetailViewController = segue.destinationViewController;
    userDetailViewController.selectedUser = [self.savedUsers objectAtIndex:self.tableView.indexPathForSelectedRow.section];
}


@end
