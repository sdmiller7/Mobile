//
//  BHCoreDataManager.h
//  UUIDPoc
//
//  Created by Ryan Morton on 2/5/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BHError,BHTest,BHDebugLog,BHTransfer;

typedef void(^BHCoreDataManagerBOOLResponseBlock)(BOOL success);
typedef void(^BHCoreDataManagerArrayResponseBlock)(NSArray *queryResults);

@interface BHCoreDataManager : NSObject
{
    
}

+(BHCoreDataManager*)sharedManager;

#pragma mark - Errors
-(void)logError:(BHError*)bhError forTest:(BHTest*)bhTest withCompleteBlock:(BHCoreDataManagerBOOLResponseBlock)completeBlock;

#pragma mark - Tests

-(void)getLastTestWithCompleteBlock:(BHCoreDataManagerArrayResponseBlock)completeBlock;

-(void)getAllTestsWithCompleteBlock:(BHCoreDataManagerArrayResponseBlock)completeBlock includeAllPropertyData:(BOOL)includeAllPropertyData;

-(void)createANewTestWithCompleteBlock:(BHCoreDataManagerArrayResponseBlock)completeBlock;
@end
