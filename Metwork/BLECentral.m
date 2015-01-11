//
//  BLECentral.m
//  Metwork
//
//  Created by Kyle Yoon on 11/19/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import "BLECentral.h"

@implementation BLECentral

+ (BLECentral *)sharedInstance {
    //BLECentral Singleton
    static BLECentral *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate , ^{
        _sharedInstance = [[BLECentral alloc] init];
    });
    return _sharedInstance;
}

- (void)initializeCentralManager {
    if (!self.centralManager) {
        NSLog(@"Initializing Central Manager");
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
}

- (void)startScanning {
    NSLog(@"Starting up BLECentral");
    [self initializeCentralManager];
    //Initializing array of peripherals that have connected to the central manager.
    self.connectedPeripheralsUUIDs = [[NSMutableArray alloc] init];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CB CentralManager State: Powered Off");
            self.centralManager = nil;
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CB Central Manager State: Resetting");
            self.centralManager = nil;
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CB Central Manager State: Unauthorized");
            self.centralManager = nil;
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CB Central Manager State: Unsupported");
            self.centralManager = nil;
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"CB Central Manager State: Unknown");
            self.centralManager = nil;
            break;
        default:
            NSLog(@"CB Central Manager State: Powered On");
            [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kNETIZMO_SERVICE_UUID]] options:nil];
            NSLog(@"Started Scanning");
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"Discovered peripheral: %@ RSSI: %@", peripheral.name, RSSI);
    if (![self.connectedPeripheralsUUIDs containsObject:peripheral.identifier]) {
        [self.centralManager stopScan];
        _discoveredPeripheral = peripheral;
        [self.connectedPeripheralsUUIDs addObject:_discoveredPeripheral.identifier];
        NSLog(@"Connecting to peripheral: %@", peripheral);
        [self.centralManager connectPeripheral:peripheral options:nil];
        [self.delegate startAnimatingActivityIndicator];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect to peripheral: %@", peripheral);
    [self cleanUp];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected to peripheral: %@", peripheral);
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:kNETIZMO_SERVICE_UUID]]];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering services: %@", error);
        return;
    }
    NSLog(@"Discovered services: %@", peripheral.services);
    CBService *service = peripheral.services.firstObject;
    [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kNETIZMO_CHARACTERISTIC_UUID]] forService:service];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Character discovering error: %@", error);
        return;
    }
    NSLog(@"Discovered Characteristics: %@", service.characteristics);
    CBCharacteristic *characteristic = service.characteristics.firstObject;
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNETIZMO_CHARACTERISTIC_UUID]]) {
        NSLog(@"Characteristic is: %@", characteristic);
        [peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Characteristic value update error: %@", error);
        return;
    }
    NSString *connectedId = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSLog(@"Got user objectId: %@", connectedId);
    [self.delegate addUserWithObjectId:connectedId];
    NSLog(@"Cancelling connection to peripheral: %@", peripheral);
    [self.centralManager cancelPeripheralConnection:peripheral];
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kNETIZMO_SERVICE_UUID]] options:nil];
    [self.delegate stopAnimatingActivityIndicator];
}

- (void)stopScanning {
    [self.centralManager stopScan];
    NSLog(@"Stopped scanning");
    self.centralManager = nil;
}

- (void)cleanUp {
    // See if we are subscribed to a characteristic on the peripheral
    if (_discoveredPeripheral.services != nil) {
        for (CBService *service in _discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNETIZMO_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            [_discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            return;
                        }
                    }
                }
            }
        }
    }
    [self.centralManager cancelPeripheralConnection:_discoveredPeripheral];
}

@end
