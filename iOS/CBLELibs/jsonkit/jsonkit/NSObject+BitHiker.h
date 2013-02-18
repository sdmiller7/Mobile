//
//  NSObject+BitHiker.h
//  UUIDPoc
//
//  Created by Ryan Morton on 2/6/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (BitHiker)

/**
 This doesn't return the property names of super classes.
 */
-(NSMutableArray*)propertyNames;

/**
 This doesn't return the property names/types of super classes.
 */
-(NSMutableDictionary*)propertyNamesAndTypes;

-(NSString*)propertyTypeForProperty:(objc_property_t)property;

-(NSMutableString*)jsonRepresentation;

/**
 This doesn't return the property names/types of super classes.
 */
-(NSMutableDictionary*)dictionaryRep;
@end
