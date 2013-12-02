//
//  GeoPositionViewController.m
//  Midway
//
//  Created by Olof Bjerke on 2013-12-02.
//  Copyright (c) 2013 duckless. All rights reserved.
//

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


@end
