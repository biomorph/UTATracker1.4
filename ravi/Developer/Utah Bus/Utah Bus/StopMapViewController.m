//
//  StopMapViewController.m
//  Utah Bus
//
//  Created by Ravi Alla on 8/13/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import "StopMapViewController.h"
#import "LocationAnnotation.h"
#import "UtaFetcher.h"
#import "StopInfoTableViewController.h"
#import "UTAStopMonitoringViewController.h"

@interface StopMapViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) UIButton *typeDetailDisclosure;
@property (nonatomic, strong) NSArray *stopDescription;
@property (nonatomic, strong) NSArray *vehicleInfoArray;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) UtaFetcher *utaFetcher;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property BOOL internetActive;
@property (strong, nonatomic) NSArray *annotations;


@end

@implementation StopMapViewController

@synthesize typeDetailDisclosure = _typeDetailDisclosure;
@synthesize stopInfo = _stopInfo;
@synthesize mapView = _mapView;
@synthesize utaFetcher = _utaFetcher;
@synthesize vehicleInfoArray = _vehicleInfoArray;
@synthesize stopMapDelegate = _stopMapDelegate;
@synthesize annotations = _annotations;

- (NSArray *) vehicleInfoArray
{
    if (!_vehicleInfoArray)_vehicleInfoArray = [[NSArray alloc]init];
    return _vehicleInfoArray;
}
- (UtaFetcher *) utaFetcher
{
    if (!_utaFetcher) _utaFetcher = [[UtaFetcher alloc] init];
    return _utaFetcher;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) updateMapView
{
    if ([self.mapView.annotations count]>0){
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
    if (self.annotations)[self.mapView addAnnotations:self.annotations];
    
    // Setting the initial zoom based on the highest and lowest values of the latitudes and longitudes of the buses' locations
    if ([self.annotations count]!= 0){
        NSMutableArray *latitude = [NSMutableArray arrayWithCapacity:[self.annotations count]];
        NSMutableArray *longitude = [NSMutableArray arrayWithCapacity:[self.annotations count]];
        for (LocationAnnotation *annotation in self.annotations){
            [latitude addObject:[[annotation vehicleInfo] objectForKey:LATITUDE]];
            [longitude addObject:[[annotation vehicleInfo]objectForKey:LONGITUDE]];
        }

        for (LocationAnnotation *annotation in self.annotations){
            self.vehicleInfo = [annotation vehicleInfo];
        }
        NSArray* sortedlatitude = [latitude sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            return ([obj1 doubleValue] < [obj2 doubleValue]);
        }];
        
        NSArray* sortedlongitude = [longitude sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            return ([obj1 doubleValue] < [obj2 doubleValue]);
        }];
        MKCoordinateRegion zoomRegion;
        zoomRegion.center.latitude = ([[sortedlatitude objectAtIndex:0] doubleValue]+[[sortedlatitude lastObject]doubleValue])/2;
        zoomRegion.center.longitude = ([[sortedlongitude objectAtIndex:0]doubleValue]+[[sortedlongitude lastObject]doubleValue])/2;
        double latitudeDelta = [[sortedlatitude lastObject]doubleValue]-[[sortedlatitude objectAtIndex:0]doubleValue];
        double longitudeDelta = [[sortedlongitude lastObject]doubleValue]-[[sortedlongitude objectAtIndex:0]doubleValue];
        if (latitudeDelta < 0) latitudeDelta = -1*latitudeDelta;
        if (longitudeDelta <0) longitudeDelta = -1*longitudeDelta;
        zoomRegion.span.latitudeDelta = latitudeDelta;
        zoomRegion.span.longitudeDelta = longitudeDelta;
        if (zoomRegion.span.latitudeDelta==0) zoomRegion.span.latitudeDelta = 0.2;
        if (zoomRegion.span.longitudeDelta == 0) zoomRegion.span.longitudeDelta = 0.2;
        [self.mapView setRegion:zoomRegion animated:YES];
    }
    else {
        MKCoordinateRegion zoomRegion;
        zoomRegion.center.latitude = 40.760779;
        zoomRegion.center.longitude = -111.891047;
        zoomRegion.span.latitudeDelta = 0.8;
        zoomRegion.span.longitudeDelta = 0.8;
        [self.mapView setRegion:zoomRegion animated:YES];
    }
   
}
- (void) setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void) setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = @"Closest Stops";
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 150, 40)];
    tlabel.text=self.navigationItem.title;
    tlabel.textColor=[UIColor whiteColor];
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    [tlabel setTextAlignment:NSTextAlignmentCenter];
    self.navigationItem.titleView=tlabel;
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:3];
    
    // Create a standard refresh button.
   
    UIBarButtonItem *bi = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshStopMap:)];
    [buttons addObject:bi];
       // Add profile button.
    bi = [[UIBarButtonItem alloc] initWithTitle:@"GPS" style:UIBarButtonItemStylePlain target:self action:@selector(refreshStopMap:)];
    bi.style = UIBarButtonItemStyleBordered;
    [buttons addObject:bi];
        // Add buttons to toolbar and toolbar to nav bar.
    self.navigationItem.rightBarButtonItems=buttons;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = nil;
    self.mapView.delegate = self;
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 10 m
    [self.locationManager startUpdatingLocation];
    [self.mapView setShowsUserLocation:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    self.internetReachable = [Reachability reachabilityForInternetConnection];
    [self.internetReachable startNotifier];
	// Do any additional setup after loading the view.
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (![annotation isKindOfClass:[MKUserLocation class]]){
    MKAnnotationView *aView =[mapView dequeueReusableAnnotationViewWithIdentifier:@"Stop Coordinates"];
    if (!aView){
        aView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"Stop Coordinates"];
        aView.canShowCallout = YES;
    }
    aView.annotation = annotation;
        aView.canShowCallout = YES;
        aView.leftCalloutAccessoryView = nil;
        self.typeDetailDisclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        aView.rightCalloutAccessoryView = self.typeDetailDisclosure;
    return aView;
}
else return  nil;
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
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    self.typeDetailDisclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    view.rightCalloutAccessoryView = self.typeDetailDisclosure;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    self.stopInfo = [(LocationAnnotation *)view.annotation vehicleInfo];
    if (self.stopInfo){
      NSString *stopID = [self.stopInfo objectForKey:STOP_ID];
        [self showBuses:stopID];
    }
}
- (void) showBuses:(NSString *)atStop
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    UIBarButtonItem *bi = [[UIBarButtonItem alloc]initWithCustomView:spinner];
    [spinner hidesWhenStopped];
    NSMutableArray *navigationItems = [self.navigationItem.rightBarButtonItems mutableCopy];
    [navigationItems addObject:bi];
    self.navigationItem.rightBarButtonItems = navigationItems;
    self.navigationItem.titleView = spinner;
    NSString *url = [NSString stringWithFormat:@"http://api.rideuta.com/SIRI/SIRI.svc/StopMonitor?stopid=%@&minutesout=60&onwardcalls=true&filterroute=&usertoken=%@",atStop,UtaAPIKey];
    NSLog(@"url is %@",url);
    dispatch_queue_t xmlGetter = dispatch_queue_create("UTA xml getter", NULL);
    dispatch_async(xmlGetter, ^{
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus internetStatus = [reachability currentReachabilityStatus];
        if (internetStatus != NotReachable) {
            int retryNumber = 0;
            self.vehicleInfoArray = nil;
            while (retryNumber<=2 && [self.vehicleInfoArray count]==0){
            NSArray *vehicleInfoArray =  [NSArray arrayWithArray:[self.utaFetcher executeStopFetcher:url]];
            self.vehicleInfoArray = vehicleInfoArray;
                retryNumber++;
            }
            [spinner stopAnimating];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Please Check Your Internet Connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            [spinner stopAnimating];
            self.vehicleInfoArray = nil;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger numberofcontrollers = [self.navigationController.viewControllers count];
            if (numberofcontrollers <3)[self performSegueWithIdentifier:@"show stop info" sender:self];
            [spinner hidesWhenStopped];
        });
    });
    dispatch_release(xmlGetter);
    
}

