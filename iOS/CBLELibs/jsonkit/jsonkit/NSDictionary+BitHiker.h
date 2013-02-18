//
//  NSDictionary+BitHiker.h
//  jsonkit
//
//  Created by Ryan Morton on 2/12/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (BitHiker)
-(id)objectForKey:(id)aKey andClass:(Class)objectClass;
@end
