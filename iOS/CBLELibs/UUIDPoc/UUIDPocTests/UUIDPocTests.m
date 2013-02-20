//
//  UUIDPocTests.m
//  UUIDPocTests
//
//  Created by Ryan Morton on 2/19/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "UUIDPocTests.h"
#import "BHCoreDataManager.h"
#import "BHUtils.h"
#import <CoreData/CoreData.h>
#import "DBTest.h"
#import "DBError.h"
#import "DBDebugLog.h"
#import "DBTransfer.h"
#import "BHTest.h"
#import "BHDebugLog.h"
#import "BHTransfer.h"
#import "BHError.h"


@implementation UUIDPocTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


-(void)testCreateTest
{
    [[BHCoreDataManager sharedManager] createANewTestWithCompleteBlock:^(NSArray *queryResults) {
        NSURL *testObjectURI = [(BHTest*)[queryResults lastObject] managedObjectURI];
        NSAssert(testObjectURI,@"test does not have a URI");
    }];
}

@end
