//
//  StopListTableViewController.h
//  Utah Bus
//
//  Created by Ravi Alla on 4/19/13.
//  Copyright (c) 2013 Ravi Alla. All rights reserved.
//

#import <UIKit/UIKit.h>
@class StopListTableViewController;
@protocol stopInfoDelegate
- (NSArray *) showstopInfo : (NSString *)forStopID;
@end
@interface StopListTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *stopInfoDictArray;
@property (nonatomic, weak) id <stopInfoDelegate> stopInfoDelegate;
@end
