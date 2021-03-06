//
//  GeoPositionViewController.m
//  Midway
//
//  Created by Olof Bjerke on 2013-12-02.
//  Copyright (c) 2013 duckless. All rights reserved.
//
#import "LocationManager.h"
#import "CompassView.h"
#import "GeoPositionViewController.h"

@interface GeoPositionViewController ()
@property (weak, nonatomic) IBOutlet UIView *testView;
@property (weak, nonatomic) IBOutlet UILabel *coordinates;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UILabel *venueNameLabel;

@property CompassView * compassView;
@end

@implementation GeoPositionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"updateCompass" object:nil];

    [[LocationManager shared] startUpdatingLocation];
    
    self.compassView = [[CompassView alloc] initWithFrame:CGRectMake(40, 40, 240, 240)];
    [self.testView addSubview:self.compassView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillAppear:(BOOL)animated
{

}

- (void) viewDidAppear:(BOOL)animated
{

}

- (void) receiveNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:@"updateCompass"])
    {
        NSDictionary* userInfo = notification.userInfo;
        double heading = [[userInfo objectForKey:@"heading"] doubleValue];
        double distanceLeft = [[userInfo objectForKey:@"distance"] doubleValue];
        NSString *venueName = @"Waiting for venue name";
        @try {
            venueName = [userInfo objectForKey:@"venueName"];
        }
        @catch (NSException * e) {
            venueName = @"Waiting for venue name";
        }
        @finally {

        }
        [self.compassView updateCompassWithHeading: heading];
        self.distance.text = [[NSString alloc] initWithFormat:@"%.0fm", distanceLeft];
        self.venueNameLabel.text = venueName;
    }
}

@end
