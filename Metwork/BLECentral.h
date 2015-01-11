//
//  BLECentral.h
//  Metwork
//
//  Created by Kyle Yoon on 11/19/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "UUIDS.h"
#import <UIKit/UIKit.h>

@protocol CentralDelegate

- (void)backToProfileView;
- (void)addUserWithObjectId:(NSString *)aObjectId;
- (void)startAnimatingActivityIndicator;
- (void)stopAnimatingActivityIndicator;

@end

@interface BLECentral : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *discoveredPeripheral;
@property NSMutableArray *connectedPeripheralsUUIDs;
@property id<CentralDelegate> delegate;

+ (BLECentral *)sharedInstance;
- (void)startScanning;
- (void)stopScanning;

@end
