//
//  DBTransfer.h
//  CBLEBase
//
//  Created by Ryan Morton on 2/18/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBTest;

@interface DBTransfer : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * horizontalAccuracy;
@property (nonatomic, retain) NSDate * lastLocationUpdate;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitue;
@property (nonatomic, retain) NSNumber * verticalAccuracy;
@property (nonatomic, retain) DBTest *test;

@end
