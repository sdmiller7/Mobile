//
//  CBLECoreLocationManager.h
//  CBLECoreLocationLib
//
//  Created by Ryan Morton on 1/26/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CBLECoreLocationManager : NSObject
{
    
}

+(CLLocationManager*)sharedCLLocationManager;

+(BOOL)canUseCoreLocation;

+(BOOL)hasValidLocationWithMinHorizontalAccuracy:(CLLocationAccuracy)hAccuracyInMeters andMaxAge:(NSTimeInterval)ageInSeconds;

/**
 NOTE: this method does NOT use the shared CLLocationManager. This instantiates a new CLLocationManager (one-time-use) in order to acquire a location update.
 @return YES if the update process started, NO otherwise
 */
+(BOOL)getLocationWithDistanceFilter:(CLLocationDistance)distanceFilter desiredAccuracy:(CLLocationAccuracy)accuracy completeBlock:(void(^)(NSError* error, NSArray *newLocations))completeBlock andResponseQueue:(dispatch_queue_t)responseQueue;
@end
