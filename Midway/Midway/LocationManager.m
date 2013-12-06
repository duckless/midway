//
//  LocationManager.m
//  Midway
//
//  Created by Anton Malmquist on 2013-12-06.
//  Copyright (c) 2013 duckless. All rights reserved.
//
#import "SessionModel.h"
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopUpdatingLocation) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUpdatingSignificantLocation) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUpdatingLocation) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCompass" object:self];
        
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
    NSLog(@"Stopping locaiton services");
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    double heading = [[SessionModel sharedSessionModel] headingTowardTargetLocation];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject: [NSNumber numberWithDouble:heading] forKey:@"heading"];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"updateCompass" object:nil userInfo:userInfo];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    double heading = [[SessionModel sharedSessionModel] headingTowardTargetLocation];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject: [NSNumber numberWithDouble:heading] forKey:@"heading"];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"updateCompass" object:nil userInfo:userInfo];
    NSLog(@"send heading...");
}

@end
