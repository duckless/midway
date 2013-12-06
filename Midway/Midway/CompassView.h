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

@property CLLocationManager * locationManager;
@property CGFloat currentAngle;
@property UIView *compassContainer;
@property (weak, nonatomic) IBOutlet UILabel *coordinates;
@property (weak, nonatomic) IBOutlet UILabel *distance;
- (void) receiveNotification: (NSNotification * ) notification;

@end
