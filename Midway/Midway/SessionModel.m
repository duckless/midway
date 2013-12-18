//
//  SessionModel.m
//  Midway
//
//  Created by Olof Bjerke on 2013-12-01.
//  Copyright (c) 2013 duckless. All rights reserved.
//
#import "AddressBookUI/AddressBookUI.h"
#import "SessionModel.h"
#import "LocationManager.h"
#import "Parse/PFInstallation.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180 / M_PI)

@interface SessionModel ()

@property CLLocationManager *locationManager;
@property ABRecordID personID;
@property NSMutableArray *emails;
@property NSMutableArray *phoneNumbers;
@property NSString *inviteeName;
@property NSTimeInterval timer;

@property CLLocation *targetLocation;

- (void) retrieveSessionID;
- (void) gatherInviteeInfo;
- (void) updateCompass;

@end
@implementation SessionModel

@synthesize sessionID = _sessionID;
@synthesize sessionIsActive = _sessionIsActive;

-(id) init {
    self = [super init];
    if(self) {
        _emails = [[NSMutableArray alloc] init];
        _phoneNumbers = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"updateSessionCompass" object:nil];
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

- (void) setSessionIsActive:(BOOL)sessionIsActive
{
    _sessionIsActive = sessionIsActive;
    [[NSUserDefaults standardUserDefaults] setBool:_sessionIsActive forKey:@"sessionIsActive"];
}

- (BOOL) sessionIsActive
{
    if ( ! _sessionIsActive)
    {
        _sessionIsActive = [[NSUserDefaults standardUserDefaults] boolForKey:@"sessionIsActive"];
    }
    
    return _sessionIsActive;
}

- (void) setSessionID:(NSString *)sessionID
{
    _sessionID = sessionID;
    [[NSUserDefaults standardUserDefaults] setObject:_sessionID forKey:@"sessionID"];
}

- (NSString *) sessionID
{
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"sessionID"]) {
        _sessionID = [[NSUserDefaults standardUserDefaults] stringForKey:@"sessionID"];
    } else {
        [self retrieveSessionID];
    }
    return _sessionID;
}

- (void) clearSession
{
    [self setSessionID:nil];
    [self setSessionIsActive:NO];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sessionID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sessionIsActive"];
    [self requestWithAction:@"cancel"];
}

#pragma Contact list

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
}

- (void) gatherInviteeInfo {
    
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

#pragma Networking

// First connection to server
// This message should contact the server in the background, retrieving a new session ID to be used when an email or SMS is sent
- (void) retrieveSessionID {
    NSDictionary *json = [self requestWithAction:@"start"];
    
    [self setSessionID: [json objectForKey:@"session_id"]];
}


// Second connection to server
// This method is triggered when a user taps on a link with the grabafika:// URI scheme.
// Seems to be working fine. Retrieves a café close by.
-(void)acceptSessionWith:(NSString *)sessionID
{
    [self setSessionID:sessionID];
    NSDictionary *json = [self requestWithAction:@"join"];
    
    NSString *responseLocation = [json objectForKey:@"location"];
    NSArray *latLong = [responseLocation componentsSeparatedByString:@","];
    [self setTargetLocation: [[CLLocation alloc]
                              initWithLatitude:[latLong[0] doubleValue]
                              longitude:[latLong[1] doubleValue]]];
    
    [self setSessionIsActive:YES];
}

- (NSDictionary*) requestWithAction: (NSString*)action
{
    NSString *url = [NSString stringWithFormat:@"http://midway.zbrox.org/session/%@", action];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL
                                                 URLWithString:url]];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *token = [[PFInstallation currentInstallation] deviceToken];
    NSString *location = [[NSString alloc] initWithFormat:@"%f,%f",
                          [[LocationManager shared] currentLocation].coordinate.latitude,
                          [[LocationManager shared] currentLocation].coordinate.longitude,
                          nil];
    
    NSString *postString;
    if (_sessionID)
    {
        postString = [[NSString alloc] initWithFormat:@"session_id=%@&uuid=%@&location=%@",
                                _sessionID,
                                token,
                                location,
                                nil];
    } else {
        postString = [[NSString alloc] initWithFormat:@"uuid=%@&location=%@",
                                token,
                                location,
                                nil];
    }
    
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postString length]]
   forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[postString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse *response = [[NSURLResponse alloc] init];
    NSError *error = [[NSError alloc] init];
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    return [NSJSONSerialization
                          JSONObjectWithData:receivedData
                          options:kNilOptions
                          error:&error];
}


// Run this method to retrieve a new target location?
// Method runs every x seconds to retrieve a new target café
- (void) updateTargetLocation {
    NSDictionary *json = [self requestWithAction:@"update"];
    NSString *responseLocation = [json objectForKey:@"location"];
    NSArray *latLong = [responseLocation componentsSeparatedByString:@","];
    
    [self setTargetLocation: [[CLLocation alloc]
                              initWithLatitude:[latLong[0] doubleValue]
                              longitude:[latLong[1] doubleValue]]];
    if ([self targetLocation])
    {
        [self setSessionIsActive:YES];
    } else {
        [self setSessionIsActive:NO];
    }
}

#pragma helper?

- (void) updateCompass
{
    double heading = [self headingTowardTargetLocation];
    double distance = [[[LocationManager shared] currentLocation] distanceFromLocation: self.targetLocation];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject: [[NSNumber alloc] initWithDouble:heading] forKey:@"heading"];
    [userInfo setObject: [[NSNumber alloc] initWithDouble:distance] forKey:@"distance"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"updateCompass" object:nil userInfo:userInfo];
}

-(double) headingTowardTargetLocation
{
    NSInteger trueAngle = [[LocationManager shared] currentHeading].trueHeading;
    
    // Current location
    double lat1 = [[LocationManager shared] currentLatitude];
    double lon1 = [[LocationManager shared] currentLongitude];
    
    // Target location
    float lat2 = self.targetLocation.coordinate.latitude;
    float lon2 = self.targetLocation.coordinate.longitude;
    
    float headingToTarget = atan2(sin(lon2 - lon1) * cos(lat2), cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1));
    float headingInDegrees = radiansToDegrees(headingToTarget);
    
    float compassHeading = headingInDegrees - trueAngle;
    
    if (compassHeading < 0)
        compassHeading = compassHeading + 360;
    
    return degreesToRadians(compassHeading);
}

- (void) receiveNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:@"updateSessionCompass"])
    {
        [self updateCompass];
    }
}

@end
