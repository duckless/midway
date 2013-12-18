//
//  MainViewController.h
//  Midway
//
//  Created by Rostislav Raykov on 11/22/13.
//  Copyright (c) 2013 duckless. All rights reserved.
//

#import "MessageUI/MFMessageComposeViewController.h"

@interface MainViewController : UIViewController <MFMessageComposeViewControllerDelegate>
-(IBAction)unwindInvite:(UIStoryboardSegue *)sender;

@end
