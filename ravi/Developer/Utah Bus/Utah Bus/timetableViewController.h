//
//  timetableViewController.h
//  Utah Bus
//
//  Created by Ravi Alla on 8/24/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
// To display a UIWebview with the timetable of a selected bus, queries UTA's website

#import <UIKit/UIKit.h>

@interface timetableViewController : UIViewController
@property (nonatomic, strong) IBOutlet UIWebView *timetableView;
@property (nonatomic, strong) NSString *route;
@property (nonatomic, strong) NSString *day;
@property (nonatomic, strong) NSString *vehicleDirection;
@end
