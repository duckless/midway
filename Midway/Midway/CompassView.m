//
//  CompassView.m
//  Midway
//
//  Created by Olof Bjerke on 2013-12-04.
//  Copyright (c) 2013 duckless. All rights reserved.
//

#import "CompassView.h"
#import "SessionModel.h"
#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180 / M_PI)

@interface CompassView()

- (void) updateCompass;

@end

@implementation CompassView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //Compass Images
        
        UIImageView *arrowImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        arrowImg.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testArrow" ofType:@"png"]];
        
        //Compass Container
        
        self.compassContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        //[self.compassContainer.layer  insertSublayer:myCompassLayer atIndex:0];
        [self.compassContainer addSubview:arrowImg];
        
        [self addSubview:self.compassContainer];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.delegate=self;
        
        //Start the compass updates.
        [self.locationManager startUpdatingHeading];
        [self.locationManager startUpdatingLocation];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopUpdating) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUpdating) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        
    }
    return self;
}

- (void) startUpdating
{
    NSLog(@"starting");
    
    [self.locationManager startUpdatingHeading];
}

- (void) stopUpdating
{
    NSLog(@"Stopping");
    
    [self.locationManager stopUpdatingHeading];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#pragma mark -
#pragma mark Geo Points methods

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    
	[self updateCompass];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self updateCompass];
}

- (void) updateCompass
{
    
//    NSInteger magneticAngle = newHeading.magneticHeading;
    NSInteger trueAngle = self.locationManager.heading.trueHeading;
    
    
    
//    NSLog(@"New magnetic heading: %d", magneticAngle);
	NSLog(@"New true heading: %ld", (long)trueAngle);
    
    CLLocation * targetLocation = [[SessionModel sharedSessionModel] targetLocation];
    
    // Current location
    float lat1 = self.locationManager.location.coordinate.latitude;
    float lon1 = self.locationManager.location.coordinate.longitude;
    
    // Target location
    float lat2 = targetLocation.coordinate.latitude;
    float lon2 = targetLocation.coordinate.longitude;
    
    // Distance between coordinates
    float distance = [self.locationManager.location distanceFromLocation: targetLocation];
    
    //    θ = atan2( sin(Δlong).cos(lat2), cos(lat1).sin(lat2) − sin(lat1).cos(lat2).cos(Δlong) )
    //    float heading = atan2(cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1), sin(lon2 - lon1) * cos(lat2));
    float heading = atan2(sin(lon2 - lon1) * cos(lat2), cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1));
    
    
    float headingInDegrees = radiansToDegrees(heading);
    
    
    float compassHeading = headingInDegrees - trueAngle;
    
    if (compassHeading < 0) {
        compassHeading = compassHeading + 360;
    }
    
    NSLog(@"compassHeading: %f", compassHeading);
    
    NSLog(@"headingInDegrees = %f, trueHeading = %ld", headingInDegrees, (long)trueAngle);
    self.coordinates.text = [[NSString alloc] initWithFormat:@"lat: %f, lon: %f", lat1, lon1];
    self.distance.text = [[NSString alloc] initWithFormat:@"%f meter left", distance];
    
    //This is set by a switch in my apps settings //
    NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
    BOOL magneticNorth = [prefs boolForKey:@"UseMagneticNorth"];
    
    if (magneticNorth == YES) {
        //        NSLog(@"using magnetic north");
        
//        CGAffineTransform rotate = CGAffineTransformMakeRotation(degreesToRadians(-magneticAngle));
//        [self.compassContainer setTransform:rotate];
    }
    else {
        //        NSLog(@"using true north");
        
        CGAffineTransform rotate = CGAffineTransformMakeRotation(degreesToRadians(compassHeading));
        [self.compassContainer setTransform:rotate];
    }
    
}

@end