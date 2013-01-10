//
//  LocationAnnotation.m
//  Utah Bus
//
//  Created by Ravi Alla on 8/6/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
// custom annotations

#import "LocationAnnotation.h"
#import "UtaFetcher.h"

@implementation LocationAnnotation
+ (LocationAnnotation *) annotationForVehicleOrStop: (NSDictionary *) vehicleInfo
{
    LocationAnnotation *annotation = [[LocationAnnotation alloc]init];
    annotation.vehicleInfo = vehicleInfo;
    return annotation;
}

- (NSString *) title
{
    if ([self.vehicleInfo objectForKey:PUBLISHED_LINE_NAME]){
        return [self.vehicleInfo objectForKey:PUBLISHED_LINE_NAME];
    }
    else if ([self.vehicleInfo objectForKey:STOP_NAME]){
        return [self.vehicleInfo objectForKey:STOP_NAME];
    }
    else return nil;
}

- (NSString *) subtitle
{
    if ([self.vehicleInfo objectForKey:DIRECTION_OF_VEHICLE]){
        return [self.vehicleInfo objectForKey:DIRECTION_OF_VEHICLE];
    }
    else if ([self.vehicleInfo objectForKey:STOP_DIRECTION]){
        //NSString * distance = [self.vehicleInfo objectForKey:DISTANCE_TO_STOP];
        //double distanceInMiles = [distance doubleValue]/5280.0;
        NSString *subtitle = [NSString stringWithFormat:@"%@",/*distanceInMiles,*/[self.vehicleInfo objectForKey:STOP_DIRECTION]];
        return subtitle;
    }
    else return nil;
}

- (NSString *) direction
{
    return nil;
}
- (CLLocationCoordinate2D) coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.vehicleInfo objectForKey:LATITUDE] floatValue];
    coordinate.longitude = [[self.vehicleInfo objectForKey:LONGITUDE] floatValue];
    return  coordinate;
}

- (NSString *) progress
{
    if ([self.vehicleInfo objectForKey:PROGRESS_RATE]){
        return [self.vehicleInfo objectForKey:PROGRESS_RATE];
    }
    else return nil;
}
@end
