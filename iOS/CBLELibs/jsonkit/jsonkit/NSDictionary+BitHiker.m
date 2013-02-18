//
//  NSDictionary+BitHiker.m
//  jsonkit
//
//  Created by Ryan Morton on 2/12/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "NSDictionary+BitHiker.h"

@implementation NSDictionary (BitHiker)
-(id)objectForKey:(id)aKey andClass:(Class)objectClass
{
    id result = nil;
    
    @try
    {
        id o = [self objectForKey:aKey];
        if([o isKindOfClass:objectClass])
        {
            result = o;
        }
    }
    @catch(NSException *ex){}
    
    return result;
}
@end
