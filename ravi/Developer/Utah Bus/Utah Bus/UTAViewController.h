//
//  ViewController.h
//  Utah Bus
//
//  Created by Ravi Alla on 8/3/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
// This is for the first tab where you type in a route and track the progress of buses on that route

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UtaFetcher.h"
#import "UtaAPIKey.h"
#import <CoreData/CoreData.h>
#import "Reachability.h"
#import "MapViewController.h"



@interface UTAViewController : UIViewController <NSFetchedResultsControllerDelegate,RefreshDelegate>
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController; //for fetching results from coredata
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;//managed object context to access coredata
@property (strong, nonatomic) Reachability *internetReachable;

@property (strong, nonatomic) IBOutlet UITextField *routeName;
-(void) checkNetworkStatus:(NSNotification *)notice;

@end
