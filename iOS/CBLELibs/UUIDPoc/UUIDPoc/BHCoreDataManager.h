//
//  BHCoreDataManager.h
//  UUIDPoc
//
//  Created by Ryan Morton on 2/5/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^BHCoreDataManagerBOOLResponseBlock)(BOOL success);
typedef void(^BHCoreDataManagerArrayResponseBlock)(NSArray *queryResults);

@interface BHCoreDataManager : NSObject
{
    
}

+(BHCoreDataManager*)sharedManager;

#pragma mark - Tests
-(void)getAllTestsWithCompleteBlock:(BHCoreDataManagerArrayResponseBlock)completeBlock includeAllPropertyData:(BOOL)includeAllPropertyData;

-(void)createANewTestWithCompleteBlock:(BHCoreDataManagerArrayResponseBlock)completeBlock;
@end
