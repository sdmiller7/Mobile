//
//  BHTransfer.h
//  UUIDPoc
//
//  Created by Ryan Morton on 2/18/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "BHDBObject.h"

@class BHTest, DBTransfer;

@interface BHTransfer : BHDBObject
{
    
}

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * horizontalAccuracy;
@property (nonatomic, retain) NSDate * lastLocationUpdate;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitue;
@property (nonatomic, retain) NSNumber * verticalAccuracy;
@property (nonatomic, retain) BHTest *test;

+(BHTransfer*)transferWithDBTransfer:(DBTransfer*)transfer;
/**
 Does not copy over the "test"
 */
-(id)initWithDBTransfer:(DBTransfer*)transfer;
@end
