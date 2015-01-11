//
//  UsersTableViewController.h
//  Metwork
//
//  Created by Kyle Yoon on 11/11/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEPeripheral.h"
#import "BLECentral.h"

@interface UsersTableViewController : UITableViewController

@property BLECentral *BLECentral;
@property BLEPeripheral *BLEPeripheral;

@end
