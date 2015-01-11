//
//  BLEPeripheral.h
//  Metwork
//
//  Created by Kyle Yoon on 11/19/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "MWUser.h"
#import "UUIDS.h"

@protocol PeripheralDelegate

- (void)backToProfileView;

@end

@interface BLEPeripheral : NSObject <CBPeripheralManagerDelegate>

@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic *transferCharacteristic;
@property (strong, nonatomic) NSData *dataOfUserID;
@property id<PeripheralDelegate> delegate;
@property CLBeaconRegion *beaconRegion;

+ (BLEPeripheral *)sharedInstance;
- (void)startAdvertising;
- (void)stopAdvertising;

@end
