//
//  MainViewController.m
//  Midway
//
//  Created by Rostislav Raykov on 11/22/13.
//  Copyright (c) 2013 duckless. All rights reserved.
//
#import "SessionModel.h"
#import "MainViewController.h"

@interface MainViewController ()

- (IBAction)inviteAFriend:(id)sender;
- (void) sendText;
- (void) sendMail;

@property ABRecordID personID;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

#pragma Text messaging

- (void) sendText {
 
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        SessionModel *sharedSessionModel = [SessionModel sharedSessionModel];
        controller.body = [[NSString alloc] initWithFormat:@"Hi! Want to grab a fika with me? grabafika://%@", sharedSessionModel.sessionID ];
        controller.messageComposeDelegate = self;
        controller.topViewController.navigationController.navigationBar.tintColor = [UIColor colorWithRed:1.000 green:0.620 blue:0.000 alpha:1.000];
        [self presentViewController:controller animated:YES completion:nil];
    }
    controller = nil;
    
}

-(void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if(result == MessageComposeResultCancelled)
    {
        NSLog(@"cancelled");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if(result == MessageComposeResultFailed)
    {
        NSLog(@"failed");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if(result == MessageComposeResultSent)
    {
        NSLog(@"Send sms!");
        [self dismissViewControllerAnimated:NO completion: ^{
            [self performSegueWithIdentifier:@"waitingScreen" sender:self];
        }];
    }
}

#pragma Email

- (void) sendMail {
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Grab a fika"];
    SessionModel *sharedSessionModel = [SessionModel sharedSessionModel];
    NSString *text = [[NSString alloc] initWithFormat:@"Hi! Want to grab a fika with me? <br/> <a href='grabafika://%@'>Tap here!</a> to use the Grab a Fika iOS app.", sharedSessionModel.sessionID];
    [controller setMessageBody:text isHTML:YES];
    if (controller) [self presentViewController:controller animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    [self dismissViewControllerAnimated:NO completion:nil];
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
        [self performSegueWithIdentifier:@"waitingScreen" sender:self];
    }
}


#pragma IB actions

- (IBAction)inviteAFriend:(id)sender {
    SessionModel * sharedSessionModel = [SessionModel sharedSessionModel];
    [sharedSessionModel retrieveSessionID];
    [self sendMail];
}

-(IBAction)unwindInvite:(UIStoryboardSegue *)sender
{
    [[SessionModel sharedSessionModel] clearSession];
}

-(IBAction)unwindNavigation:(UIStoryboardSegue *)sender
{
    [[SessionModel sharedSessionModel] clearSession];
}


@end
