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

@property BOOL sessionIsActive;

@property NSURLConnection *sessionIDconnection;
@property NSMutableData *sessionIDdata;
@property NSTimeInterval timer;

@property NSData *joinSessionData;

@property NSURLConnection *updateSessionConnection;
@property NSData *updateSessionData;

@property CLLocation *targetLocation;

- (void) retrieveSessionID;
- (void) gatherInviteeInfo;
- (void) updateCompass;

@end
@implementation SessionModel

@synthesize sessionID = _sessionID;

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

- (void) setSessionID:(NSString *)sessionID
{
    _sessionID = sessionID;
    [[NSUserDefaults standardUserDefaults] setObject:_sessionID forKey:@"sessionID"];
}

- (NSString *) sessionID
{
    if (_sessionID)
    {
        return _sessionID;
    } else {
        return [[NSUserDefaults standardUserDefaults] stringForKey:@"sessionID"];
    }
}

- (void) clearSession
{
    [self setSessionID:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sessionID"];
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
    NSLog(@"Retrieve a sessionID...");
    NSString *token = [[PFInstallation currentInstallation] deviceToken];
    
    NSString *location = [[NSString alloc] initWithFormat:@"%f,%f",
                          [[LocationManager shared] currentLocation].coordinate.latitude,
                          [[LocationManager shared] currentLocation].coordinate.longitude,
                          nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL
                                                 URLWithString:@"http://midway.zbrox.org/session/start"]];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [[NSString alloc] initWithFormat:@"uuid=%@&location=%@",
                            token,
                            location,
                            nil];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postString length]]
   forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[postString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    _sessionIDconnection =[[NSURLConnection alloc] initWithRequest:request
                                                          delegate:self];
    
    _sessionIDdata = [NSMutableData data];
    [_sessionIDconnection start];
}

// Second connection to server
// This method is triggered when a user taps on a link with the grabafika:// URI scheme.
// Seems to be working fine. Retrieves a café close by.
-(void)acceptSessionWith:(NSString *)sessionID
{
    NSString *token = [[PFInstallation currentInstallation] deviceToken];
    
    NSString *location = [[NSString alloc] initWithFormat:@"%f,%f",
                          [[LocationManager shared] currentLocation].coordinate.latitude,
                          [[LocationManager shared] currentLocation].coordinate.longitude,
                          nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL
                                                 URLWithString:@"http://midway.zbrox.org/session/join"]];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [[NSString alloc] initWithFormat:@"session_id=%@&uuid=%@&location=%@",
                            sessionID,
                            token,
                            location,
                            nil];

    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postString length]]
    forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[postString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSURLResponse *response = [[NSURLResponse alloc] init];
    NSError *error = [[NSError alloc] init];
    self.joinSessionData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:self.joinSessionData
                          options:kNilOptions
                          error:&error];
    
    NSString *responseLocation = [json objectForKey:@"location"];
    NSArray *latLong = [responseLocation componentsSeparatedByString:@","];
    [self setTargetLocation: [[CLLocation alloc]
                              initWithLatitude:[latLong[0] doubleValue]
                              longitude:[latLong[1] doubleValue]]];
    
    [self setSessionID:sessionID];
}


// Run this method to retrieve a new target location?
// Method runs every x seconds to retrieve a new target café
- (void) updateTargetLocation {
    NSString *token = [[PFInstallation currentInstallation] deviceToken];
    
    NSString *location = [[NSString alloc] initWithFormat:@"%f,%f",
                          [[LocationManager shared] currentLocation].coordinate.latitude,
                          [[LocationManager shared] currentLocation].coordinate.longitude,
                          nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL
                                                 URLWithString:@"http://midway.zbrox.org/session/update"]];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [[NSString alloc] initWithFormat:@"session_id=%@&uuid=%@&location=%@",
                            [self sessionID],
                            token,
                            location,
                            nil];

    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postString length]]
   forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[postString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSURLResponse *response = [[NSURLResponse alloc] init];
    NSError *error = [[NSError alloc] init];
    _updateSessionData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:_updateSessionData
                          options:kNilOptions
                          error:&error];
    NSString *responseLocation = [json objectForKey:@"location"];
    NSArray *latLong = [responseLocation componentsSeparatedByString:@","];

    [self setTargetLocation: [[CLLocation alloc]
                              initWithLatitude:[latLong[0] doubleValue]
                              longitude:[latLong[1] doubleValue]]];
}

#pragma connection helpers

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(!data.length)
        return;
    
    if (connection == _sessionIDconnection) {
        [_sessionIDdata appendData:data];
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"retrive session id?");
    if(connection == _sessionIDconnection)
    {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:_sessionIDdata
                              options:kNilOptions
                              error:&error];
        
        [self setSessionID: [json objectForKey:@"session_id"]];
    }
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Did Receive Response");
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    NSLog(@"Did Fail");
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
