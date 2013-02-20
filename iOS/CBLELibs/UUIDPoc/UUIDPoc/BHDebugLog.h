//
//  BHDebugLog.h
//  UUIDPoc
//
//  Created by Ryan Morton on 2/18/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "BHDBObject.h"

@class DBDebugLog,BHTest;

@interface BHDebugLog : BHDBObject
<NSCopying>
{
    
}

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) BHTest *test;

+(BHDebugLog*)debugLogWithDBDebugLog:(DBDebugLog*)debugLog;
/**
 Does not copy over the "test"
 */
-(id)initWithDBDebugLog:(DBDebugLog*)debugLog;
@end
