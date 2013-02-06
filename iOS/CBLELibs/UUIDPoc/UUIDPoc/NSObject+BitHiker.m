//
//  NSObject+BitHiker.m
//  UUIDPoc
//
//  Created by Ryan Morton on 2/6/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "NSObject+BitHiker.h"
#import <objc/runtime.h>

@implementation NSObject (BitHiker)

-(NSMutableArray*)propertyNames
{
    NSMutableArray *result = [NSMutableArray array];
    
    unsigned int propCount, i;
    objc_property_t *props = class_copyPropertyList([self class], &propCount);
    for(i = 0; i < propCount; i++)
    {
    	objc_property_t prop = props[i];
    	const char *propNameCString = property_getName(prop);
    	if(propNameCString)
        {
    		NSString *propName = [NSString stringWithCString:propNameCString encoding:NSUTF8StringEncoding];
            if(propName.length>0)
            {
                [result addObject:propName];
            }
    	}
    }
    free(props);//release... because of copy
    
    return result;
}

@end
