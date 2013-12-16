//
//  SessionModel.h
//  Midway
//
//  Created by Olof Bjerke on 2013-12-01.
//  Copyright (c) 2013 duckless. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "AddressBookUI/AddressBookUI.h"

@interface SessionModel : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate, CLLocationManagerDelegate>

@property NSString *sessionID;

+ (id)sharedSessionModel;
- (NSMutableArray *) inviteesEmails;
- (NSMutableArray *) inviteesPhoneNumbers;
- (NSString *) inviteesName;

- (void) startSessionWith:(ABRecordID)invitee;
- (void) acceptSessionWith:(NSString *)sessionID;
- (double) headingTowardTargetLocation;
- (void) retrieveSessionID;
- (void) getLocation;
- (void) updateTargetLocation;

- (CLLocation *) currentLocation;
- (CLHeading *) currentHeading;

- (double) currentLatitude;
- (double) currentLongitude;

- (void) startUpdatingLocation;
- (void) startUpdatingSignificantLocation;
- (void) stopLocationUpdates;


@end
