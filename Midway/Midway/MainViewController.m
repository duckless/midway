//
//  MainViewController.m
//  Midway
//
//  Created by Rostislav Raykov on 11/22/13.
//  Copyright (c) 2013 duckless. All rights reserved.
//
#import "SessionModel.h"
#import "MainViewController.h"
#import "InviteMethodsViewController.h"

@interface MainViewController ()

- (IBAction)inviteAFriend:(id)sender;

@property ABRecordID personID;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    [self dismissViewControllerAnimated:NO completion:nil];
    self.personID = ABRecordGetRecordID(person);
    [[SessionModel sharedSessionModel] startSessionWith:ABRecordGetRecordID(person)];
    [self performSegueWithIdentifier:@"inviteMethods" sender:self];
    return NO;
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"inviteMethods"]) {
        UINavigationController  *navController = (UINavigationController*)[segue destinationViewController];
        InviteMethodsViewController *targetController = (InviteMethodsViewController *) [[navController viewControllers] objectAtIndex: 0];
        [targetController setPersonID:self.personID];
    }
}

#pragma IB actions

- (IBAction)inviteAFriend:(id)sender {
    SessionModel * sharedSessionModel = [SessionModel sharedSessionModel];
    [sharedSessionModel retrieveSessionID];
    
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentViewController:picker animated:YES completion:Nil];
}

-(IBAction)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


-(IBAction)unwindInvite:(UIStoryboardSegue *)sender
{
  

}

-(IBAction)unwindNavigation:(UIStoryboardSegue *)sender
{
    [[SessionModel sharedSessionModel] clearSession];
}


@end
