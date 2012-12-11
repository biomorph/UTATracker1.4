//
//  UTAStopMonitoringViewController.h
//  Utah Bus
//
//  Created by Ravi Alla on 8/13/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Reachability.h"

@interface UTAStopMonitoringViewController : UIViewController
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController; //for fetching results from coredata
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;//managed object context to access coredata
@property (strong, nonatomic) Reachability *internetReachable;
@end
