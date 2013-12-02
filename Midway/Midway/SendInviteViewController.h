//
//  SendInviteViewController.h
//  Midway
//
//  Created by Olof Bjerke on 2013-12-01.
//  Copyright (c) 2013 duckless. All rights reserved.
//
#import <MessageUI/MFMailComposeViewController.h>
#import "MessageUI/MFMessageComposeViewController.h"
#import <UIKit/UIKit.h>

@interface SendInviteViewController : UIViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@end
