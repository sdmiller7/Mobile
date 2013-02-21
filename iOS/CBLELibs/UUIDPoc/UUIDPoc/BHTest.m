//
//  BHTest.m
//  UUIDPoc
//
//  Created by Ryan Morton on 2/18/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "BHTest.h"
#import "DBTest.h"
#import "DBError.h"
#import "DBTransfer.h"
#import "DBDebugLog.h"
#import "BHError.h"
#import "BHDebugLog.h"
#import "BHTransfer.h"
#import <jsonkit/NSObject+BitHiker.h>


@implementation BHTest
+(BHTest*)testWithDBTest:(DBTest*)test
{
    BHTest *result = [[BHTest alloc] initWithDBTest:test andIncludeAllPropertData:NO];
    return [result autorelease];
}
+(BHTest*)testWithDBTest:(DBTest*)test andIncludeAllPropertData:(BOOL)includeAllPropertyData
{
    BHTest *result = [[BHTest alloc] initWithDBTest:test andIncludeAllPropertData:includeAllPropertyData];
    return [result autorelease];
}
-(void)dealloc
{
    self.endDate = nil;
    self.startDate = nil;
    self.debugLogs = nil;
    self.errors = nil;
    self.transfers = nil;
    [super dealloc];
}

-(id)initWithDBTest:(DBTest*)test andIncludeAllPropertData:(BOOL)includeAllPropertyData
{
    self = [super init];
    if(self)
    {
        self.errors = [NSMutableArray array];
        self.transfers = [NSMutableArray array];
        self.debugLogs = [NSMutableArray array];
        self.managedObjectURI = [[test objectID] URIRepresentation];
        
        if(test)
        {
            self.endDate = [[test.endDate copy] autorelease];
            self.startDate = [[test.startDate copy] autorelease];
            if(includeAllPropertyData)
            {
                for(DBTransfer *t in test.transfers)
                {
                    BHTransfer *mT = [BHTransfer transferWithDBTransfer:t];
                    //mT.test = self;
                    [self.transfers addObject:mT];
                }
                [self.transfers sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
                
                for(DBError *error in test.errors)
                {
                    BHError *mError = [BHError errorWithDBError:error];
                    //mError.test = self;
                    [self.errors addObject:mError];
                }
                [self.errors sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
                
                for(DBDebugLog *log in test.debugLogs)
                {
                    BHDebugLog *mLog = [BHDebugLog debugLogWithDBDebugLog:log];
                    //mLog.test = self;
                    [self.debugLogs addObject:mLog];
                }
                [self.debugLogs sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
            }
        }
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    BHTest *result = [[BHTest alloc] init];
    
    result.endDate = [[self.endDate copyWithZone:zone] autorelease];
    result.startDate = [[self.startDate copyWithZone:zone] autorelease];
    result.debugLogs = [[self.debugLogs copyWithZone:zone] autorelease];
    result.transfers = [[self.transfers copyWithZone:zone] autorelease];
    result.errors = [[self.errors copyWithZone:zone] autorelease];
    result.debugLogs = [[self.debugLogs copyWithZone:zone] autorelease];
    result.managedObjectURI = [[self.managedObjectURI copyWithZone:zone] autorelease];
    
    return result;
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"%@<%p>\n%@",NSStringFromClass(self.class),self,[self dictionaryRep]];
}

#pragma mark Core Data Helper Methods

-(DBTest*)DBTestWithPersistentStore:(NSPersistentStoreCoordinator*)persistentStore andContext:(NSManagedObjectContext*)currentContext
{
    if(currentContext && persistentStore)
    {
        DBTest *test = nil;
        
        if(self.managedObjectURI)
        {
            NSManagedObjectID *objectID = [persistentStore managedObjectIDForURIRepresentation:self.managedObjectURI];
            if(objectID)
            {
                NSError *error = nil;
                NSFetchRequest *testRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *testDescription = [NSEntityDescription entityForName:@"Tests" inManagedObjectContext:currentContext];
                [testRequest setEntity:testDescription];
                [testRequest setIncludesPendingChanges:YES];
                [testRequest setIncludesPropertyValues:YES];
                [testRequest setReturnsObjectsAsFaults:NO];
                [testRequest setFetchLimit:1];
                NSPredicate *where = [NSPredicate predicateWithFormat:@"self IN %@",@[objectID]];
                [testRequest setPredicate:where];
                
                test = [[currentContext executeFetchRequest:testRequest error:&error] lastObject];
                [testRequest release];
            }
        }
        
        return test;
    }
    return nil;
}

-(NSManagedObjectID*)managedObjectIDWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    if(persistentStoreCoordinator && self.managedObjectURI)
    {
        NSManagedObjectID *objectID = [persistentStoreCoordinator managedObjectIDForURIRepresentation:self.managedObjectURI];
        return objectID;
    }
    return nil;
}

-(void)saveToManagedObject:(NSManagedObject *)managedObject
{
    [self saveToManagedObject:managedObject withExclusionList:@[@"debugLogs",@"errors",@"transfers"]];
}
@end
