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

@interface SessionModel : NSObject <NSURLConnectionDataDelegate, CLLocationManagerDelegate>

@property NSString *sessionID;

+ (id)sharedSessionModel;
- (NSMutableArray *) inviteesEmails;
- (NSMutableArray *) inviteesPhoneNumbers;
- (NSString *) inviteesName;
- (CLLocation *) targetLocation;
- (void) startSessionWith:(ABRecordID)invitee;
- (void) acceptSessionWith:(NSString *)sessionID;
- (double) headingTowardTargetLocation;
- (void) retrieveSessionID;

- (CLLocation *) currentLocation;
- (CLHeading *) currentHeading;

- (double) currentLatitude;
- (double) currentLongitude;

- (void) startUpdatingLocation;
- (void) startUpdatingSignificantLocation;
- (void) stopLocationUpdates;


@end
