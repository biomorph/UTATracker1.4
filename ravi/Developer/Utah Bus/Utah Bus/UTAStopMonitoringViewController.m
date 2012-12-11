//
//  UTAStopMonitoringViewController.m
//  Utah Bus
//
//  Created by Ravi Alla on 8/13/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import "UTAStopMonitoringViewController.h"
#import "UtaFetcher.h"
#import "MapViewController.h"
#import "LocationAnnotation.h"
#import "FavoritesTableViewController.h"
#import "StopMapViewController.h"

@interface UTAStopMonitoringViewController ()<CLLocationManagerDelegate,NSFetchedResultsControllerDelegate,RefreshStopMapDelegate>//UITableViewDelegate,UITextFieldDelegate,UITableViewDataSource
@property (strong, nonatomic) IBOutlet UITextField *routeFilter;
@property (nonatomic, strong)  CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *stopInfoArray;
@property (nonatomic, strong) UtaFetcher *utaFetcher;
@property (nonatomic, strong) UITableView *autocompleteTableView;
@property (nonatomic, strong) NSMutableArray *autoCompleteRouteNames;
@property (nonatomic, strong) NSMutableArray *routeNames;
@property (nonatomic, strong) NSMutableArray *shape_lt;
@property (nonatomic, strong) NSMutableArray *shape_lon;
@property BOOL internetActive;
@property (nonatomic) BOOL refreshStopMapPressed;
@property (nonatomic, strong) CLLocation *mapLocation;




@end

@implementation UTAStopMonitoringViewController
@synthesize routeFilter = _routeFilter;
@synthesize locationManager = _locationManager;
@synthesize stopInfoArray = _stopInfoArray;
@synthesize utaFetcher = _utaFetcher;
@synthesize autoCompleteRouteNames = _autoCompleteRouteNames;
@synthesize autocompleteTableView = _autocompleteTableView;
@synthesize routeNames = _routeNames;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize refreshStopMapPressed = _refreshStopMapPressed;
@synthesize mapLocation = _mapLocation;

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
- (UtaFetcher *) utaFetcher
{
    if (!_utaFetcher)_utaFetcher = [[UtaFetcher alloc]init];
    return _utaFetcher;
}

- (NSArray *) stopInfoArray
{
    if (!_stopInfoArray)_stopInfoArray = [[NSArray alloc]init];
    return _stopInfoArray;
}

- (CLLocationManager *) locationManager
{
    if (!_locationManager){
        _locationManager = [[CLLocationManager alloc]init];
    }
    return _locationManager;
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
- (IBAction)findStops:(id)sender {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    double latitude;
    double longitude;
    if (!self.refreshStopMapPressed){
        latitude = self.locationManager.location.coordinate.latitude;
        longitude = self.locationManager.location.coordinate.longitude;
    }
    else {
        self.stopInfoArray = nil;
        latitude = self.mapLocation.coordinate.latitude;
        longitude = self.mapLocation.coordinate.longitude;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Routes"
                                              inManagedObjectContext:self.managedObjectContext];
    NSPredicate *routePredicate = [NSPredicate predicateWithFormat:@"route_short_name=%@",self.routeFilter.text];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:routePredicate];
    NSArray *fetchedRoutes = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    NSString *urlString = [NSString string];
    if ([fetchedRoutes count] >0) {
         urlString = [NSString stringWithFormat:@"http://api.rideuta.com/SIRI/SIRI.svc/CloseStopmonitor?latitude=%f&longitude=%f&route=%@&numberToReturn=25&usertoken=%@",latitude,longitude, self.routeFilter.text,UtaAPIKey];
    }
    else {
        urlString = [NSString stringWithFormat:@"http://api.rideuta.com/SIRI/SIRI.svc/CloseStopmonitor?latitude=%f&longitude=%f&route=&numberToReturn=25&usertoken=%@",latitude,longitude,UtaAPIKey];
    }
    dispatch_queue_t xmlGetter = dispatch_queue_create("UTA xml getter", NULL);
    dispatch_async(xmlGetter, ^{
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus internetStatus = [reachability currentReachabilityStatus];
        if (internetStatus != NotReachable) {
            int retryNumber = 0;
            self.stopInfoArray = nil;
            while (retryNumber<=2 && [self.stopInfoArray count]==0){
        self.stopInfoArray = [self.utaFetcher executeFetcher:urlString];
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
            if (numberofcontrollers <2 && self.stopInfoArray)[self performSegueWithIdentifier:@"show stops on map" sender:self];
        });
    });
    dispatch_release(xmlGetter);
    
}
/*- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.autocompleteTableView.hidden = NO;
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteEntriesWithSubstring:substring];
    return YES;
}*/

