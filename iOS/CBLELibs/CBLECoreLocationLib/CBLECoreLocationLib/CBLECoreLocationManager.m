//
//  CBLECoreLocationManager.m
//  CBLECoreLocationLib
//
//  Created by Ryan Morton on 1/26/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "CBLECoreLocationManager.h"
#import "CBLECoreLocationLib.h"

#pragma mark - CBLELocationManager
/**
 Adds blocks to CLLocationManager callbacks... helps to create one-time use location managers and location look-ups
 */
@interface CBLELocationManager : CLLocationManager
<CLLocationManagerDelegate>
{
    dispatch_queue_t __strong _responseQueue;
}

@property (nonatomic, copy) void(^NewLocationCompleteBlock)(NSError* error, NSArray *newLocations);

-(void)cleanUpAfterUpdatingLocation;
-(void)getLocationWithDistanceFilter:(CLLocationDistance)distanceFilter desiredAccuracy:(CLLocationAccuracy)accuracy completeBlock:(void(^)(NSError* error, NSArray *newLocations))completeBlock andResponseQueue:(dispatch_queue_t)responseQueue;
@end

@implementation CBLELocationManager

-(void)cleanUpAfterUpdatingLocation
{
    _responseQueue = nil;
    self.NewLocationCompleteBlock = nil;
    self.delegate = nil;
}

-(void)getLocationWithDistanceFilter:(CLLocationDistance)distanceFilter desiredAccuracy:(CLLocationAccuracy)accuracy completeBlock:(void(^)(NSError* error, NSArray *newLocations))completeBlock andResponseQueue:(dispatch_queue_t)responseQueue
{
    if(completeBlock && !self.NewLocationCompleteBlock && !_responseQueue)
    {
        _responseQueue = responseQueue;
        if(!_responseQueue)
        {
            _responseQueue = dispatch_get_main_queue();
        }
        
        self.distanceFilter = distanceFilter;
        self.desiredAccuracy = accuracy;
        self.delegate = self;
        self.NewLocationCompleteBlock = completeBlock;
        [self startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self stopUpdatingLocation];
    if(self.NewLocationCompleteBlock)
    {
        dispatch_async(_responseQueue, ^{
            self.NewLocationCompleteBlock(error, nil);
        });
    }
    [self cleanUpAfterUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self stopUpdatingLocation];
    if(self.NewLocationCompleteBlock)
    {
        dispatch_async(_responseQueue, ^{
            self.NewLocationCompleteBlock(nil,locations);
        });
    }
    [self cleanUpAfterUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self locationManager:manager didUpdateLocations:@[newLocation]];
}

@end

#pragma mark - CBLECoreLocationManager
@implementation CBLECoreLocationManager
static CLLocationManager __strong *_sharedCLLocationManager;

+(void)initialize
{
    [super initialize];
    static dispatch_once_t _clManageOnceToken;
    dispatch_once(&_clManageOnceToken, ^{
        _sharedCLLocationManager = [[CLLocationManager alloc] init];
    });
}

+(CLLocationManager*)sharedCLLocationManager
{
    return _sharedCLLocationManager;
}

+(BOOL)canUseCoreLocation
{
    return [CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized;
}

+(BOOL)hasValidLocationWithMinHorizontalAccuracy:(CLLocationAccuracy)hAccuracyInMeters andMaxAge:(NSTimeInterval)ageInSeconds
{
    CLLocation *_currentLocation = [self sharedCLLocationManager].location;
    NSTimeInterval deltaT = ABS([_currentLocation.timestamp timeIntervalSinceNow]);
    if(deltaT<=ageInSeconds)
    {
        if(_currentLocation.horizontalAccuracy>=0 && _currentLocation.horizontalAccuracy <= hAccuracyInMeters)
        {
            return YES;
        }
    }
    return NO;
}

+(BOOL)getLocationWithDistanceFilter:(CLLocationDistance)distanceFilter desiredAccuracy:(CLLocationAccuracy)accuracy completeBlock:(void(^)(NSError* error, NSArray *newLocations))completeBlock andResponseQueue:(dispatch_queue_t)responseQueue
{
    if([self canUseCoreLocation] && completeBlock)
    {
        CBLELocationManager *locationManager = [[CBLELocationManager alloc] init];
        [locationManager getLocationWithDistanceFilter:distanceFilter desiredAccuracy:accuracy completeBlock:^(NSError *error, NSArray *newLocations) {
            completeBlock(error,newLocations);
            //do this in order to keep the locationManager around in memory until we're done with it
            //by using it in this block, it will be retained until this block finishes
            locationManager.delegate = nil;
        } andResponseQueue:responseQueue];
        return YES;
    }
    return NO;
}
@end
