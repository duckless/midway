//
//  CompassView.h
//  Midway
//
//  Created by Olof Bjerke on 2013-12-04.
//  Copyright (c) 2013 duckless. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface CompassView : UIView <CLLocationManagerDelegate>

- (void) updateCompassWithHeading: (double) compassHeading;

@end
