//
//  BHTest.h
//  UUIDPoc
//
//  Created by Ryan Morton on 2/18/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BHDBObject.h"
#import <CoreData/CoreData.h>

@class DBTest;

@interface BHTest : BHDBObject
<NSCopying>
{
    
}

@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSMutableArray *debugLogs;
@property (nonatomic, retain) NSMutableArray *errors;
@property (nonatomic, retain) NSMutableArray *transfers;

+(BHTest*)testWithDBTest:(DBTest*)test;
+(BHTest*)testWithDBTest:(DBTest*)test andIncludeAllPropertData:(BOOL)includeAllPropertyData;

-(id)initWithDBTest:(DBTest*)test andIncludeAllPropertData:(BOOL)includeAllPropertyData;

#pragma mark Core Data Helper Methods
-(DBTest*)DBTestWithPersistentStore:(NSPersistentStoreCoordinator*)persistentStore andContext:(NSManagedObjectContext*)currentContext;

-(NSManagedObjectID*)managedObjectIDWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)persistentStoreCoordinator;
@end
