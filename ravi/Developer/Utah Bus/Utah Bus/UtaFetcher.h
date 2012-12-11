//
//  UtaFetcher.h
//  Utah Bus
//
//  Created by Ravi Alla on 8/3/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "UtaAPIKey.h"
#define PUBLISHED_LINE_NAME @"PublishedLineName"
#define VEHICLE_LOCATION @"VehicleLocation"
#define LATITUDE @"Latitude"
#define LONGITUDE @"Longitude"
#define PROGRESS_RATE @"ProgressRate"
#define DEPARTURE_TIME @"EstimatedDepartureTime"
#define DIRECTION_OF_VEHICLE @"DirectionRef"
#define STOP_DIRECTION @"StopDirection"
#define ROUTES_STOP_SERVICES @"Route"
#define STOP_ID @"StopID"
#define DISTANCE_TO_STOP @"DistanceToStop"
#define STOP_NAME @"StopName"
#define STOP_POINT_REF @"StopPointName"
#define LINE_NAME @"LineRef"
#define VEHICLE_AT_STOP @"VehicleAtStop"
#define UNIQUE_ID @"VehicleRef"

@interface UtaFetcher:NSObject <NSXMLParserDelegate>
@property (nonatomic, strong) NSMutableArray *vehicleInfoArray;
@property (nonatomic, strong) NSMutableArray *stopInfoArray;
- (NSArray *) executeUtaFetcher :(NSString *) forRouteQuery;
- (NSArray *) executeFetcher:(NSString *)forStopQuery;
- (NSArray *) executeStopFetcher : (NSString *) forStopId;

@end
