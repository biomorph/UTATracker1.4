//
//  UtaFetcher.m
//  Utah Bus
//
//  Created by Ravi Alla on 8/3/12.
//  Copyright (c) 2012 Ravi Alla. All rights reserved.
//

#import "UtaFetcher.h"
#import "UTAViewController.h"
@interface UtaFetcher()//<UTAXMLFetcherDelegate>
@property (nonatomic, strong) NSString *publishedLineName;
@property (nonatomic, strong) NSString *vehicleLatitude;
@property (nonatomic, strong) NSString *vehicleLongitude;
@property (nonatomic, strong) NSString *progressRate;
@property (nonatomic, strong) NSString *departureTime;
@property (nonatomic, strong) NSString *directionOfVehicle;
@property (nonatomic, strong) NSString *lineref;
@property (nonatomic, strong) NSMutableArray *stopIdsAlongTheWay;
@property (nonatomic, strong) NSString *stopDirection;
@property (nonatomic, strong) NSString *distanceToStop;
@property (nonatomic, strong) NSString *stopName;
@property (nonatomic, strong) NSMutableArray *routesStopServices;
@property (nonatomic, strong) NSMutableString *currentNode;
@property (nonatomic, strong) NSDictionary *vehicleInfo;
@property (nonatomic, strong) NSString *stopID;
@property (nonatomic, strong) NSDictionary *stopInfo;
@property (nonatomic, strong) NSString *stopLatitude;
@property (nonatomic, strong) NSString *stopLongitude;
@property (nonatomic, strong) NSString *atStop;
@property (nonatomic, strong) NSString *uniqueId;
@property (nonatomic ,strong) NSCountedSet *idArray;
@end


@implementation UtaFetcher

@synthesize vehicleInfoArray = _vehicleInfoArray;
@synthesize vehicleInfo = _vehicleInfo;
@synthesize publishedLineName = _publishedLineName;
@synthesize vehicleLatitude = _vehicleLatitude;
@synthesize vehicleLongitude = _vehicleLongitude;
@synthesize progressRate = _progressRate;
@synthesize departureTime = _departureTime;
@synthesize directionOfVehicle = _directionOfVehicle;
@synthesize lineref = _lineref;
@synthesize stopIdsAlongTheWay = _stopIdsAlongTheWay;
@synthesize stopInfoArray = _stopInfoArray;
@synthesize currentNode = _currentNode;
@synthesize stopDirection = _stopDirection;
@synthesize stopName = _stopName;
@synthesize distanceToStop = _distanceToStop;
@synthesize routesStopServices = _routesStopServices;
@synthesize stopID = _stopID;
@synthesize stopInfo = _stopInfo;
@synthesize stopLatitude = _stopLatitude;
@synthesize stopLongitude = _stopLongitude;
@synthesize  atStop = _atStop;
@synthesize uniqueId = _uniqueId;
@synthesize idArray = _idArray;




// Get the xml data from UTA website and send it to an NSXMLParser instance
- (NSArray *) executeUtaFetcher :(NSString *) forRouteQuery
{
    BOOL success;
    NSXMLParser *xmlParser;
    NSString *query = [forRouteQuery stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *xmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:query]];
    xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities:YES];
     success = [xmlParser parse];
    NSArray *vehicleInfoArray = [NSArray arrayWithArray:self.vehicleInfoArray];
    [self.vehicleInfoArray removeAllObjects];
    [self.idArray removeAllObjects];
    if (success)return vehicleInfoArray;
    else return nil;
    
}
- (NSArray *) executeFetcher:(NSString *)forStopQuery
{
    BOOL success;
    NSXMLParser *xmlParser;
    NSString *query = [forStopQuery stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *xmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:query]];
    xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities:YES];
    success = [xmlParser parse];
    NSArray *stopInfoArray = [NSArray arrayWithArray:self.stopInfoArray];
    [self.stopInfoArray removeAllObjects];
    if (success) return stopInfoArray;
    else return nil;
}

- (NSArray *) executeStopFetcher : (NSString *) forStopId
{
    BOOL success;
    NSXMLParser *xmlParser;
    NSString *query = [forStopId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *xmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:query]];
    xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities:YES];
    success = [xmlParser parse];
    NSArray *vehicleInfoArray = [NSArray arrayWithArray:self.vehicleInfoArray];
    [self.vehicleInfoArray removeAllObjects];
    [self.idArray removeAllObjects];
    if (success) return vehicleInfoArray;
    else return nil;
}

