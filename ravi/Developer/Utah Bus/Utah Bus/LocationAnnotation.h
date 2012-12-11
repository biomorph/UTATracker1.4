//
//  LocationAnnotation.h
//  Utah Bus
//
//  Created by Ravi Alla on 8/6/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LocationAnnotation : NSObject <MKAnnotation>

+ (LocationAnnotation *) annotationForVehicleOrStop: (NSDictionary *) vehicleInfo;
@property (nonatomic, strong) NSDictionary *vehicleInfo;

@end
