//
//  ViewController.m
//  Utah Bus
//
//  Created by Ravi Alla on 8/3/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import "UTAViewController.h"
#import "UtaFetcher.h"
#import "MapViewController.h"
#import "LocationAnnotation.h"
#import "FavoritesTableViewController.h"
#import "StopInfoTableViewController.h"

@interface UTAViewController ()<FavoritesTableViewControllerDelegate>

@property (nonatomic, strong) NSString *onwardCalls;
@property (nonatomic, strong) NSArray *vehicleInfoArray;
@property (nonatomic, strong) UtaFetcher *utaFetcher;
@property (nonatomic, strong) LocationAnnotation *annotation;
@property (nonatomic, strong) NSMutableArray *shape_lt; //holds the shape_pt_lat for passing to mapview overlays
@property (nonatomic, strong) NSMutableArray *shape_lon; //holds the shape_pt_lon for passing to mapview overlays
@property (nonatomic, strong) UITableView *autocompleteTableView;
@property (nonatomic, strong) NSMutableArray *routeNames;
@property (nonatomic, strong) NSMutableArray *autoCompleteRouteNames;
@property BOOL internetActive;
@property (nonatomic) BOOL refreshPressed;
@property (nonatomic) BOOL finishedGetting;
@property (nonatomic,strong) NSArray *refreshedAnnotations;
@property (nonatomic, strong) MapViewController *mapvc;
@end

@implementation UTAViewController
@synthesize routeName = _routeName;
@synthesize onwardCalls = _onwardCalls;
@synthesize utaFetcher = _utaFetcher;
@synthesize vehicleInfoArray = _vehicleInfoArray;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize shape_lon = _shape_lon;
@synthesize shape_lt = _shape_lt;
@synthesize routeNames = _routeNames;
@synthesize autoCompleteRouteNames = _autoCompleteRouteNames;


// getting the managedobjectcontext and lazily instantiating
- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext)_managedObjectContext = [[NSManagedObjectContext alloc]init];
    return _managedObjectContext;
}

- (NSMutableArray *) autoCompleteRouteNames
{
    if (!_autoCompleteRouteNames) _autoCompleteRouteNames = [[NSMutableArray alloc]init];
    return _autoCompleteRouteNames;
}

- (NSMutableArray *) routeNames
{
    if (!_routeNames)_routeNames = [[NSMutableArray alloc]init];
    return _routeNames;
}

//lazy instantiation of shape_lon
- (NSMutableArray *) shape_lon
{
    if (!_shape_lon)_shape_lon = [[NSMutableArray alloc]init];
    return _shape_lon;
}
//lazy instantiation of shape_lt
- (NSMutableArray *) shape_lt
{
    if (!_shape_lt)_shape_lt = [[NSMutableArray alloc]init];
    return _shape_lt;
}
//lazy instantiation of the utaFetcher instance
- (UtaFetcher *) utaFetcher
{
    if (!_utaFetcher) _utaFetcher = [[UtaFetcher alloc] init];
    return _utaFetcher;
}

- (MapViewController *)mapvc
{
    if (!_mapvc) _mapvc = [[MapViewController alloc]init];
    return _mapvc;
}
- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    self.internetReachable = [Reachability reachabilityForInternetConnection];
    [self.internetReachable startNotifier];

}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // check for internet connection
    /*NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"utabus.availableroutes"]){
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Routes"
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        for (NSManagedObject *route in fetchedObjects){
            [self.routeNames addObject:[route valueForKey:@"route_short_name"]];
        }

        [defaults setObject:self.routeNames forKey:@"utabus.availableroutes"];
        [defaults synchronize];
    }
    else {
        self.routeNames = [defaults objectForKey:@"utabus.availableroutes"];
    }
    self.autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 160, 640, 105) style:UITableViewStylePlain];
    self.autocompleteTableView.delegate = self;
    self.autocompleteTableView.dataSource = self;
    self.autocompleteTableView.scrollEnabled = YES;
    self.autocompleteTableView.hidden = YES;
    [self.view addSubview:self.autocompleteTableView];
    self.routeName.delegate = self;
    self.infoView.hidden = YES;*/
    UINavigationController *fnvc = [self.tabBarController.viewControllers objectAtIndex:3];
    FavoritesTableViewController *fvc = (FavoritesTableViewController *)[fnvc topViewController];
    [fvc setRouteDelegate:self];
    
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


