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

@interface SessionModel : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (strong,nonatomic) NSString *sessionID;

+ (id)sharedSessionModel;

- (NSMutableArray *) inviteesEmails;
- (NSMutableArray *) inviteesPhoneNumbers;
- (NSString *) inviteesName;

- (void) clearSession;
- (void) startSessionWith:(ABRecordID)invitee;
- (void) acceptSessionWith:(NSString *)sessionID;
- (void) retrieveSessionID;
- (void) updateTargetLocation;
- (double) headingTowardTargetLocation;

- (void) receiveNotification: (NSNotification * ) notification;

@end
