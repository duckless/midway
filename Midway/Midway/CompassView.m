//
//  CompassView.m
//  Midway
//
//  Created by Olof Bjerke on 2013-12-04.
//  Copyright (c) 2013 duckless. All rights reserved.
//

#import "CompassView.h"
#import "SessionModel.h"


@interface CompassView()

- (void) updateCompassWithHeading: (double) compassHeading;

@end

@implementation CompassView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    
        UIImageView *arrowImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
        arrowImg.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"golden_arrow" ofType:@"png"]];
    
        self.compassContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
        [self.compassContainer addSubview:arrowImg];
        
        [self addSubview:self.compassContainer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"updateCompass" object:nil];
        
    }
    return self;
}

- (void) receiveNotification:(NSNotification *)notification
{
    NSLog(@"get notification in view");
    if ([notification.name isEqualToString:@"updateCompass"])
    {
        NSDictionary* userInfo = notification.userInfo;
        double heading = [[userInfo objectForKey:@"heading"] doubleValue];
       
        [self updateCompassWithHeading: heading];
    }
}

- (void) updateCompassWithHeading: (double) compassHeading
{

//    self.coordinates.text = [[NSString alloc] initWithFormat:@"lat: %f, lon: %f", lat1, lon1];
//    self.distance.text = [[NSString alloc] initWithFormat:@"%f meter left", distance];
    
    CGAffineTransform rotate = CGAffineTransformMakeRotation(compassHeading);
    [self.compassContainer setTransform:rotate];
}

@end