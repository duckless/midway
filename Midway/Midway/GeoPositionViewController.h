//
//  GeoPositionViewController.h
//  Midway
//
//  Created by Olof Bjerke on 2013-12-02.
//  Copyright (c) 2013 duckless. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

@interface GeoPositionViewController : UIViewController
- (void) receiveNotification: (NSNotification * ) notification;


@end
