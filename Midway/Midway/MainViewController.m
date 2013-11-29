//
//  MainViewController.m
//  Midway
//
//  Created by Rostislav Raykov on 11/22/13.
//  Copyright (c) 2013 duckless. All rights reserved.
//

#import "MainViewController.h"
#import "InviteMethodsViewController.h"

@interface MainViewController ()

- (IBAction)inviteAFriend:(id)sender;
-(void) displayPerson:(ABRecordRef)person;
@property ABRecordID personID;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepare for segue");
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
    if([[segue identifier] isEqualToString:@"inviteMethods"]) {
        UINavigationController  *navController = (UINavigationController*)[segue destinationViewController];
        InviteMethodsViewController *targetController = (InviteMethodsViewController *) [[navController viewControllers] objectAtIndex: 0];
        [targetController setPersonID:self.personID];
    }
}



- (IBAction)inviteAFriend:(id)sender {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentViewController:picker animated:YES completion:Nil];
}

-(IBAction)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    self.personID = ABRecordGetRecordID(person);
//    [self displayPerson:person];
    [self dismissViewControllerAnimated:NO completion:nil];
    [self performSegueWithIdentifier:@"inviteMethods" sender:self];
    return NO;
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    return NO;
}

-(void) displayPerson:(ABRecordRef)person {
    
//    NSString *name = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    ABMultiValueRef emailMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty);
    NSArray *emailAddresses = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailMultiValue);
    
    NSString *email = [emailAddresses firstObject];
    
    self.labelOfInvited.text  = email;
    
}


@end
