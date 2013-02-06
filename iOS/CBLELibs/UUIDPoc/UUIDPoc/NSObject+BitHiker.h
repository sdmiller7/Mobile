//
//  NSObject+BitHiker.h
//  UUIDPoc
//
//  Created by Ryan Morton on 2/6/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (BitHiker)

/**
 This doesn't return the property names of super classes.
 */
-(NSMutableArray*)propertyNames;
@end
