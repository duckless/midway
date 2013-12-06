//
//  LocationManager.m
//  Midway
//
//  Created by Anton Malmquist on 2013-12-06.
//  Copyright (c) 2013 duckless. All rights reserved.
//

#import "LocationManager.h"
@interface LocationManager()

@property CLLocationManager *locationManager;

@end

@implementation LocationManager

-(id) init {
    self = [super init];
    if(self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.headingFilter = 1;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.delegate=self;
        
        // Start the location updates.
        [self startUpdatingLocation];
    }
    return self;
}

+ (id)locationManager {
    static LocationManager *sharedLocationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLocationManager = [[self alloc] init];
    });
    return sharedLocationManager;
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

- (void) startUpdatingLocation
{
    [self.locationManager startUpdatingHeading];
    [self.locationManager startUpdatingLocation];
}

-(void) startUpdatingSignificantLocation
{
    [self.locationManager startMonitoringSignificantLocationChanges];
}

-(void) stopLocationUpdates
{
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
}

@end
