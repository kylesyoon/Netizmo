//
//  BLEPeripheral.m
//  Metwork
//
//  Created by Kyle Yoon on 11/19/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import "BLEPeripheral.h"

@implementation BLEPeripheral

+ (BLEPeripheral *)sharedInstance {
    static BLEPeripheral *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[BLEPeripheral alloc] init];
    });
    return _sharedInstance;
}

- (void)initializePeripheralManager {
    if (!self.peripheralManager) {
        NSLog(@"Initializing Peripheral Manager");
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    }
}

- (void)startAdvertising {
    NSLog(@"Starting up BLEPeripheral");
    [self initializePeripheralManager];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if (error) {
        NSLog(@"Couldn't turn on advertising.");
        NSLog(@"Advertising starting error: %@", error);
        [self stopAdvertising];
        [self.delegate backToProfileView];
        return;
    }
    if (peripheral.isAdvertising) {
        NSLog(@"Advertising is on");
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOff:
            NSLog(@"CB Peripheral Manager State: Powered Off");
            self.peripheralManager = nil;
            [self.delegate backToProfileView];
            break;
        case CBPeripheralManagerStateUnauthorized:
            NSLog(@"CB Peripheral Manager State: Unauthorized");
            self.peripheralManager = nil;
            [self.delegate backToProfileView];
            break;
        case CBPeripheralManagerStateResetting:
            NSLog(@"CB Peripheral Manager State: Resetting");
            self.peripheralManager = nil;
            [self.delegate backToProfileView];
        case CBPeripheralManagerStateUnsupported:
            NSLog(@"CB Peripheral Manager State: Unsupported");
            self.peripheralManager = nil;
            [self.delegate backToProfileView];
            break;
        case CBPeripheralManagerStateUnknown:
            NSLog(@"CBPeripheral Manager State: Unknown");
            self.peripheralManager = nil;
            [self.delegate backToProfileView];
            break;
        default:
            NSLog(@"CB Peripheral Manager State: Powered On");
            [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:kNETIZMO_SERVICE_UUID]]}];
            NSLog(@"Started advertising");
            self.dataOfUserID = [[MWUser currentUser].objectId dataUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"Advertising data of user objectId string: %@", self.dataOfUserID);
            //Initializing characteristic with value of objectId.
            self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kNETIZMO_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyRead value:self.dataOfUserID permissions:CBAttributePermissionsReadable];
            //Initializing service with characteric.
            CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:kNETIZMO_SERVICE_UUID] primary:YES];
            transferService.characteristics = @[self.transferCharacteristic];
            [self.peripheralManager addService:transferService];
            NSLog(@"Added characteristic: %@", transferService.characteristics);
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    NSLog(@"Did receive read request: %@", request);
}

- (void)stopAdvertising {
    [self.peripheralManager removeAllServices];
    [self.peripheralManager stopAdvertising];
    self.peripheralManager = nil;
    NSLog(@"Stopped advertising");
}

@end
