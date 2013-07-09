//
//  StopListTableViewController.m
//  Utah Bus
//
//  Created by Ravi Alla on 4/19/13.
//  Copyright (c) 2013 Ravi Alla. All rights reserved.
//

#import "StopListTableViewController.h"
#import "LocationAnnotation.h"
#import "StopInfoTableViewController.h"
#import "UtaAPIKey.h"
#import "UtaFetcher.h"

@interface StopListTableViewController ()
@property (nonatomic, strong) NSArray *stopInfoArray;
@property (nonatomic, strong) UtaFetcher *utaFetcher;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation StopListTableViewController
@synthesize stopInfoDictArray  = _stopInfoDictArray;
@synthesize stopInfoDelegate = _stopInfoDelegate;
@synthesize stopInfoArray = _stopInfoArray;
@synthesize spinner = _spinner;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (UtaFetcher *) utaFetcher
{
    if (!_utaFetcher) _utaFetcher = [[UtaFetcher alloc] init];
    return _utaFetcher;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Closest Stop List";

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.stopInfoDictArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"stop list cells";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    LocationAnnotation *stopAnnotation = [self.stopInfoDictArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [[stopAnnotation vehicleInfo] objectForKey:@"StopName"];
    cell.detailTextLabel.text = [[stopAnnotation vehicleInfo]objectForKey:@"StopDirection"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.spinner startAnimating];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryView:self.spinner];
    LocationAnnotation *stopAnnotation = [self.stopInfoDictArray objectAtIndex:indexPath.row];
    [self showBuses:[[stopAnnotation vehicleInfo]objectForKey:@"StopID"]];
}

- (void) showBuses:(NSString *)atStop
{
    NSString *url = [NSString stringWithFormat:@"http://api.rideuta.com/SIRI/SIRI.svc/StopMonitor?stopid=%@&minutesout=30&onwardcalls=true&filterroute=&usertoken=%@",atStop,UtaAPIKey];
    dispatch_queue_t xmlGetter = dispatch_queue_create("UTA xml getter", NULL);
    dispatch_async(xmlGetter, ^{
        self.stopInfoArray =  [NSArray arrayWithArray:[self.utaFetcher executeStopFetcher:url]];
        dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"show stop info" sender:self];
            [self.spinner stopAnimating];
        });
    });
    dispatch_release(xmlGetter);
  self.stopInfoArray = nil;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setStopDescriptionForTable:self.stopInfoArray];
}

@end
