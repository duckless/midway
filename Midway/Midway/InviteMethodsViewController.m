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
- (void) sendMail: (NSString *) recipent;
- (void) sendText: (NSString *) recipent;

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

-(void) viewWillAppear:(BOOL)animated
{
    
    [self structureTable];
    
    [[self tableView]  reloadData];
    
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
       [self sendMail: [tableView cellForRowAtIndexPath:indexPath].textLabel.text];
    else if (indexPath.section == 1)
       [self sendText: [tableView cellForRowAtIndexPath:indexPath].textLabel.text];
}


- (void) sendMail: (NSString *) recipent {
    NSMutableArray *recipents = [[NSMutableArray alloc] init];
    [recipents addObject:recipent];
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Grab a fika"];
    [controller setToRecipients: recipents];
    SessionModel *sharedSessionModel = [SessionModel sharedSessionModel];
    NSString *text = [[NSString alloc] initWithFormat:@"Hi! Want to grab a fika with me? <br/> <a href='grabafika://%@'>Tap here!</a> to use the Grab a Fika iOS app.", sharedSessionModel.sessionID];
    [controller setMessageBody:text isHTML:YES];
    if (controller) [self presentViewController:controller animated:YES completion:nil];
}

- (void) sendText: (NSString *) recipent {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        SessionModel *sharedSessionModel = [SessionModel sharedSessionModel];
        controller.body = [[NSString alloc] initWithFormat:@"Hi! Want to grab a fika with me? grabafika://%@", sharedSessionModel.sessionID ];
        controller.recipients = [NSArray arrayWithObjects: recipent, nil];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
    
}

-(void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if(result == MessageComposeResultCancelled)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if(result == MessageComposeResultFailed)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        NSLog(@"Send sms!");
        [self dismissViewControllerAnimated:NO completion:nil];
        [self performSegueWithIdentifier:@"waitingForAccept" sender:self];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    [self dismissViewControllerAnimated:NO completion:nil];
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
        [self performSegueWithIdentifier:@"waitingForAccept" sender:self];
    }
    NSLog(@"GO to waiting!");
}

#pragma mark - Table view data source

-(void) structureTable {
    
    if(self.inviteMethods.count == 0)
    {
        // One for email and one for phone numbers
        [self.inviteMethods addObject: ([[NSMutableArray alloc] init])];
        [self.inviteMethods addObject: ([[NSMutableArray alloc] init])];
        
        [[self.inviteMethods objectAtIndex:0] addObjectsFromArray: [[SessionModel sharedSessionModel] inviteesEmails]];
        [[self.inviteMethods objectAtIndex:1] addObjectsFromArray:[[SessionModel sharedSessionModel] inviteesPhoneNumbers]];
        
        self.title = [[SessionModel sharedSessionModel] inviteesName];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.inviteMethods.count;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSLog(@"chose %ld", (long)indexPath.row);
}

@end
