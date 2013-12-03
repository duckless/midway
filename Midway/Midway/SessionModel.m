//
//  SessionModel.m
//  Midway
//
//  Created by Olof Bjerke on 2013-12-01.
//  Copyright (c) 2013 duckless. All rights reserved.
//
#import "AddressBookUI/AddressBookUI.h"
#import "SessionModel.h"
@interface SessionModel ()

@property ABRecordID personID;
@property NSMutableArray *emails;
@property NSMutableArray *phoneNumbers;
@property NSString *inviteeName;
@property BOOL sessionIsActive;

- (void) retrieveSessionID;
- (void) gatherInviteeInfo;

@end
@implementation SessionModel

-(id) init {
    self = [super init];
    if(self) {
        _emails = [[NSMutableArray alloc] init];
        _phoneNumbers = [[NSMutableArray alloc] init];
//        [self loadData];
        
    }
    return self;
}

+ (id)sharedSessionModel {
    static SessionModel *sharedSessionModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSessionModel = [[self alloc] init];
    });
    return sharedSessionModel;
}

- (NSMutableArray *) inviteesEmails {
    return self.emails;
}

- (NSMutableArray *) inviteesPhoneNumbers {
    return self.phoneNumbers;
}

- (NSString *) inviteesName {
    return self.inviteeName;
}

- (void) startSessionWith:(ABRecordID)invitee {
    self.personID = invitee;
    
    [self gatherInviteeInfo];
    NSLog(@"got an ID!");
    
}

#warning missing implementation
- (void) invalidateSession {

}

- (BOOL) isSessionActive {
    return _sessionIsActive;
}

#warning missing implementation
- (NSURL *) getInviteURL {
    return nil;
}

- (void) gatherInviteeInfo {
    
    NSLog(@"Gather email and phone info");
    [self.emails removeAllObjects];
    [self.phoneNumbers removeAllObjects];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
    ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(addressBook, self.personID);
    
    ABMultiValueRef emailMultiValue = ABRecordCopyValue(personRef, kABPersonEmailProperty);
    NSArray *emailAddresses = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailMultiValue);
    
    [self.emails addObjectsFromArray:emailAddresses];
    
    ABMultiValueRef phoneMultiValue = ABRecordCopyValue(personRef, kABPersonPhoneProperty);
    NSArray *phoneNumbers = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneMultiValue);

    [self.phoneNumbers addObjectsFromArray:phoneNumbers];
    
    self.inviteeName = (__bridge NSString *)(ABRecordCopyValue(personRef, kABPersonFirstNameProperty));
    
}

#warning missing implementation
- (void) retrieveSessionID {
    // This message should contact the server in the
    // background, retrieving a new session ID to be used when an email or SMS is sent
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
#warning url string must be added
        NSString *urlString = nil;
        NSURL *requestURL = [NSURL URLWithString:urlString];
        NSData *responseData = [NSData dataWithContentsOfURL: requestURL];
        
        NSError *parsingError;
        NSDictionary *jsonRespsonse = [NSJSONSerialization
                                       JSONObjectWithData:responseData
                                       options:kNilOptions
                                       error:&parsingError];
#warning json key missing
        NSString *sessionID = [jsonRespsonse objectForKey:@""];
        dispatch_sync(dispatch_get_main_queue(), ^{ //To make the update happen in main thread.
            
        });
    });
}

@end