// shows an autofil by substringing the typed characters
/*- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.autocompleteTableView.hidden = NO;
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteEntriesWithSubstring:substring];
    return YES;
}

// presents autofil options in a tableview based on the typed string
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    // Put anything that starts with this substring into the autocompleteUrls array
    // The items in this array is what will show up in the table view
    for(NSString *curString in self.routeNames) {
        NSRange substringRange = [curString rangeOfString:substring];
        if (substringRange.location == 0) {
            [self.autoCompleteRouteNames addObject:curString];
        }
        [self.autocompleteTableView reloadData];
    }
}

//tableview methods for autofil tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    //if ([self.autoCompleteRouteNames count]==1)self.autocompleteTableView.hidden = YES;
    
    return [self.autoCompleteRouteNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.routeName.text.length == 0) {
        self.autoCompleteRouteNames = nil;
        self.autocompleteTableView.hidden = YES;
    }
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    
    if ([self.autoCompleteRouteNames count] >0)cell.textLabel.text = [self.autoCompleteRouteNames objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    self.routeName.text = selectedCell.textLabel.text;
    self.autocompleteTableView.hidden = YES;
    
}*/

//This method dismisses the onscreen keyboard when touched away from text field
- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.routeName isFirstResponder] && [touch view] != self.routeName) {
        [self.routeName resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

//fetches the xml from UTA API website when show vehicles button is pressed
- (IBAction)showVehicles:(id)sender {

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    NSString *urlString = [NSString stringWithFormat:@"http://api.rideuta.com/SIRI/SIRI.svc/VehicleMonitor/ByRoute?route=%@&onwardcalls=true&usertoken=%@",self.routeName.text,UtaAPIKey];
    
    // Here I am fetching routeID from core data entity route, based on the bus typed into the text field
    //NSLog(@"routename is %@",self.routeName.text);
if (!self.refreshPressed){
    NSString *routeID = [NSString string];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Routes"
                                              inManagedObjectContext:self.managedObjectContext];
    NSPredicate *routePredicate = [NSPredicate predicateWithFormat:@"route_short_name=%@",self.routeName.text];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:routePredicate];
    NSArray *fetchedRoutes = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    NSLog(@"fetchedRoutes number %@",fetchedRoutes);

    routeID = [[fetchedRoutes lastObject] valueForKey:@"route_id"];
    NSLog(@"RouteID %@",routeID);
    // Here I am fetching the shapeID from core data entity trips, based on the routeID I got from above
    NSEntityDescription *tripsEntity = [NSEntityDescription entityForName:@"Trips"
                                                   inManagedObjectContext:self.managedObjectContext];
    NSPredicate *tripPredicate = [NSPredicate predicateWithFormat:@"route_id=%@",routeID];
    [fetchRequest setEntity:tripsEntity];
    [fetchRequest setPredicate:tripPredicate];
    NSArray *fetchedTrips = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    //NSLog(@"fetchedTrip number %d",[fetchedTrips count]);
    NSCountedSet *shape_ids = [NSCountedSet set];

    NSMutableArray *unique_shape_ids = [NSMutableArray array];
    for (NSManagedObject *trip in fetchedTrips){
        if ([[trip valueForKey:@"route_id"]isEqualToString:routeID]){
            [shape_ids addObject:[trip valueForKey:@"shape_id"]];
            if (![unique_shape_ids containsObject:[trip valueForKey:@"shape_id"]])[unique_shape_ids addObject:[trip valueForKey:@"shape_id"]];
        }
    }
    //NSLog(@"Shape_ids are %@",unique_shape_ids);
    if ([unique_shape_ids count]>0){
    NSString *highest_count_shape_id = [NSString string];
    NSUInteger maxcount=0;
    for (NSString *shape_id in unique_shape_ids){
        if (maxcount<[shape_ids countForObject:shape_id]) {
            maxcount = [shape_ids countForObject:shape_id];
            highest_count_shape_id = shape_id;
        }
    }
    [unique_shape_ids removeObject:highest_count_shape_id];
    maxcount = 0;
    NSString *second_highest_count_shape_id;
    for (NSString *shape_id in unique_shape_ids){
        if (maxcount<[shape_ids countForObject:shape_id]) {
            maxcount = [shape_ids countForObject:shape_id];
            second_highest_count_shape_id = shape_id;
        }
    }
    [unique_shape_ids removeAllObjects];
    [unique_shape_ids addObject:highest_count_shape_id];
    if (second_highest_count_shape_id)[unique_shape_ids addObject:second_highest_count_shape_id];
    }
    self.shape_lt = nil;
    self.shape_lon = nil;
    for (NSString *shapeID in unique_shape_ids){
    //NSString *shapeID = [unique_shape_ids objectAtIndex:0];
    // Here I am fetching the shape_pt_lat and shape_pt_long from core data entity shapes, based on the shapeID I got above
    //NSLog(@"Shape_ids are %@",shapeID);
    NSEntityDescription *shapesEntity = [NSEntityDescription entityForName:@"Shapes"
                                                    inManagedObjectContext:self.managedObjectContext];
    NSPredicate *shapePredicate = [NSPredicate predicateWithFormat:@"shape_id=%@",shapeID];
    [fetchRequest setEntity:shapesEntity];
    [fetchRequest setPredicate:shapePredicate];
    NSArray *fetchedShapes = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    NSLog(@"number of shape points is %d",[fetchedShapes count]);
        for (NSManagedObject *shape in fetchedShapes){
            if([[shape valueForKey:@"shape_id"] isEqualToString:shapeID]){
            [self.shape_lt addObject:[shape valueForKey:@"shape_pt_lat"]];
            [self.shape_lon addObject:[shape valueForKey:@"shape_pt_lon"]];
            }
        }
    }
}
    dispatch_queue_t xmlGetter = dispatch_queue_create("UTA xml getter", NULL);
    dispatch_async(xmlGetter, ^{
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus internetStatus = [reachability currentReachabilityStatus];
        if (internetStatus != NotReachable) {
            int retryNumber = 0;
            self.vehicleInfoArray = nil;
            while (retryNumber <=2 && [self.vehicleInfoArray count]==0){
            self.vehicleInfoArray = [self.utaFetcher executeUtaFetcher:urlString];
                retryNumber++;
            }
            self.finishedGetting = YES;
        [spinner stopAnimating];
        }
        else {
           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please Check Your Internet Connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            [spinner stopAnimating];
            self.shape_lon = nil;
            self.shape_lt = nil;
            self.vehicleInfoArray = nil;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger numberofcontrollers = [self.navigationController.viewControllers count];
            if (numberofcontrollers <2 && self.vehicleInfoArray)[self performSegueWithIdentifier:@"show on map" sender:self];
        });
    });
    dispatch_release(xmlGetter);
    
}

