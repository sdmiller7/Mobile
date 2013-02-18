//
//  DBErrors.h
//  CBLEBase
//
//  Created by Ryan Morton on 2/18/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBTest;

@interface DBErrors : NSManagedObject

@property (nonatomic, retain) NSString * cause;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) DBTest *test;

@end
