//
//  RoutePlannerViewController.h
//  Utah Bus
//
//  Created by Ravi Alla on 10/8/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//  This displays either UTA's route planning website or googles transit mobile website, in case you want to plan your trip.

#import <UIKit/UIKit.h>

@interface RoutePlannerViewController : UIViewController
@property (nonatomic, strong) IBOutlet UIWebView *routePlannerWebView;

@end
