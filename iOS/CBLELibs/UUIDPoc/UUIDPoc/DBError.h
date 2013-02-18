//
//  DBError.h
//  UUIDPoc
//
//  Created by Ryan Morton on 2/18/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBTest;

@interface DBError : NSManagedObject

@property (nonatomic, retain) NSString * cause;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) DBTest *test;

@end