// this is the protocol method for FavoriteTableViewControllerDelegate that takes the favorite string and runs the showVehicles method and also switches the tab to the route tab and pops any other viewcontrollers in the stack, so there are no nesting mapviews.
- (void) showFavoriteRoute:(NSString *)favoriteRoute :(FavoritesTableViewController *)sender
{
    self.routeName.text = favoriteRoute;
    [self showVehicles:sender];    
    [self.navigationController popToViewController:self animated:YES];
    //[self.tabBarController setSelectedIndex:0];
        

}


// helper method to return an array of annotations to pass to mapview during segue
- (NSArray *) mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.vehicleInfoArray count]];
    for(NSDictionary *vehicle in self.vehicleInfoArray){
        [annotations addObject:[LocationAnnotation annotationForVehicleOrStop:vehicle]];
        
    }
    
    return annotations;
}

- (NSArray *)refreshedAnnotations:(NSString *)withRoute :(MapViewController *)sender
{
    self.refreshPressed = YES;
    self.vehicleInfoArray = nil;
    int retryNumber=0;
    NSString *urlString = [NSString stringWithFormat:@"http://api.rideuta.com/SIRI/SIRI.svc/VehicleMonitor/ByRoute?route=%@&onwardcalls=true&usertoken=%@",withRoute,UtaAPIKey];
    while (retryNumber <=2 && [self.vehicleInfoArray count]==0) {
         self.vehicleInfoArray = [self.utaFetcher executeUtaFetcher:urlString];
       retryNumber++;
    }
    self.refreshPressed = NO;
    return [self mapAnnotations];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show on map"]){
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
        [segue.destinationViewController setShape_lon:self.shape_lon];
        [segue.destinationViewController setShape_lt:self.shape_lt];
        [self.tabBarController setSelectedIndex:0];
        [segue.destinationViewController setRefreshDelegate:self];
        self.shape_lon = nil;
        self.shape_lt = nil;
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidUnload
{
    [self setRouteName:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self.autocompleteTableView reloadInputViews];
    return YES;
}


@end
