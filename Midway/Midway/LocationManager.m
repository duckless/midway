//
//  LocationManager.m
//  Midway
//
//  Created by Rostislav Raykov on 12/18/13.
//  Copyright (c) 2013 duckless. All rights reserved.
//

#import "LocationManager.h"
#import "SessionModel.h"
#import "Beacon.h"

@implementation LocationManager

+ (id) shared {
    static LocationManager *sharedLocationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLocationManager = [[self alloc] init];
    });
    return sharedLocationManager;
}

- (id) init
{
    self = [super init];
    if(self) {
        // Location mananger setup
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.headingFilter = 1;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.delegate= self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLocationUpdates) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUpdatingSignificantLocation) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUpdatingLocation) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

#pragma Location manager

- (void) startUpdatingLocation
{
    NSLog(@"starting location services");
    [self.locationManager startUpdatingHeading];
    [self.locationManager startUpdatingLocation];
}

-(void) startUpdatingSignificantLocation
{
    NSLog(@"starting significant");
    [self.locationManager startMonitoringSignificantLocationChanges];
}

-(void) stopLocationUpdates
{
    NSLog(@"Stopping location services");
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
}

- (CLHeading *) currentHeading
{
    return self.locationManager.heading;
}

- (CLLocation *) currentLocation
{
    return self.locationManager.location;
}

-(double) currentLatitude
{
    return self.locationManager.location.coordinate.latitude;;
}

-(double) currentLongitude
{
    return self.locationManager.location.coordinate.longitude;
}

#pragma location manager delegate

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"updateSessionCompass" object:nil userInfo:nil];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"updateSessionCompass" object:nil userInfo:nil];
}

#pragma ibeacon

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:[[Beacon shared] beaconRegion]];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self.locationManager stopRangingBeaconsInRegion:[[Beacon shared] beaconRegion]];
}

@end
