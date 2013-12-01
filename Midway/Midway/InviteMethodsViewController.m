//
//  InviteMethodsViewController.m
//  Midway
//
//  Created by Olof Bjerke on 2013-11-29.
//  Copyright (c) 2013 duckless. All rights reserved.
//
#import "SessionModel.h"
#import "InviteMethodsViewController.h"


@interface InviteMethodsViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *cellTapped;
@property NSMutableArray *inviteMethods;
-(void) structureTable;

@end

@implementation InviteMethodsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _inviteMethods = [[NSMutableArray alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    
    [self structureTable];
    
    [[self tableView]  reloadData];
    
}


-(void) structureTable {
    
    if(self.inviteMethods.count == 0)
    {
    
        // One for email and one for phone numbers
        [self.inviteMethods addObject: ([[NSMutableArray alloc] init])];
        [self.inviteMethods addObject: ([[NSMutableArray alloc] init])];
        
    
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
        ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(addressBook, self.personID);
    
        ABMultiValueRef emailMultiValue = ABRecordCopyValue(personRef, kABPersonEmailProperty);
        NSArray *emailAddresses = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailMultiValue);
        
        [[self.inviteMethods objectAtIndex:0] addObjectsFromArray: [[SessionModel sharedSessionModel] inviteesEmails]];
    /*
     for (NSString *email  in emailAddresses) {
     [self.inviteMethods addObject:email];
     }
     */
        ABMultiValueRef phoneMultiValue = ABRecordCopyValue(personRef, kABPersonPhoneProperty);
        NSArray *phoneNumbers = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneMultiValue);
    /*
     for (NSString *number  in phoneNumbers) {
     [self.inviteMethods addObject: number];
     }
     */
        [[self.inviteMethods objectAtIndex:1] addObjectsFromArray:[[SessionModel sharedSessionModel] inviteesPhoneNumbers]];
    
        NSString *email = [emailAddresses firstObject];
    
        NSString *name = (__bridge NSString *)(ABRecordCopyValue(personRef, kABPersonFirstNameProperty));
        NSLog(@"Email is: %@", email);
        NSString * title = [[NSString alloc] initWithFormat:@"Invite %@", name];
        self.title = title;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return ([[self.inviteMethods objectAtIndex:section] count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"inviteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[self.inviteMethods objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"Email";
            break;
        case 1:
            sectionName = @"SMS";
            break;
            // ...
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



@end