//Lazily instantiate the vehicle info dictionary and other mutable arrays used for holding the parsed data

- (NSMutableArray *) vehicleInfoArray {
    if (!_vehicleInfoArray) {
        _vehicleInfoArray = [[NSMutableArray alloc]init];
    }
    return _vehicleInfoArray;
}

- (NSDictionary *) vehicleInfo {
    if (!_vehicleInfo) {
        _vehicleInfo = [[NSMutableDictionary alloc] init];
    }
    return _vehicleInfo;
}

- (NSString *) publishedLineName {
    if (!_publishedLineName){
        _publishedLineName = [[NSString alloc]init];
    }
    return _publishedLineName;
}
- (NSString *) vehicleLatitude {
    if (!_vehicleLatitude){
        _vehicleLatitude = [[NSString alloc]init];
    }
    return _vehicleLatitude;
}
- (NSString *) vehicleLongitude {
    if (!_vehicleLongitude){
        _vehicleLongitude = [[NSString alloc]init];
    }
    return _vehicleLongitude;
}
- (NSString *) progressRate {
    if (!_progressRate){
        _progressRate = [[NSString alloc]init];
    }
    return _progressRate;
}
- (NSString *) departureTime {
    if (!_departureTime){
        _departureTime = [[NSString alloc]init];
    }
    return _departureTime;
}
- (NSString *) directionOfVehicle {
    if (!_directionOfVehicle){
        _directionOfVehicle = [[NSString alloc]init];
    }
    return _directionOfVehicle;
}
- (NSString *) lineref {
    if (!_lineref)_lineref =[[NSString alloc]init];
    return _lineref;
}
- (NSMutableArray *) stopIdsAlongTheWay {
    if (!_stopIdsAlongTheWay){
        _stopIdsAlongTheWay = [[NSMutableArray alloc]init];
    }
    return _stopIdsAlongTheWay;
}
- (NSMutableString *) currentNode {
    if (!_currentNode){
        _currentNode = [[NSMutableString alloc]init];
    }
    return _currentNode;
}
- (NSString *) stopDirection {
    if (!_stopDirection)_stopDirection = [[NSString alloc]init];
    return _stopDirection;
}
- (NSString *) stopID {
    if (!_stopID)_stopID = [[NSString alloc]init];
    return  _stopID;
}
- (NSString *)stopName {
    if (!_stopName)_stopName = [[NSString alloc]init];
    return _stopName;
}
- (NSMutableArray *)routesStopServices {
    if (!_routesStopServices)_routesStopServices = [[NSMutableArray alloc]init];
    return _routesStopServices;
}
- (NSString *)distanceToStop {
    if (!_distanceToStop)_distanceToStop = [[NSString alloc]init];
    return  _distanceToStop;
    
}
- (NSMutableArray *) stopInfoArray {
    if (!_stopInfoArray)_stopInfoArray = [[NSMutableArray alloc]init];
    return _stopInfoArray;
}
- (NSDictionary *) stopInfo {
    if (!_stopInfo)_stopInfo = [[NSDictionary alloc]init];
    return _stopInfo;
}
- (NSString *)stopLatitude {
    if (!_stopLatitude)_stopLatitude = [[NSString alloc]init];
    return _stopLatitude;
}
- (NSString *)stopLongitude {
    if (!_stopLongitude) _stopLongitude = [[NSString alloc]init];
    return _stopLongitude;
}
- (NSString *)atStop {
    if (!_atStop)_atStop = [[NSString alloc]init];
    return _atStop;
}
- (NSString *)uniqueId {
    if (!_uniqueId)_uniqueId = [[NSString alloc]init];
    return _uniqueId;
}
-(NSCountedSet *)idArray {
    if (!_idArray)_idArray = [[NSCountedSet alloc]init];
    return _idArray;
}
- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    
}

// NSXMLParser delegate method,that creates a string by concatenating the characters into currentNode when characters are found in elements 
- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.currentNode appendString:string];
}

