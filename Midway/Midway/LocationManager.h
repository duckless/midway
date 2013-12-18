//
//  LocationManager.h
//  Midway
//
//  Created by Rostislav Raykov on 12/18/13.
//  Copyright (c) 2013 duckless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

+ (id)shared;

- (CLLocation *) currentLocation;
- (CLHeading *) currentHeading;

- (double) currentLatitude;
- (double) currentLongitude;

- (void) startUpdatingLocation;
- (void) startUpdatingSignificantLocation;
- (void) stopLocationUpdates;

@end