// presents autofil options in a tableview based on the typed string
/*- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
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
    if (self.routeFilter.text.length == 0) {
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
    self.routeFilter.text = selectedCell.textLabel.text;
    self.autocompleteTableView.hidden = YES;
    
}*/



/*- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
    for (UIView* view in self.view.subviews) {
        if ([view isKindOfClass:[UITextField class]])
            [view resignFirstResponder];
        }
}*/

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
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 10 m
    [self.locationManager startUpdatingLocation];
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
    self.autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 180, 640, 105) style:UITableViewStylePlain];
    self.autocompleteTableView.delegate = self;
    self.autocompleteTableView.dataSource =self;
    self.autocompleteTableView.scrollEnabled = YES;
    self.autocompleteTableView.hidden = YES;
    [self.view addSubview:self.autocompleteTableView];
    self.routeFilter.delegate = self;*/
	// Do any additional setup after loading the view.
}
- (NSArray *) mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.stopInfoArray count]];
    for(NSDictionary *stop in self.stopInfoArray){
        [annotations addObject:[LocationAnnotation annotationForVehicleOrStop:stop]];
        
    }
    return annotations;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show stops on map"]){
        [segue.destinationViewController setAnnotations:nil];
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
        [segue.destinationViewController setShape_lon:self.shape_lon];
        [segue.destinationViewController setShape_lt:self.shape_lt];
        [segue.destinationViewController setStopMapDelegate:self];
        self.shape_lon = nil;
        self.shape_lt = nil;
    }
}

- (NSArray *) refreshedStopAnnotations:(CLLocation *)forLocation :(StopMapViewController *)sender
{
    self.mapLocation = forLocation;
    double latitude;
    double longitude;
    if (!self.refreshStopMapPressed){
        latitude = self.locationManager.location.coordinate.latitude;
        longitude = self.locationManager.location.coordinate.longitude;
    }
    else {
        self.stopInfoArray = nil;
        latitude = self.mapLocation.coordinate.latitude;
        longitude = self.mapLocation.coordinate.longitude;
    }
  NSString *urlString = [NSString stringWithFormat:@"http://api.rideuta.com/SIRI/SIRI.svc/CloseStopmonitor?latitude=%f&longitude=%f&route=&numberToReturn=25&usertoken=%@",latitude,longitude,UtaAPIKey];
    int retryNumber = 0;
    self.stopInfoArray = nil;
    while (retryNumber<=2 && [self.stopInfoArray count]==0){
    self.stopInfoArray = [self.utaFetcher executeFetcher:urlString];
        retryNumber++;
    }
    self.refreshStopMapPressed = NO;
   return [self mapAnnotations];
}
- (void) refreshStopMap:(BOOL)pressed
{
    self.refreshStopMapPressed = pressed;
}
- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    self.internetReachable = [Reachability reachabilityForInternetConnection];
    [self.internetReachable startNotifier];
    
}
- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.routeFilter isFirstResponder] && [touch view] != self.routeFilter) {
        [self.routeFilter resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}
- (void)viewDidUnload
{
    [self setRouteFilter:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
