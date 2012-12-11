//
//  FavoritesTableViewController.m
//  Utah Bus
//
//  Created by Ravi Alla on 8/13/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import "FavoritesTableViewController.h"
#import "UTAViewController.h"
#import "UtaFetcher.h"
#import "StopInfoTableViewController.h"

@interface FavoritesTableViewController ()<UITabBarControllerDelegate,RefreshStopDelegate>
@property (nonatomic, strong) NSMutableArray *favoriteRoutes;
@property (nonatomic, strong) NSMutableArray *favoriteStops;
@property (nonatomic, strong) UtaFetcher *utaFetcher;
@property (nonatomic, strong) NSArray *stopInfoArray;
@property (strong, nonatomic) Reachability *internetReachable;
@property (strong, nonatomic) NSArray *stopInfo;
@property BOOL internetActive;

@end

@implementation FavoritesTableViewController
@synthesize favoriteRoutes = _favoriteRoutes;
@synthesize favoriteStops = _favoriteStops;
@synthesize routeDelegate = _routeDelegate;
@synthesize utaFetcher = _utaFetcher;
@synthesize internetReachable = _internetReachable;
@synthesize stopInfo = _stopInfo;

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

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"favorite.routes"])self.favoriteRoutes = [[defaults objectForKey:@"favorite.routes"]mutableCopy];
    if ([defaults objectForKey:@"favorite.stops"])self.favoriteStops = [[defaults objectForKey:@"favorite.stops"]mutableCopy];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBarController setDelegate:self];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"favorite.routes"])self.favoriteRoutes = [[defaults objectForKey:@"favorite.routes"]mutableCopy];
    if ([defaults objectForKey:@"favorite.stops"])self.favoriteStops = [[defaults objectForKey:@"favorite.stops"]mutableCopy];
    [self.tableView reloadData];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)return [self.favoriteRoutes count];
    else return [self.favoriteStops count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Favorites";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    if (indexPath.section == 0) {
    NSArray *favoriteRouteInfo = [self.favoriteRoutes objectAtIndex:indexPath.row];
    cell.textLabel.text = [favoriteRouteInfo objectAtIndex:0];
    cell.detailTextLabel.text = [favoriteRouteInfo objectAtIndex:1];
    [cell setAccessoryView:nil];
    }
    else {
        NSArray *favoriteStopInfo = [self.favoriteStops objectAtIndex:indexPath.row];
        cell.textLabel.text = [favoriteStopInfo objectAtIndex:1];
        cell.detailTextLabel.text = [favoriteStopInfo objectAtIndex:2];
        [cell setAccessoryView:nil];
    }
    return cell;
}

// button to clear all the favorites from table and from NSUserDefaults
- (IBAction)clearFavorites:(id)sender {
    [self.favoriteRoutes removeAllObjects];
    [self.favoriteStops removeAllObjects];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favoriteRoutes = [[defaults objectForKey:@"favorite.routes"]mutableCopy];
    NSMutableArray *favoriteStops = [[defaults objectForKey:@"favorite.stops"]mutableCopy];
    favoriteStops = nil;
    favoriteRoutes = nil;
    [defaults setObject:favoriteRoutes forKey:@"favorite.routes"];
    [defaults setObject:favoriteStops forKey:@"favorite.stops"];
    [defaults synchronize];
    [self.tableView reloadData];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) return @"Favorite Routes";
    else return @"Favorite Stops";
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *favoriteRoutes = [[defaults objectForKey:@"favorite.routes"]mutableCopy];
        NSMutableArray *favoriteStops =[[defaults objectForKey:@"favorite.stops"]mutableCopy];
        if (indexPath.section == 0){
            [self.favoriteRoutes removeObjectAtIndex:indexPath.row];
            if (favoriteRoutes){
                [favoriteRoutes removeObjectAtIndex:indexPath.row];
                [defaults setObject:favoriteRoutes forKey:@"favorite.routes"];
            }
        }
        else {
            [self.favoriteStops removeObjectAtIndex:indexPath.row];
            if (favoriteStops){
                [favoriteStops removeObjectAtIndex:indexPath.row];
                [defaults setObject:favoriteStops forKey:@"favorite.stops"];
            }
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
       
        [defaults synchronize];
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryView:spinner];
    //sending a message to the delegate - UTAViewController asking it to showFavorite:favorite on the map
    if (indexPath.section==0){
        NSString *favoriteRoute = [[self.favoriteRoutes objectAtIndex:indexPath.row] objectAtIndex:1];
        [self.routeDelegate showFavoriteRoute:favoriteRoute :self];
    }
    if (indexPath.section == 1){
        NSString *favoriteStop = [[self.favoriteStops objectAtIndex:indexPath.row] objectAtIndex:0];
        self.stopInfo = [self.favoriteStops objectAtIndex:indexPath.row];
        [self showBuses:favoriteStop];
    }
}
-(void) checkNetworkStatus:(NSNotification *)notice
{
    self.internetActive = YES;
    NetworkStatus internetStatus = [self.internetReachable currentReachabilityStatus];
    if (internetStatus == NotReachable){
        //NSLog(@"The internet is down.");
        self.internetActive = NO;
    }
    
}
- (void) showBuses:(NSString *)atStop
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    NSString *url = [NSString stringWithFormat:@"http://api.rideuta.com/SIRI/SIRI.svc/StopMonitor?stopid=%@&minutesout=30&onwardcalls=true&filterroute=&usertoken=%@",atStop,UtaAPIKey];
    //NSLog(@"url is %@",url);
    dispatch_queue_t xmlGetter = dispatch_queue_create("UTA xml getter", NULL);
    dispatch_async(xmlGetter, ^{
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus internetStatus = [reachability currentReachabilityStatus];
        if (internetStatus != NotReachable) {
            int retryNumber = 0;
            self.stopInfoArray = nil;
            while (retryNumber<=2 && [self.stopInfoArray count]==0){
            NSArray *stopInfoArray =  [NSArray arrayWithArray:[self.utaFetcher executeStopFetcher:url]];
            self.stopInfoArray = stopInfoArray;
                retryNumber++;
            }
            [spinner stopAnimating];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please Check Your Internet Connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            [spinner stopAnimating];
            self.stopInfoArray = nil;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger numberofcontrollers = [self.navigationController.viewControllers count];
            if (numberofcontrollers <2 && self.stopInfoArray)
            [self performSegueWithIdentifier:@"show favorite stop info" sender:self];
        });
    });
    dispatch_release(xmlGetter);
    
}

- (NSArray *) refreshedStopInfo:(NSString *)forStop :(StopInfoTableViewController *)sender
{
    [self showBuses:forStop];
    return self.stopInfoArray;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show favorite stop info"]){
        [segue.destinationViewController setStopDescriptionForTable:self.stopInfoArray];
        [segue.destinationViewController setRefreshStopDelegate:self];
        [segue.destinationViewController setStopID:[self.stopInfo objectAtIndex:0]];
        [segue.destinationViewController setStopName:[self.stopInfo objectAtIndex:1]];
    }
}
@end
