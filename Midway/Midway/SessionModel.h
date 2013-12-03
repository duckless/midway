//
//  SessionModel.h
//  Midway
//
//  Created by Olof Bjerke on 2013-12-01.
//  Copyright (c) 2013 duckless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressBookUI/AddressBookUI.h"

@interface SessionModel : NSObject

@property NSString *sessionID;

+ (id)sharedSessionModel;
- (NSMutableArray *) inviteesEmails;
- (NSMutableArray *) inviteesPhoneNumbers;
- (NSString *) inviteesName;

- (void) startSessionWith: (ABRecordID) invitee;
- (void) invalidateSession;
- (BOOL) isSessionActive;
- (NSURL *) getInviteURL;

@end