- (void) refreshStopMap:(UIBarButtonItem*)sender
{
    CLLocation *currentLocation = [[CLLocation alloc]initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    if (![sender.title isEqualToString:@"GPS"]){
        //dispatch_queue_t xmlGetter = dispatch_queue_create("UTA xml getter", NULL);
        //dispatch_async(xmlGetter, ^{
            [self.stopMapDelegate refreshStopMap:YES];
            self.annotations = [self.stopMapDelegate refreshedStopAnnotations:currentLocation :self];
            CLLocationCoordinate2D center = [self.mapView centerCoordinate];
            [self.mapView setCenterCoordinate:center];
            //NSLog(@"I'm in refresh");
            [self updateMapView];
            //dispatch_async(dispatch_get_main_queue(), ^{
                 //self.typeDetailDisclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
           // });
        //});
        //dispatch_release(xmlGetter);
        
    }
    else {
        //dispatch_queue_t xmlGetter = dispatch_queue_create("UTA xml getter", NULL);
        //dispatch_async(xmlGetter, ^{
            [self.stopMapDelegate refreshStopMap:NO];
            self.annotations = [self.stopMapDelegate refreshedStopAnnotations:currentLocation :self];
            //dispatch_async(dispatch_get_main_queue(), ^{
            //});
        //});
        //dispatch_release(xmlGetter);
    }
    //self.typeDetailDisclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show stop info"]){
        [segue.destinationViewController setStopDescriptionForTable:self.vehicleInfoArray];
        [segue.destinationViewController setStopInfo:self.stopInfo];

    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
