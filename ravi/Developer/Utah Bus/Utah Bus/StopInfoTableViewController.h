//
//  StopInfoTableViewController.h
//  Utah Bus
//
//  Created by Ravi Alla on 8/14/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

@class StopInfoTableViewController;
@protocol RefreshStopDelegate
- (NSArray *) refreshedStopInfo : (NSString *)forStop : (StopInfoTableViewController *) sender;
@end
@interface StopInfoTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *stopDescriptionForTable;
@property (nonatomic, strong) NSDictionary *stopInfo;
@property (nonatomic, weak) id<RefreshStopDelegate> refreshStopDelegate;
@property (nonatomic, strong) NSString *stopName;
@property (nonatomic, strong) NSString *stopID;
@end
