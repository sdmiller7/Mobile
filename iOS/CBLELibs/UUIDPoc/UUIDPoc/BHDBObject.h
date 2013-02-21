//
//  BHDBObject.h
//  UUIDPoc
//
//  Created by Ryan Morton on 2/18/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BHDBObject : NSObject
{
    
}

@property (nonatomic, retain) NSURL *managedObjectURI;
@property (nonatomic, retain) NSURL *testManagedObjectURI;

-(void)saveToManagedObject:(NSManagedObject*)managedObject;
-(void)saveToManagedObject:(NSManagedObject*)managedObject withExclusionList:(NSArray*)excludedPropertyNames;
@end
