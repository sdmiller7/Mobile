//
//  BHDBObject.m
//  UUIDPoc
//
//  Created by Ryan Morton on 2/18/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "BHDBObject.h"
#import <jsonkit/NSObject+BitHiker.h>


@implementation BHDBObject
-(void)dealloc
{
    self.managedObjectURI = nil;
    [super dealloc];
}

-(void)saveToManagedObject:(NSManagedObject*)managedObject
{
    [self saveToManagedObject:managedObject withExclusionList:nil];
}

-(void)saveToManagedObject:(NSManagedObject*)managedObject withExclusionList:(NSArray*)excludedPropertyNames
{
    if(managedObject)
    {
        NSArray *myPropNames = [self propertyNames];
        NSArray *otherPropNames = [managedObject propertyNames];
        
        for(NSString *prop in myPropNames)
        {
            @try
            {
                if([otherPropNames containsObject:prop] && ![excludedPropertyNames containsObject:prop])
                {
                    if([[self valueForKey:prop] conformsToProtocol:@protocol(NSCopying)])
                    {
                        [managedObject setValue:[[[self valueForKey:prop] copy] autorelease] forKey:prop];
                    }
                    else
                    {
                        [managedObject setValue:[self valueForKey:prop] forKey:prop];
                    }
                }
            }
            @catch(NSException *ex){}
        }
    }
}

@end
