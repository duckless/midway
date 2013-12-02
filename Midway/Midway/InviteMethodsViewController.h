//
//  InviteMethodsViewController.h
//  Midway
//
//  Created by Olof Bjerke on 2013-11-29.
//  Copyright (c) 2013 duckless. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "AddressBookUI/AddressBookUI.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "MessageUI/MFMessageComposeViewController.h"

@interface InviteMethodsViewController : UITableViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property ABRecordID personID;

@end
