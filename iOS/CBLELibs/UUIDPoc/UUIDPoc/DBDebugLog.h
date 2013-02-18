//
//  DBDebugLog.h
//  CBLEBase
//
//  Created by Ryan Morton on 2/18/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBTest;

@interface DBDebugLog : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) DBTest *test;

@end
