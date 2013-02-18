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
@end
