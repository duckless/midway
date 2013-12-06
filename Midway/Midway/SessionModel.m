//
//  SessionModel.m
//  Midway
//
//  Created by Olof Bjerke on 2013-12-01.
//  Copyright (c) 2013 duckless. All rights reserved.
//
#import "AddressBookUI/AddressBookUI.h"
#import "SessionModel.h"

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


#warning missing implementation
- (void) retrieveSessionID {
    // This message should contact the server in the
    // background, retrieving a new session ID to be used when an email or SMS is sent
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                                        initWithURL:[NSURL
                                                      URLWithString:@"http://midway.zbrox.org/session/start"]];
        
        [request setHTTPMethod:@"POST"];
        
        NSString *postString = [[NSString alloc] initWithFormat:@"uuid=%@&location=%@", nil, nil];
        
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postString length]]
                                           forHTTPHeaderField:@"Content-length"];
        
        [request setHTTPBody:[postString
                              dataUsingEncoding:NSUTF8StringEncoding]];
        
        _sessionIDconnection =[[NSURLConnection alloc] initWithRequest:request
                                        delegate:self];
        
        _sessionIDdata = [NSMutableData data];
        [_sessionIDconnection start];
    });
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(!data.length)
        return;
    
    if (connection == _sessionIDconnection){
        [_sessionIDdata appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(connection == _sessionIDconnection)
    {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:_sessionIDdata
                              options:kNilOptions
                              error:&error];
        _sessionID = [json objectForKey:@"session_id"];
    }
}

-(double) headingTowardTargetLocation
{
    NSInteger trueAngle = [self currentHeading].trueHeading;
    CLLocation * targetLocation = self.targetLocation;
    
    // Current location
    double lat1 = [self currentLatitude];
    double lon1 = [self currentLongitude];
    
    // Target location
    float lat2 = targetLocation.coordinate.latitude;
    float lon2 = targetLocation.coordinate.longitude;
    
    
    float headingToTarget = atan2(sin(lon2 - lon1) * cos(lat2), cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1));
    float headingInDegrees = radiansToDegrees(headingToTarget);
    
    float compassHeading = headingInDegrees - trueAngle;
    
    if (compassHeading < 0)
        compassHeading = compassHeading + 360;
    
    // NSLog(@"compassHeading: %f", compassHeading);
    return degreesToRadians(compassHeading);
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
    double heading = [self headingTowardTargetLocation];
    double distance = [[self currentLocation] distanceFromLocation: self.targetLocation];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject: [[NSNumber alloc] initWithDouble:heading] forKey:@"heading"];
    [userInfo setObject: [[NSNumber alloc] initWithDouble:distance] forKey:@"distance"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"updateCompass" object:nil userInfo:userInfo];
}

@end
