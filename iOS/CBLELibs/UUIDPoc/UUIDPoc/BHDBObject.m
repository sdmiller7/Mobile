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


@end
