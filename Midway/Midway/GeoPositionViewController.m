//
//  GeoPositionViewController.m
//  Midway
//
//  Created by Olof Bjerke on 2013-12-02.
//  Copyright (c) 2013 duckless. All rights reserved.
//
#import "SessionModel.h"
#import "GeoPositionViewController.h"

@interface GeoPositionViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *geoArrow;
@property CLLocationManager *locationManager;
@end

@implementation GeoPositionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager=[[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.headingFilter = 1;
    self.locationManager.delegate= self;
    [self.locationManager startUpdatingHeading];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    // Convert Degree to Radian and move the needle
    float oldRad =  -manager.heading.trueHeading * M_PI / 180.0f;
    float newRad =  -newHeading.trueHeading * M_PI / 180.0f;
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    theAnimation.fromValue = [NSNumber numberWithFloat:oldRad];
    theAnimation.toValue=[NSNumber numberWithFloat:newRad];
    theAnimation.duration = 0.5f;
    [self.geoArrow.layer addAnimation:theAnimation forKey:@"animateMyRotation"];
    self.geoArrow.transform = CGAffineTransformMakeRotation(newRad);	NSLog(@"%f (%f) => %f (%f)", manager.heading.trueHeading, oldRad, newHeading.trueHeading, newRad);
}
 
 double lon = location.longitude - otherLocation.longitude;
 double y = sin(lon) * cos(otherLocation.latitude);
 double x = cos(location.latitude) * sin(otherLocation.latitude) - sin(location.latitude) * cos(otherLocation.latitude) * cos(lon);
 double angle = atan2(y, x);
 
*/

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    
    CLLocation *location = manager.location;
    CLLocation *otherLocation = [[SessionModel sharedSessionModel] targetLocation];
    
    double distanceEast = (location.coordinate.longitude > 0 && otherLocation.coordinate.longitude < 0) ? 180 - location.coordinate.longitude + otherLocation.coordinate.longitude - -180: otherLocation.coordinate.longitude - location.coordinate.longitude;
    
    if (distanceEast < 0) {
        distanceEast += 360;
    }
    
    double distanceWest = (location.coordinate.longitude < 0 && otherLocation.coordinate.longitude > 0) ? -180 - location.coordinate.longitude - 180 - otherLocation.coordinate.longitude : location.coordinate.longitude - otherLocation.coordinate.longitude;
    
    if (distanceWest < 0) {
        distanceWest += 360;
    }
    
    float latitudinalDifference = (otherLocation.coordinate.latitude - location.coordinate.latitude);
    float longitudinalDifference = fmin(distanceEast,distanceWest);
    
    float arcTan = atan(longitudinalDifference / latitudinalDifference);
    
    float oldRadian = (-manager.heading.trueHeading *M_PI /180.0f)+arcTan+M_PI;
    float newRadian = (-newHeading.trueHeading *M_PI /180.0f)+arcTan+M_PI;
    
    CABasicAnimation *animation;
    animation=[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.fromValue = [NSNumber numberWithFloat:oldRadian];
    animation.toValue = [NSNumber numberWithFloat:newRadian];
    //animation.duration = 0.1f;
    self.geoArrow.layer.anchorPoint = CGPointMake(0.5, 0.5);
    
//    [self.geoArrow.layer addAnimation:animation forKey:nil];
    self.geoArrow.transform = CGAffineTransformMakeRotation(newRadian);
}

@end
