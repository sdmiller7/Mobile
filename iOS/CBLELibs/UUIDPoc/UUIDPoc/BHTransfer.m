//
//  BHTransfer.m
//  UUIDPoc
//
//  Created by Ryan Morton on 2/18/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "BHTransfer.h"
#import "DBTransfer.h"
#import <jsonkit/NSObject+BitHiker.h>

@implementation BHTransfer
-(void)dealloc
{
    self.date = nil;
    self.horizontalAccuracy = nil;
    self.lastLocationUpdate = nil;
    self.latitude = nil;
    self.longitue = nil;
    self.verticalAccuracy = nil;
    self.test = nil;
    [super dealloc];
}

+(BHTransfer*)transferWithDBTransfer:(DBTransfer*)transfer
{
    BHTransfer *result = [[BHTransfer alloc] initWithDBTransfer:transfer];
    return [result autorelease];
}

-(id)initWithDBTransfer:(DBTransfer*)transfer
{
    self = [super init];
    if(self)
    {
        if(transfer)
        {
            self.date = [[transfer.date copy] autorelease];
            self.horizontalAccuracy = [[transfer.horizontalAccuracy copy] autorelease];
            self.lastLocationUpdate = [[transfer.lastLocationUpdate copy] autorelease];
            self.latitude = [[transfer.latitude copy] autorelease];
            self.longitue = [[transfer.longitue copy] autorelease];
            self.verticalAccuracy = [[transfer.verticalAccuracy copy] autorelease];
            self.managedObjectURI = [[transfer objectID] URIRepresentation];
        }
    }
    return self;
}
@end
