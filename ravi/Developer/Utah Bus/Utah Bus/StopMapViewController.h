//
//  StopMapViewController.h
//  Utah Bus
//
//  Created by Ravi Alla on 8/13/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//  This is for view which displays bus stops at current location

#import "MapViewController.h"
#import "Reachability.h"
@class StopMapViewController;
@protocol RefreshStopMapDelegate <NSObject>


- (NSArray *) refreshedStopAnnotations : (CLLocation*) forLocation : (StopMapViewController*) sender;
- (void) refreshStopMap:(BOOL)pressed;

@end
@interface StopMapViewController : MapViewController
@property (nonatomic, strong) NSDictionary *stopInfo;
@property (strong, nonatomic) Reachability *internetReachable;
-(void) checkNetworkStatus:(NSNotification *)notice;
@property (nonatomic, weak) id <RefreshStopMapDelegate> stopMapDelegate;
@end
