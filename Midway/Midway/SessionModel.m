//
//  SessionModel.m
//  Midway
//
//  Created by Olof Bjerke on 2013-12-01.
//  Copyright (c) 2013 duckless. All rights reserved.
//
#import "LocationManager.h"
#import "AddressBookUI/AddressBookUI.h"
#import "SessionModel.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180 / M_PI)

@interface SessionModel ()

@property ABRecordID personID;
@property NSMutableArray *emails;
@property NSMutableArray *phoneNumbers;
@property NSString *inviteeName;
- (void) retrieveSessionID;
- (void) gatherInviteeInfo;

@end
@implementation SessionModel

-(id) init {
    self = [super init];
    if(self) {
        _emails = [[NSMutableArray alloc] init];
        _phoneNumbers = [[NSMutableArray alloc] init];
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

- (void) startSessionWith:(ABRecordID)invitee {
    self.personID = invitee;
    
    [self gatherInviteeInfo];
    NSLog(@"got an ID!");
    
}

- (NSString *) inviteesName {
    return self.inviteeName;
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

- (CLLocation *) targetLocation {
    
    //    57° 42.218', 11° 58.035'
    CLLocationDegrees latitude = 57.70363333333333;
    CLLocationDegrees longitude = 11.96725;
    
    // Parking lot
    latitude = 57.671345;
    longitude = 11.915153;
    
    // Kuggen
    latitude = 57.706983;
    longitude = 11.9387;
    
//    140 km south of Gothenburg
//    latitude = 57.5413;
//    longitude = 11.910583;
    
    CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude: latitude longitude:longitude];
    
    return targetLocation;
}

- (void) retrieveSessionID {
    // This message should contact the server in the
    // background, retrieving a new session ID to be used when an email or SMS is sent
}

-(double) headingTowardTargetLocation
{
    NSInteger trueAngle = [[LocationManager locationManager] currentHeading].trueHeading;
    CLLocation * targetLocation = self.targetLocation;
    
    // Current location
    double lat1 = [[LocationManager locationManager] currentLatitude];
    double lon1 = [[LocationManager locationManager] currentLongitude];
    
    // Target location
    float lat2 = targetLocation.coordinate.latitude;
    float lon2 = targetLocation.coordinate.longitude;
    
    // Distance between coordinates
    // double distance = [[[LocationManager locationManager] currentLocation] distanceFromLocation: targetLocation];
    
    float headingToTarget = atan2(sin(lon2 - lon1) * cos(lat2), cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1));
    float headingInDegrees = radiansToDegrees(headingToTarget);
    
    float compassHeading = headingInDegrees - trueAngle;
    
    if (compassHeading < 0)
        compassHeading = compassHeading + 360;
    
    NSLog(@"compassHeading: %f", compassHeading);
    return degreesToRadians(compassHeading);
}

@end
