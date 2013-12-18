//
//  Beacon.m
//  Midway
//
//  Created by Rostislav Raykov on 12/18/13.
//  Copyright (c) 2013 duckless. All rights reserved.
//

#import "Beacon.h"
#import "SessionModel.h"
#import "LocationManager.h"

@implementation Beacon

+ (id)sharedBeacon {
    static Beacon *sharedBeacon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBeacon = [[self alloc] init];
    });
    return sharedBeacon;
}

- (id) init
{
    self = [super init];
    if(self) {
        
    }
    return self;
}

- (void) startBeaming
{
    NSInteger sessionID = [[[SessionModel sharedSessionModel] sessionID] integerValue];
    NSNumber *major = [[NSNumber alloc] initWithInteger:sessionID];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"F7412ED5-05EC-47AD-8644-3DAFA74BBF8B"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                major:[major shortValue]
                                                                minor:1
                                                           identifier:@"com.duckless.grabafika"];
}

- (void) startSearching
{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"23542266-18D1-4FE4-B4A1-23F8195B9D39"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.devfright.myRegion"];
    [[LocationManager shared] startMonitoringForRegion:self.beaconRegion];
}

- (IBAction)transmitBeacon:(UIButton *)sender {
    self.beaconPeripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:nil];
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                     queue:nil
                                                                   options:nil];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Powered On");
        [self.peripheralManager startAdvertising:self.beaconPeripheralData];
    } else if (peripheral.state == CBPeripheralManagerStatePoweredOff) {
        NSLog(@"Powered Off");
        [self.peripheralManager stopAdvertising];
    }
}

@end
