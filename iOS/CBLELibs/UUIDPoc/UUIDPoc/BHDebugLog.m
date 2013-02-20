//
//  BHDebugLog.m
//  UUIDPoc
//
//  Created by Ryan Morton on 2/18/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "BHDebugLog.h"
#import "DBDebugLog.h"
#import "DBTest.h"
#import "BHTest.h"
#import <jsonkit/NSObject+BitHiker.h>

@implementation BHDebugLog
+(BHDebugLog*)debugLogWithDBDebugLog:(DBDebugLog*)debugLog
{
    BHDebugLog *result = [[BHDebugLog alloc] initWithDBDebugLog:debugLog];
    return [result autorelease];
}
-(void)dealloc
{
    self.date = nil;
    self.message = nil;
    self.test = nil;
    [super dealloc];
}

-(id)initWithDBDebugLog:(DBDebugLog*)debugLog
{
    self = [super init];
    if(self)
    {
        if(debugLog)
        {
            self.date = [[debugLog.date copy] autorelease];
            self.message = [[debugLog.message copy] autorelease];
            self.managedObjectURI = [[debugLog objectID] URIRepresentation];
        }
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    BHDebugLog *result= [[BHDebugLog alloc] init];
    
    result.date = [[self.date copyWithZone:zone] autorelease];
    result.message = [[self.message copyWithZone:zone] autorelease];
    result.test = [[self.test copyWithZone:zone] autorelease];
    result.managedObjectURI = [[self.managedObjectURI copyWithZone:zone] autorelease];
    
    return result;
}

-(void)saveToManagedObject:(NSManagedObject *)managedObject
{
    [self saveToManagedObject:managedObject withExclusionList:@[@"test"]];
}
@end
