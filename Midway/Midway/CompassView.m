//
//  CompassView.m
//  Midway
//
//  Created by Olof Bjerke on 2013-12-04.
//  Copyright (c) 2013 duckless. All rights reserved.
//

#import "CompassView.h"
@interface CompassView()
@property CGFloat currentAngle;
@property UIView *compassContainer;
@end

@implementation CompassView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIImageView *arrowImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240, 240)];
        arrowImg.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"arrow" ofType:@"png"]];
    
        self.compassContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.compassContainer addSubview:arrowImg];
        [self addSubview:self.compassContainer];
    }
    return self;
}

- (void) updateCompassWithHeading: (double) compassHeading
{
    CGAffineTransform rotate = CGAffineTransformMakeRotation(compassHeading);
    [self.compassContainer setTransform:rotate];
}

@end