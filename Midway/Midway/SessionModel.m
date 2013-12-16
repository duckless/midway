//
//  SessionModel.m
//  Midway
//
//  Created by Olof Bjerke on 2013-12-01.
//  Copyright (c) 2013 duckless. All rights reserved.
//
#import "AddressBookUI/AddressBookUI.h"
#import "SessionModel.h"
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
@property NSMutableData *updateSessionData;

@property CLLocation *targetLocation;
@property NSString *venueName;

- (void) retrieveSessionID;
- (void) gatherInviteeInfo;
- (void) updateCompass;

@end
@implementation SessionModel

-(id) init {
    self = [super init];
    if(self) {
        _emails = [[NSMutableArray alloc] init];
        _phoneNumbers = [[NSMutableArray alloc] init];
        
        // Location mananger setup
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.headingFilter = 1;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.delegate= self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLocationUpdates) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUpdatingSignificantLocation) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUpdatingLocation) name:UIApplicationDidBecomeActiveNotification object:nil];
        
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
    NSLog(@"got an user record ID!");
    
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

#pragma Networking

- (void) retrieveSessionID {
    NSLog(@"retrive");
    // First connection to server
    // This message should contact the server in the background, retrieving a new session ID to be used when an email or SMS is sent
    
    NSString *token = [[PFInstallation currentInstallation] deviceToken];
    
    NSString *location = [[NSString alloc] initWithFormat:@"%f,%f",
                          self.currentLocation.coordinate.latitude,
                          self.currentLocation.coordinate.longitude,
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

-(void)acceptSessionWith:(NSString *)sessionID
{
    NSLog(@"accept session");
    // Second connection to server
    // This method is triggered when a user taps on a link with the grabafika:// URI scheme.
    
    NSString *token = [[PFInstallation currentInstallation] deviceToken];
    
    NSString *location = [[NSString alloc] initWithFormat:@"%f,%f",
                          self.currentLocation.coordinate.latitude,
                          self.currentLocation.coordinate.longitude,
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
                          JSONObjectWithData:_joinSessionData
                          options:kNilOptions
                          error:&error];
    self.sessionID = [json objectForKey:@"session_id"];
    NSString *responseLocation = [json objectForKey:@"location"];
    NSArray *latLong = [responseLocation componentsSeparatedByString:@","];
    [self setTargetLocation: [[CLLocation alloc]
                              initWithLatitude:[latLong[0] doubleValue]
                              longitude:[latLong[1] doubleValue]]];
    [self setVenueName:[json objectForKey:@"venue_name"]];
}



- (void) getLocation
{
    NSLog(@"get location");
    // This method is triggered by a push notification after a session is accepted
    // Third connection to server
    
    NSString *token = [[PFInstallation currentInstallation] deviceToken];
    
    NSString *location = [[NSString alloc] initWithFormat:@"%f,%f",
                          self.currentLocation.coordinate.latitude,
                          self.currentLocation.coordinate.longitude,
                          nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL
                                                 URLWithString:@"http://midway.zbrox.org/session/update"]];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [[NSString alloc] initWithFormat:@"session_id=%@&uuid=%@&location=%@",
                            self.sessionID,
                            token,
                            location,
                            nil];
    
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postString length]]
    forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[postString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSURLResponse *response = [[NSURLResponse alloc] init];
    NSError *error = [[NSError alloc] init];
    _joinSessionData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:_joinSessionData
                          options:kNilOptions
                          error:&error];

    NSString *responseLocation = [json objectForKey:@"location"];
    NSArray *latLong = [responseLocation componentsSeparatedByString:@","];
    [self setTargetLocation: [[CLLocation alloc]
                              initWithLatitude:[latLong[0] doubleValue]
                              longitude:[latLong[1] doubleValue]]];
    [self setVenueName:[json objectForKey:@"venue_name"]];
}

