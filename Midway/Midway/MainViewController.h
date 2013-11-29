//
//  MainViewController.h
//  Midway
//
//  Created by Rostislav Raykov on 11/22/13.
//  Copyright (c) 2013 duckless. All rights reserved.
//

#import "FlipsideViewController.h"
#import "AddressBookUI/AddressBookUI.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate>


@property (weak, nonatomic) IBOutlet UILabel *labelOfInvited;

@end
