//
//  UsersTableViewController.m
//  Metwork
//
//  Created by Kyle Yoon on 11/11/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import "UsersTableViewController.h"
#import "MWUser.h"
#import "UserTableViewCell.h"
#import "UserDetailViewController.h"

@interface UsersTableViewController () <CentralDelegate, PeripheralDelegate>

@property NSMutableArray *retrievedUsers;
@property UIActivityIndicatorView *activityIndicator;
@property UILabel *noNearbyUsersLabel;

@end

@implementation UsersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.BLECentral.delegate = self;
    self.BLEPeripheral.delegate = self;
    self.retrievedUsers = [NSMutableArray array];
    UIBarButtonItem *endNetworkingButton = [[UIBarButtonItem alloc] initWithTitle:@"Stop" style:UIBarButtonItemStyleDone target:self action:@selector(onEndNetworkingTapped:)];
    endNetworkingButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = endNetworkingButton;
    [self initializeActivityIndicator];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.noNearbyUsersLabel = [[UILabel alloc] init];
    self.noNearbyUsersLabel.text = @"No nearby users";
    self.noNearbyUsersLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    self.noNearbyUsersLabel.textColor = [UIColor darkGrayColor];
    [self.noNearbyUsersLabel sizeToFit];
    self.noNearbyUsersLabel.center = CGPointMake(self.view.center.x, self.view.center.y - 44);
    [self.view addSubview:self.noNearbyUsersLabel];
}

- (IBAction)onEndNetworkingTapped:(id)sender {
    UIAlertController *stopNetworkingAlert = [UIAlertController alertControllerWithTitle:@"Ending Networking Session" message:@"Once the networking session ends, you will lose the found users. Save necessary users before ending." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *endAction = [UIAlertAction actionWithTitle:@"End" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self.BLECentral stopScanning];
        [self.BLEPeripheral stopAdvertising];
        [self.retrievedUsers removeAllObjects];
        [self.tableView reloadData];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [stopNetworkingAlert dismissViewControllerAnimated:YES completion:nil];
    }];
    [stopNetworkingAlert addAction:cancelAction];
    [stopNetworkingAlert addAction:endAction];
    [self presentViewController:stopNetworkingAlert animated:YES completion:nil];
}

- (IBAction)onRefreshTapped:(id)sender {
    NSLog(@"Refreshing");
    [self.BLECentral stopScanning];
    [self.BLECentral startScanning];
    [self.retrievedUsers removeAllObjects];
    [self.tableView reloadData];
    [self toggleNoNearbyUsersLabel];
}

- (void)toggleNoNearbyUsersLabel {
    if (self.retrievedUsers.count > 0) {
        self.noNearbyUsersLabel.hidden = YES;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    } else {
        self.noNearbyUsersLabel.hidden = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UserDetailViewController *userDetailViewController = segue.destinationViewController;
    userDetailViewController.selectedUser = [self.retrievedUsers objectAtIndex:self.tableView.indexPathForSelectedRow.section];
}

#pragma mark - BLE Delegate Methods

- (void)addUserWithObjectId:(NSString *)aObjectId {
    NSLog(@"Add objectId delegate called");
    [MWUser retrieveUserWithObjectId:aObjectId completion:^(MWUser *user) {
        MWUser *retrievedUser = user;
        [self.retrievedUsers insertObject:retrievedUser atIndex:0];
        [self toggleNoNearbyUsersLabel];
        [self.tableView beginUpdates];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
        NSLog(@"Adding user to table");
    }];
}

- (void)backToProfileView {
    //This method is called when there are BLE authorization issues.
    //Takes user back to the profile view.
    [self.BLECentral stopScanning];
    [self.BLEPeripheral stopAdvertising];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.retrievedUsers.count;
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
    MWUser *user = [self.retrievedUsers objectAtIndex:section];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 2.5, 40, 40)];
    imageView.layer.cornerRadius = imageView.frame.size.width / 2;
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [user.profileImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        imageView.image = [UIImage imageWithData:data];
    }];
    
    UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(50, 12, self.view.frame.size.width - 95, 20)];
    userName.text = [user.firstName stringByAppendingString:[NSString stringWithFormat:@" %@", user.lastName]];
    userName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];

    [headerView addSubview:imageView];
    [headerView addSubview:userName];

    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MWUser *user = [self.retrievedUsers objectAtIndex:indexPath.section];
    cell.userJobTitleAndCompany.text = [user.jobTitle stringByAppendingString:[NSString stringWithFormat:@" at %@", user.company]];
    cell.userNeed.text = user.need;

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"Removing user: %@", [self.retrievedUsers objectAtIndex:indexPath.row]);
        [self.retrievedUsers removeObjectAtIndex:indexPath.section];
        [self.tableView reloadData];
        [self toggleNoNearbyUsersLabel];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Remove";
}

#pragma mark - Activity Indicator

- (void)initializeActivityIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.color = [UIColor colorWithRed:0.0/255.0 green:180.0/255.0 blue:255.0/255.0 alpha:1.0];
    self.activityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y - 44);
    
    [self.view addSubview:self.activityIndicator];
}

- (void)startAnimatingActivityIndicator {
    [self.activityIndicator startAnimating];
    NSLog(@"Started animating for activity indicator: %@", self.activityIndicator);
}

- (void)stopAnimatingActivityIndicator {
    [self.activityIndicator stopAnimating];
    NSLog(@"Stopped animating for activity indicator: %@", self.activityIndicator);
}


@end
