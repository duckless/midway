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
@property CLLocationManager *locationManager;
@property long time;
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
    [[LocationManager locationManager] startUpdatingLocation];
    CompassView *compassView = [[CompassView alloc] initWithFrame:CGRectMake(10, 10, 300, 300)];
    compassView.coordinates = self.coordinates;
    compassView.distance = self.distance;
    [self.testView addSubview:compassView];
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


@end
