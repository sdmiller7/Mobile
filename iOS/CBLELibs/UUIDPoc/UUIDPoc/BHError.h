//
//  BHError.h
//  UUIDPoc
//
//  Created by Ryan Morton on 2/18/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BHDBObject.h"
@class BHTest,DBError;

@interface BHError : BHDBObject
{
    
}

@property (nonatomic, retain) NSString * cause;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) BHTest *test;

+(BHError*)errorWithDBError:(DBError*)error;

/**
 Does not copy over the "test"
 */
-(id)initWithDBError:(DBError*)error;
@end
