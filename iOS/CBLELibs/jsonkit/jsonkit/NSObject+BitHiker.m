//
//  NSObject+BitHiker.m
//  UUIDPoc
//
//  Created by Ryan Morton on 2/6/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "NSObject+BitHiker.h"
#import "JSONKit.h"
#import "NSDate+BitHiker.h"


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

-(NSMutableDictionary*)propertyNamesAndTypes
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
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
                NSString *propertyType = [self propertyTypeForProperty:prop];
                if(propertyType.length>0)
                {
                    [result setObject:propertyType forKey:propName];
                }
            }
    	}
    }
    free(props);//release... because of copy
    return result;
}

-(NSString*)propertyTypeForProperty:(objc_property_t)property
{
    NSString *result = nil;
    
    @try
    {
        const char *attribs = property_getAttributes(property);
        NSString *attributes = [NSString stringWithCString:attribs encoding:NSUTF8StringEncoding];
        if(attributes.length>0)
        {
            //NSLog(@"attribs: %@",attributes);
            NSArray *comps = [attributes componentsSeparatedByString:@","];
            if(comps.count>0)
            {
                NSString *dirtyType = [comps objectAtIndex:0];
                if([dirtyType rangeOfString:@"T@"].location==0)
                {
                    //object or id
                    if(dirtyType.length>2)
                    {
                        result = [[dirtyType stringByReplacingOccurrencesOfString:@"T@" withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    }
                    else
                    {
                        result = @"id";
                    }
                }
                else if([dirtyType rangeOfString:@"Tc"].location==0)
                {
                    result = @"BOOL";
                }
                else if([dirtyType rangeOfString:@"Ti"].location==0)
                {
                    result = @"NSInteger";
                }
                else if([dirtyType rangeOfString:@"TI"].location==0)
                {
                    result = @"NSUInteger";
                }
                else if([dirtyType rangeOfString:@"Tq"].location==0)
                {
                    result = @"long long";
                }
                else if([dirtyType rangeOfString:@"TQ"].location==0)
                {
                    result = @"unsigned long long";
                }
                else if([dirtyType rangeOfString:@"Tl"].location==0)
                {
                    result = @"long";
                }
                else if([dirtyType rangeOfString:@"Tf"].location==0)
                {
                    result = @"float";
                }
                else if([dirtyType rangeOfString:@"Td"].location==0)
                {
                    result = @"double";
                }
            }
        }
    }
    @catch(NSException *ex){}
    
    return result;
}

-(NSMutableDictionary*)dictionaryRep
{
    NSDictionary *propsAndTypes = [self propertyNamesAndTypes];
    NSArray *allPropNames = [propsAndTypes allKeys];
    NSString *propType = nil;
    NSMutableDictionary *dictionaryRep = [NSMutableDictionary dictionaryWithCapacity:allPropNames.count];
    for(NSString *propName in allPropNames)
    {
        id o = [self valueForKey:propName];
        propType = [propsAndTypes objectForKey:propName];
        if(o)
        {
            if([o isKindOfClass:[NSNumber class]])
            {
                if([o isKindOfClass:NSClassFromString(@"NSCFBoolean")] ||
                   [propType isEqualToString:@"BOOL"])
                {
                    //[jsonDictionary setObject:[(NSNumber*)o boolValue]?@"true":@"false" forKey:propName];
                    [dictionaryRep setObject:[NSNumber numberWithBool:[(NSNumber*)o boolValue]?YES:NO] forKey:propName];
                }
                else
                {
                    [dictionaryRep setObject:o forKey:propName];
                }
            }
            else if([o isKindOfClass:[NSArray class]])
            {
                NSArray *array = [self jsonSafeArrayValue:(NSArray*)o];
                if(array)
                {
                    [dictionaryRep setObject:array forKey:propName];
                }
            }
            else if([o isKindOfClass:[NSSet class]])
            {
                NSArray *array = [self jsonSafeArrayValue:(NSArray*)o];
                if(array)
                {
                    [dictionaryRep setObject:array forKey:propName];
                }
            }
            else if([o isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *dictionary = [self jsonSafeDictionary:(NSDictionary*)o];
                if(dictionary)
                {
                    [dictionaryRep setObject:dictionary forKey:propName];
                }
            }
            else if([o isKindOfClass:[NSString class]])
            {
                [dictionaryRep setObject:o forKey:propName];
            }
            else if([o isKindOfClass:[NSDate class]])
            {
                NSString *dateAsString = [(NSDate*)o UTCStringRepresentation];
                [dictionaryRep setObject:dateAsString forKey:propName];
            }
            else
            {
                NSMutableDictionary *linkedObjectDictionary = [o dictionaryRep];
                if(linkedObjectDictionary.count>0)
                {
                    [dictionaryRep setObject:linkedObjectDictionary forKey:propName];
                }
            }
        }
    }
    
    return dictionaryRep;
}

-(id)jsonSafeDictionary:(NSDictionary*)dictionary
{
    if(dictionary)
    {
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:dictionary.count];
        NSArray *keys = [dictionary allKeys];
        for(NSObject *o in keys)
        {
            if([o isKindOfClass:[NSString class]])
            {
                id value = [dictionary objectForKey:o];
                if([value isKindOfClass:[NSString class]])
                {
                    [result setObject:value forKey:(NSString*)o];
                }
                else if([value isKindOfClass:[NSNumber class]])
                {
                    [result setObject:value forKey:(NSString*)o];
                }
                else if([value isKindOfClass:[NSArray class]])
                {
                    [result setObject:[self jsonSafeArrayValue:(NSArray*)value] forKey:(NSString*)o];
                }
                else if([value isKindOfClass:[NSDate class]])
                {
                    [result setObject:[(NSDate*)value UTCStringRepresentation] forKey:(NSString*)o];
                }
                else if([value isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary *dictionaryRep = [self jsonSafeDictionary:(NSDictionary*)value];
                    if(dictionaryRep)
                    {
                        [result setObject:dictionaryRep forKey:(NSString*)o];
                    }
                }
                else
                {
                    NSDictionary *dictionaryRep = [value dictionaryRep];
                    if(dictionaryRep)
                    {
                        [result setObject:dictionaryRep forKey:(NSString*)o];
                    }
                }
            }
        }
        return result;
    }
    return nil;
}

-(id)jsonSafeArrayValue:(NSArray *)array
{
    if(array)
    {
        NSMutableArray *result = [NSMutableArray arrayWithCapacity:array.count];
        for(NSObject *subO in array)
        {
            if([subO isKindOfClass:[NSString class]])
            {
                [result addObject:subO];
            }
            else if([subO isKindOfClass:[NSNumber class]])
            {
                [result addObject:subO];
            }
            else if([subO isKindOfClass:[NSArray class]])
            {
                [result addObject:[self jsonSafeArrayValue:(NSArray*)subO]];
            }
            else if([subO isKindOfClass:[NSDate class]])
            {
                [result addObject:[(NSDate*)subO UTCStringRepresentation]];
            }
            else if([subO isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *dictionaryRep = [self jsonSafeDictionary:(NSDictionary*)subO];
                if(dictionaryRep)
                {
                    [result addObject:dictionaryRep];
                }
            }
            else
            {
                NSDictionary *dictionaryRep = [subO dictionaryRep];
                if(dictionaryRep)
                {
                    [result addObject:dictionaryRep];
                }
            }
        }
        return result;
    }
    return nil;
}

-(NSMutableString*)jsonRepresentation
{
    NSMutableString *jsonRep = [NSMutableString string];
    NSMutableDictionary *jsonDictionary = [self dictionaryRep];
    if(jsonDictionary)
    {
        @try
        {
            NSString *jsonString = [jsonDictionary JSONString];
            if(jsonString.length>0)
            {
                [jsonRep appendString:jsonString];
            }
        }
        @catch(NSException *ex){}
    }
    
    return jsonRep;
}

@end
