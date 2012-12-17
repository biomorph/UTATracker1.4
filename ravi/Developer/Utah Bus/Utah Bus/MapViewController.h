//
//  MapViewController.h
//  Utah Bus
//
//  Created by Ravi Alla on 8/6/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
@class MapViewController;
@protocol RefreshDelegate

- (NSArray *) refreshedAnnotations :(NSString*) withRoute : (MapViewController *) sender;
@end
@interface MapViewController : UIViewController
@property (nonatomic, strong) NSArray *annotations;
@property (nonatomic, strong) NSDictionary *vehicleInfo;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (strong, nonatomic) NSMutableArray *shape_lt;
@property (strong, nonatomic) NSMutableArray *shape_lon;
@property (strong, nonatomic) id <RefreshDelegate> refreshDelegate;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSDictionary *dictOfShapeArrays;

@end