// NSXMLParser delegate method, that assigns the currentNode string to different strings depending on element name, when an element ends 
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:PUBLISHED_LINE_NAME]) {
        self.publishedLineName = self.currentNode;
    }
    if ([elementName isEqualToString:LATITUDE]) {
        self.vehicleLatitude = self.currentNode;
        self.stopLatitude = self.currentNode;
    }
    if ([elementName isEqualToString:LONGITUDE]) {
        self.vehicleLongitude =self.currentNode;
        self.stopLongitude = self.currentNode;
    }
    if ([elementName isEqualToString:PROGRESS_RATE]) {
        self.progressRate=self.currentNode;
    }
    if ([elementName isEqualToString:DEPARTURE_TIME]){
        self.departureTime=self.currentNode;
    }
    if ([elementName isEqualToString:DIRECTION_OF_VEHICLE]){
        self.directionOfVehicle=self.currentNode;
    }
    if ([elementName isEqualToString:LINE_NAME]){
        self.lineref = self.currentNode;
    }
    if ([elementName isEqualToString:STOP_NAME]){
        self.stopName = self.currentNode;
    }
    if ([elementName isEqualToString:STOP_POINT_REF]){
        if (![self.stopIdsAlongTheWay containsObject:elementName])[self.stopIdsAlongTheWay addObject:self.currentNode];
    }
    if ([elementName isEqualToString:ROUTES_STOP_SERVICES]){
        [self.routesStopServices addObject:self.currentNode];
    }
    if ([elementName isEqualToString:STOP_DIRECTION]){
        self.stopDirection = self.currentNode;
    }
    if ([elementName isEqualToString:STOP_ID]){
        self.stopID = self.currentNode;
    }
    if ([elementName isEqualToString:DISTANCE_TO_STOP]){
        self.distanceToStop = self.currentNode;
    }
    if ([elementName isEqualToString:VEHICLE_AT_STOP]){
        self.atStop = self.currentNode;
    }
    if ([elementName isEqualToString:UNIQUE_ID]&&![self.currentNode isEqualToString:@"UTA_Unknown"]){
        self.uniqueId = self.currentNode;
        [self.idArray addObject:self.currentNode];
    }
    if ([elementName isEqualToString:@"MonitoredVehicleJourney"]) {
        
            self.vehicleInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.publishedLineName,PUBLISHED_LINE_NAME,self.vehicleLatitude,LATITUDE,self.vehicleLongitude,LONGITUDE,self.progressRate,PROGRESS_RATE,self.departureTime,DEPARTURE_TIME,self.atStop,VEHICLE_AT_STOP, self.directionOfVehicle,DIRECTION_OF_VEHICLE,self.lineref,LINE_NAME, self.stopIdsAlongTheWay,STOP_POINT_REF,self.uniqueId,UNIQUE_ID, nil];
        
           if (![self.lineref isEqualToString:@"000"]) [self.vehicleInfoArray addObject:self.vehicleInfo];
    }
    
    if ([elementName isEqualToString:@"MonitoredCloseStop"]){
            self.stopInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.stopName,STOP_NAME,self.stopID,STOP_ID,self.stopDirection,STOP_DIRECTION,self.stopLatitude,LATITUDE,self.stopLongitude,LONGITUDE, self.routesStopServices,ROUTES_STOP_SERVICES,self.distanceToStop,DISTANCE_TO_STOP, nil];
        [self.stopInfoArray addObject:self.stopInfo];
    }
    self.currentNode = nil;
    
    
}

// NSXMLParser delegate method, that sets the contents of the mutable arrays to nil;
- (void) parserDidEndDocument:(NSXMLParser *)parser
{
    //NSLog(@"vehicles %@",self.vehicleInfoArray);
    //NSLog(@"stops %@",self.stopInfoArray);
    self.publishedLineName = nil;
    self.vehicleLatitude = nil;
    self.vehicleLongitude = nil;
    self.progressRate = nil;
    self.departureTime = nil;
    self.directionOfVehicle = nil;
    self.lineref = nil;
    self.stopIdsAlongTheWay =nil;
    self.stopID = nil;
    self.stopDirection = nil;
    self.stopName = nil;
    self.stopLatitude = nil;
    self.stopLongitude = nil;
    self.routesStopServices = nil;
    self.distanceToStop = nil;
}

@end
