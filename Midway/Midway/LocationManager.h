//
//  LocationManager.h
//  Midway
//
//  Created by Anton Malmquist on 2013-12-06.
//  Copyright (c) 2013 duckless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject

+ (id)locationManager;

- (CLLocation *) currentLocation;
- (CLLocation *) currentHeading;

- (double) currentLatitude;
- (double) currentLongitude;

- (void) startUpdatingLocation;
- (void) startUpdatingSignificantLocation;
- (void) stopLocationUpdates;

@end