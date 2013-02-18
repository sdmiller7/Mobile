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
            self.managedObjectURI = [[error objectID] URIRepresentation];
        }
    }
    return self;
}
@end
