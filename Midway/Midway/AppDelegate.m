//
//  AppDelegate.m
//  Midway
//
//  Created by Rostislav Raykov on 11/22/13.
//  Copyright (c) 2013 duckless. All rights reserved.
//
#import "AppDelegate.h"
#import "SessionModel.h"
#import "Parse/Parse.h"
#import "GeoPositionViewController.h"
@interface AppDelegate()

-(void) joinSession;

@property NSString *url;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"parse_config" ofType:@"plist"];
    NSDictionary *parse_config = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    [Parse setApplicationId:[parse_config objectForKey:@"appId"]
                  clientKey:[parse_config objectForKey:@"clientKey"]];
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
    return YES;
    
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Received remote notification");
    [PFPush handlePush:userInfo];
    
    [[SessionModel sharedSessionModel] updateTargetLocation];
    [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    [self.window.rootViewController performSegueWithIdentifier:@"geoPosition" sender:self];
}



- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    self.url = url.host;
    NSLog(@"opening a link!");
    SessionModel * sharedSessionModel = [SessionModel sharedSessionModel];
 
    // Is a session already active?
    if(sharedSessionModel.sessionID != nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Session is active" message:@"A session is already active. Do you want to cancel the current session and join the new one?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Join session",nil];
        [alert show];
    }
    else
    {
        [self joinSession];
    }
    return YES;
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSLog(@"OK Tapped. Join Session");
        [self joinSession];
    }
    else {
        NSLog(@"Cancel Tapped.");
    }
}


- (void) joinSession
{
    [[SessionModel sharedSessionModel] acceptSessionWith:self.url];
    [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    [self.window.rootViewController performSegueWithIdentifier:@"geoPosition" sender:self];
}

#pragma Auto generated

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
