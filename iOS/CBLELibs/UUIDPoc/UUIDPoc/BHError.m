//
//  BHError.m
//  UUIDPoc
//
//  Created by Ryan Morton on 2/18/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "BHError.h"
#import "BHTest.h"
#import "DBError.h"
#import <jsonkit/NSObject+BitHiker.h>

@implementation BHError
+(BHError*)errorWithDBError:(DBError*)error
{
    BHError *result = [[BHError alloc] initWithDBError:error];
    return [result autorelease];
}

-(void)dealloc
{
    self.cause = nil;
    self.date = nil;
    self.title = nil;
    self.test = nil;
    [super dealloc];
}

-(id)initWithDBError:(DBError*)error
{
    self = [super init];
    if(self)
    {
        if(error)
        {
            self.cause = [[error.cause copy] autorelease];
            self.date = [[error.date copy] autorelease];
            self.title = [[error.title copy] autorelease];
            self.managedObjectURI = [[error objectID] URIRepresentation];
        }
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    BHError *result = [[BHError alloc] init];
    
    result.cause = [[self.cause copyWithZone:zone] autorelease];
    result.date = [[self.date copyWithZone:zone] autorelease];
    result.test = [[self.test copyWithZone:zone] autorelease];
    result.title = [[self.title copyWithZone:zone] autorelease];
    result.managedObjectURI = [[self.managedObjectURI copyWithZone:zone] autorelease];
    
    return result;
}

-(void)saveToManagedObject:(NSManagedObject *)managedObject
{
    [self saveToManagedObject:managedObject withExclusionList:@[@"test"]];
}
@end