- (void) updateTargetLocation {
    // Run this method to retrieve a new target location?
    // Method runs every x seconds to retrieve a new target café
 
    
    // Timer used to reduce server requests;
    if(!self.timer)
    {
        self.timer = [[NSDate date] timeIntervalSince1970] + 10;
        NSLog(@"adding time");
    }
    if (self.timer > [[NSDate date] timeIntervalSince1970]) {
        return;
    }
    else {
        self.timer = [[NSDate date] timeIntervalSince1970] + 10;
        NSLog(@"update location");
    }
    
  
    NSString *token = [[PFInstallation currentInstallation] deviceToken];
    
    NSString *location = [[NSString alloc] initWithFormat:@"%f,%f",
                          self.currentLocation.coordinate.latitude,
                          self.currentLocation.coordinate.longitude,
                          nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL
                                                 URLWithString:@"http://midway.zbrox.org/session/update"]];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [[NSString alloc] initWithFormat:@"session_id=%@&uuid=%@&location=%@",
                            self.sessionID,
                            token,
                            location,
                            nil];
    
    @try {
        NSLog(postString);
    }
    @catch (NSException *exception) {

    }
    @finally {

    }

    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postString length]]
   forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[postString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSURLResponse *response = [[NSURLResponse alloc] init];
    NSError *error = [[NSError alloc] init];
    _joinSessionData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:_joinSessionData
                          options:kNilOptions
                          error:&error];
    NSString *responseLocation = [json objectForKey:@"location"];
    NSArray *latLong = [responseLocation componentsSeparatedByString:@","];
    [self setTargetLocation: [[CLLocation alloc]
                              initWithLatitude:[latLong[0] doubleValue]
                              longitude:[latLong[1] doubleValue]]];
    [self setVenueName:[json objectForKey:@"venue_name"]];

}

#pragma connection helpers

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"did receive");
    if(!data.length)
        return;
    
    if (connection == _sessionIDconnection) {
        [_sessionIDdata appendData:data];
    }
    
    if (connection == _updateSessionConnection) {
        [_updateSessionData appendData:data];
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

        self.sessionID = [json objectForKey:@"session_id"];
    }
    
    if(connection == _updateSessionConnection)
    {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:_updateSessionData
                              options:kNilOptions
                              error:&error];
        
        NSString *responseLocation = [json objectForKey:@"location"];
        NSArray *latLong = [responseLocation componentsSeparatedByString:@","];
        [self setTargetLocation: [[CLLocation alloc]
                                  initWithLatitude:[latLong[0] doubleValue]
                                  longitude:[latLong[1] doubleValue]]];
        [self setVenueName:[json objectForKey:@"venue_name"]];
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

#pragma Location manager

- (void) startUpdatingLocation
{
    NSLog(@"starting location services");
    [self.locationManager startUpdatingHeading];
    [self.locationManager startUpdatingLocation];
}

-(void) startUpdatingSignificantLocation
{
    NSLog(@"starting significant");
    [self.locationManager startMonitoringSignificantLocationChanges];
}

-(void) stopLocationUpdates
{
    NSLog(@"Stopping location services");
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
}

- (CLHeading *) currentHeading
{
    return self.locationManager.heading;
}

- (CLLocation *) currentLocation
{
    return self.locationManager.location;
}

-(double) currentLatitude
{
    return self.locationManager.location.coordinate.latitude;;
}

-(double) currentLongitude
{
    return self.locationManager.location.coordinate.longitude;
}


#pragma location manager delegate

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self updateCompass];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    [self updateCompass];
}

#pragma helper?

- (void) updateCompass
{
    [self updateTargetLocation];
    
    double heading = [self headingTowardTargetLocation];
    double distance = [[self currentLocation] distanceFromLocation: self.targetLocation];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject: [[NSNumber alloc] initWithDouble:heading] forKey:@"heading"];
    [userInfo setObject: [[NSNumber alloc] initWithDouble:distance] forKey:@"distance"];
    @try {
        [userInfo setObject:self.venueName forKey:@"venueName"];
    }
    @catch (NSException * e) {

    }
    @finally {

    }
    [[NSNotificationCenter defaultCenter] postNotificationName: @"updateCompass" object:nil userInfo:userInfo];
}

-(double) headingTowardTargetLocation
{
    NSInteger trueAngle = [self currentHeading].trueHeading;
    
    // Current location
    double lat1 = [self currentLatitude];
    double lon1 = [self currentLongitude];
    
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

@end
