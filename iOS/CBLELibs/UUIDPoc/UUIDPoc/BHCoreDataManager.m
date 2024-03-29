//
//  BHCoreDataManager.m
//  UUIDPoc
//
//  Created by Ryan Morton on 2/5/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

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

#pragma mark - BHCoreDataOperationWrapper
/**
 Wrapper... prevents having to rewrite the same code multiple times over
 */
@interface BHCoreDataOperationWrapper : NSOperation
{
    
}
@property (nonatomic, retain) NSManagedObjectModel *mModel;
@property (nonatomic, retain) NSManagedObjectContext *mContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *mPersistentStoreCoordinator;
@property (nonatomic, copy) void(^CDWorkerBlock)(NSManagedObjectModel *model, NSManagedObjectContext *currentContext, NSPersistentStoreCoordinator *persistentStoreCoordinator);

+(BHCoreDataOperationWrapper*)wrapperWithManagedObjectModel:(NSManagedObjectModel*)model persistentStoreCoordinator:(NSPersistentStoreCoordinator*)persistentStoreCoordinator andWorkerBlock:(void(^)(NSManagedObjectModel *model, NSManagedObjectContext *currentContext, NSPersistentStoreCoordinator *persistentStoreCoordinator))workerBlock;

-(id)initWithManagedObjectModel:(NSManagedObjectModel*)model andPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)persistentStoreCoordinator;
@end

@implementation BHCoreDataOperationWrapper
+(BHCoreDataOperationWrapper*)wrapperWithManagedObjectModel:(NSManagedObjectModel*)model persistentStoreCoordinator:(NSPersistentStoreCoordinator*)persistentStoreCoordinator andWorkerBlock:(void(^)(NSManagedObjectModel *model, NSManagedObjectContext *currentContext, NSPersistentStoreCoordinator *persistentStoreCoordinator))workerBlock
{
    BHCoreDataOperationWrapper *wrapper = [[BHCoreDataOperationWrapper alloc] initWithManagedObjectModel:model andPersistentStoreCoordinator:persistentStoreCoordinator];
    
    wrapper.CDWorkerBlock = workerBlock;
    
    return [wrapper autorelease];
}
-(void)dealloc
{
    self.mPersistentStoreCoordinator = nil;
    self.mModel = nil;
    self.mContext = nil;
    self.CDWorkerBlock = nil;
    [super dealloc];
}

-(id)initWithManagedObjectModel:(NSManagedObjectModel*)model andPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    self = [super init];
    if(self)
    {
        self.mModel = model;
        self.mPersistentStoreCoordinator = persistentStoreCoordinator;
    }
    return self;
}

-(void)main
{
    if(!self.isCancelled && self.CDWorkerBlock && self.mPersistentStoreCoordinator && self.mModel)
    {
        @autoreleasepool {
            self.mContext = [[[NSManagedObjectContext alloc] init] autorelease];
            [self.mContext setPersistentStoreCoordinator:self.mPersistentStoreCoordinator];
            [self.mContext setUndoManager:nil];
            
            self.CDWorkerBlock(self.mModel,self.mContext,self.mPersistentStoreCoordinator);
            
            [self.mContext reset];
        }
    }
    self.CDWorkerBlock = nil;
    self.mPersistentStoreCoordinator = nil;
    self.mModel = nil;
    self.mContext = nil;
}

@end



#pragma mark - BHCoreDataManager
@interface BHCoreDataManager ()
{
    
}

@property (nonatomic, retain) NSOperationQueue *cdOperationQueue;
@property (nonatomic, retain) NSManagedObjectModel *cdManagedObjectModel;
@property (nonatomic, retain) NSPersistentStoreCoordinator *cdPersistentStoreCoordinator;
@end

@implementation BHCoreDataManager
static BHCoreDataManager *_sharedManager;
+(BHCoreDataManager*)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[BHCoreDataManager alloc] init];
    });
    
    return _sharedManager;
}

+(NSURL*)getPersistantStoreURL
{
    return [[NSURL fileURLWithPath:[BHUtils applicationLibraryDirectory]] URLByAppendingPathComponent:@"UUIDPoc.db"];
}
+(NSURL*)getModelURL
{
    return [[NSBundle mainBundle] URLForResource:@"UUIDPoc" withExtension:@"momd"];
}
+(NSManagedObjectModel*)getManagedObjectModelUsingModelURL:(NSURL*)modelURL
{
    return [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] autorelease];
}

+(NSManagedObjectContext*)getManagedObjectContextUsingPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)psCoordinator
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:psCoordinator];
    return [context autorelease];
}

+(BOOL)setFilePropertiesForCDPersistentStoreWithPath:(NSURL*)fullPathToStore
{
    if(fullPathToStore)
    {
        BOOL success = YES;
        
        NSFileManager *fMan = [[NSFileManager alloc] init];
        if([fMan fileExistsAtPath:[fullPathToStore path]])
        {
            success &= [BHUtils setSkipBackupAttribOfFileWithURL:fullPathToStore];
        }
        else{success &=NO;}
        [fMan release];
        
        return success;
    }
    return NO;
}

-(void)dealloc
{
    if(self.cdOperationQueue)
    {
        [self.cdOperationQueue cancelAllOperations];
    }
    self.cdOperationQueue = nil;
    self.cdManagedObjectModel = nil;
    self.cdPersistentStoreCoordinator = nil;
    [super dealloc];
}

-(void)internalInit
{
    self.cdOperationQueue  =[[[NSOperationQueue alloc] init] autorelease];
    self.cdOperationQueue.maxConcurrentOperationCount = 1;
    
    NSURL *storeURL = [BHCoreDataManager getPersistantStoreURL];
    NSURL *modelURL = [BHCoreDataManager getModelURL];
    self.cdManagedObjectModel = [BHCoreDataManager getManagedObjectModelUsingModelURL:modelURL];
    
    //create persistant store coordinator
    NSError *error = nil;
    self.cdPersistentStoreCoordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self cdManagedObjectModel]] autorelease];
    
    NSDictionary *storeOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,NSFileProtectionCompleteUntilFirstUserAuthentication,NSPersistentStoreFileProtectionKey, nil];
    
    if (![self.cdPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:storeOptions error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        
        //try again after delete
        if(![self.cdPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:storeOptions error:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    [BHCoreDataManager setFilePropertiesForCDPersistentStoreWithPath:storeURL];
}

-(id)init
{
    self = [super init];
    if(self)
    {
        [self internalInit];
    }
    return self;
}

-(void)addOperationToCDQueueWithWorkerBlock:(void(^)(NSManagedObjectModel *model, NSManagedObjectContext *currentContext, NSPersistentStoreCoordinator *persistentStoreCoordinator))workerBlock
{
    if(workerBlock)
    {
        BHCoreDataOperationWrapper *wrapper = [BHCoreDataOperationWrapper wrapperWithManagedObjectModel:self.cdManagedObjectModel persistentStoreCoordinator:self.cdPersistentStoreCoordinator andWorkerBlock:workerBlock];
        [self.cdOperationQueue addOperation:wrapper];
    }
}

#pragma mark - Transfers
-(void)saveTransfer:(BHTransfer*)bhTransfer forTest:(BHTest*)bhTest withCompleteBlock:(BHCoreDataManagerBOOLResponseBlock)completeBlock
{
    if(bhTest.managedObjectURI && bhTransfer)
    {
        [self addOperationToCDQueueWithWorkerBlock:^(NSManagedObjectModel *model, NSManagedObjectContext *currentContext, NSPersistentStoreCoordinator *persistentStoreCoordinator) {
            
            NSError *error = nil;
            DBTest *test = [bhTest DBTestWithPersistentStore:persistentStoreCoordinator andContext:currentContext];
            BOOL success = YES;
            if(test)
            {
                DBTransfer *dbTransfer = [NSEntityDescription insertNewObjectForEntityForName:@"Transfers" inManagedObjectContext:currentContext];
                [test addTransfersObject:dbTransfer];
                dbTransfer.test = test;
                [bhTransfer saveToManagedObject:dbTransfer];
                
                success = [currentContext save:&error];
            }
            else
            {
                success &= NO;
            }
            
            if(completeBlock)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(success);
                });
            }
        }];
    }
}

-(void)getAllTransfersForTest:(BHTest*)bhTest withCompleteBlock:(BHCoreDataManagerArrayResponseBlock)completeBlock
{
    if(completeBlock)
    {
        [self addOperationToCDQueueWithWorkerBlock:^(NSManagedObjectModel *model, NSManagedObjectContext *currentContext, NSPersistentStoreCoordinator *persistentStoreCoordinator) {
            
            NSError *error = nil;
            NSMutableArray *result = [NSMutableArray array];
            NSManagedObjectID *testID = [bhTest managedObjectIDWithPersistentStoreCoordinator:persistentStoreCoordinator];
            
            if(testID)
            {
                NSFetchRequest *transfersRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *logDescription = [NSEntityDescription entityForName:@"Transfers" inManagedObjectContext:currentContext];
                [transfersRequest setEntity:logDescription];
                [transfersRequest setIncludesPendingChanges:YES];
                [transfersRequest setIncludesPropertyValues:YES];
                [transfersRequest setReturnsObjectsAsFaults:NO];
                NSPredicate *where = [NSPredicate predicateWithFormat:@"test == %@",testID];
                [transfersRequest setPredicate:where];
                [transfersRequest setFetchBatchSize:100];
                
                NSArray *queryResults = [currentContext executeFetchRequest:transfersRequest error:&error];
                [transfersRequest release];
                for(DBTransfer *transfer in queryResults)
                {
                    BHTransfer *mtransfer = [BHTransfer transferWithDBTransfer:transfer];
                    mtransfer.test = bhTest;
                    mtransfer.testManagedObjectURI = bhTest.managedObjectURI;
                    [result addObject:mtransfer];
                }
                [result sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(result);
            });
        }];
    }
}

#pragma mark - Debug
-(void)getAllDebugLogsForTest:(BHTest*)bhTest withCompleteBlock:(BHCoreDataManagerArrayResponseBlock)completeBlock
{
    if(completeBlock)
    {
        [self addOperationToCDQueueWithWorkerBlock:^(NSManagedObjectModel *model, NSManagedObjectContext *currentContext, NSPersistentStoreCoordinator *persistentStoreCoordinator) {
            
            NSError *error = nil;
            NSMutableArray *result = [NSMutableArray array];
            NSManagedObjectID *testID = [bhTest managedObjectIDWithPersistentStoreCoordinator:persistentStoreCoordinator];
            
            if(testID)
            {
                NSFetchRequest *logRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *logDescription = [NSEntityDescription entityForName:@"DebugLogs" inManagedObjectContext:currentContext];
                [logRequest setEntity:logDescription];
                [logRequest setIncludesPendingChanges:YES];
                [logRequest setIncludesPropertyValues:YES];
                [logRequest setReturnsObjectsAsFaults:NO];
                NSPredicate *where = [NSPredicate predicateWithFormat:@"test == %@",testID];
                [logRequest setPredicate:where];
                [logRequest setFetchBatchSize:100];
                
                NSArray *queryResults = [currentContext executeFetchRequest:logRequest error:&error];
                [logRequest release];
                for(DBDebugLog *log in queryResults)
                {
                    BHDebugLog *mLog = [BHDebugLog debugLogWithDBDebugLog:log];
                    mLog.test = bhTest;
                    mLog.testManagedObjectURI = bhTest.managedObjectURI;
                    [result addObject:mLog];
                }
                [result sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(result);
            });
        }];
    }
}

-(void)logDebug:(BHDebugLog*)bhLog forTest:(BHTest*)bhTest withCompleteBlock:(BHCoreDataManagerBOOLResponseBlock)completeBlock
{
    if(bhTest.managedObjectURI && bhLog)
    {
        [self addOperationToCDQueueWithWorkerBlock:^(NSManagedObjectModel *model, NSManagedObjectContext *currentContext, NSPersistentStoreCoordinator *persistentStoreCoordinator) {
            
            NSError *error = nil;
            DBTest *test = [bhTest DBTestWithPersistentStore:persistentStoreCoordinator andContext:currentContext];
            BOOL success = YES;
            if(test)
            {
                DBDebugLog *dbLog = [NSEntityDescription insertNewObjectForEntityForName:@"DebugLogs" inManagedObjectContext:currentContext];
                [test addDebugLogsObject:dbLog];
                dbLog.test = test;
                [bhLog saveToManagedObject:dbLog];
                
                success = [currentContext save:&error];
            }
            else
            {
                success &= NO;
            }
            
            if(completeBlock)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(success);
                });
            }
        }];
    }
}

#pragma mark - Errors
-(void)getAllErrorsForTest:(BHTest*)bhTest withCompleteBlock:(BHCoreDataManagerArrayResponseBlock)completeBlock
{
    if(completeBlock)
    {
        [self addOperationToCDQueueWithWorkerBlock:^(NSManagedObjectModel *model, NSManagedObjectContext *currentContext, NSPersistentStoreCoordinator *persistentStoreCoordinator) {
            
            NSError *error = nil;
            NSMutableArray *result = [NSMutableArray array];
            NSManagedObjectID *testID = [bhTest managedObjectIDWithPersistentStoreCoordinator:persistentStoreCoordinator];
            
            if(testID)
            {
                NSFetchRequest *logRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *logDescription = [NSEntityDescription entityForName:@"Errors" inManagedObjectContext:currentContext];
                [logRequest setEntity:logDescription];
                [logRequest setIncludesPendingChanges:YES];
                [logRequest setIncludesPropertyValues:YES];
                [logRequest setReturnsObjectsAsFaults:NO];
                NSPredicate *where = [NSPredicate predicateWithFormat:@"test == %@",testID];
                [logRequest setPredicate:where];
                [logRequest setFetchBatchSize:100];
                
                NSArray *queryResults = [currentContext executeFetchRequest:logRequest error:&error];
                [logRequest release];
                for(DBError *log in queryResults)
                {
                    BHError *mLog = [BHError errorWithDBError:log];
                    mLog.test = bhTest;
                    mLog.testManagedObjectURI = bhTest.managedObjectURI;
                    [result addObject:mLog];
                }
                [result sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(result);
            });
        }];
    }
}

-(void)logError:(BHError*)bhError forTest:(BHTest*)bhTest withCompleteBlock:(BHCoreDataManagerBOOLResponseBlock)completeBlock
{
    [self logErrors:@[bhError] forTest:bhTest withCompleteBlock:completeBlock];
}

-(void)logErrors:(NSArray*)bhErrors forTest:(BHTest*)bhTest withCompleteBlock:(BHCoreDataManagerBOOLResponseBlock)completeBlock
{
    if(bhTest.managedObjectURI && bhErrors.count>0)
    {
        [self addOperationToCDQueueWithWorkerBlock:^(NSManagedObjectModel *model, NSManagedObjectContext *currentContext, NSPersistentStoreCoordinator *persistentStoreCoordinator) {
            
            NSError *error = nil;
            DBTest *test = [bhTest DBTestWithPersistentStore:persistentStoreCoordinator andContext:currentContext];
            BOOL success = YES;
            if(test)
            {
                DBError *dbError = nil;
                BHError *bhError = nil;
                for(NSUInteger i = 0; i<bhErrors.count; i++)
                {
                    dbError = [NSEntityDescription insertNewObjectForEntityForName:@"Errors" inManagedObjectContext:currentContext];
                    [test addErrorsObject:dbError];
                    dbError.test = test;
                    
                    bhError = (BHError*)[bhErrors objectAtIndex:i];
                    [bhError saveToManagedObject:dbError];
                }
                
                success = [currentContext save:&error];
            }
            else
            {
                success &= NO;
            }
            
            if(completeBlock)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(success);
                });
            }
        }];
    }
}

#pragma mark - Tests
-(void)getLastTestWithCompleteBlock:(BHCoreDataManagerArrayResponseBlock)completeBlock
{
    if(completeBlock)
    {
        [self addOperationToCDQueueWithWorkerBlock:^(NSManagedObjectModel *model, NSManagedObjectContext *currentContext, NSPersistentStoreCoordinator *persistentStoreCoordinator) {
            
            NSError *error = nil;            
            NSFetchRequest *testRequest = [[NSFetchRequest alloc] init];
            BHTest *mTest = nil;
            NSEntityDescription *testDescription = [NSEntityDescription entityForName:@"Tests" inManagedObjectContext:currentContext];
            [testRequest setEntity:testDescription];
            [testRequest setIncludesPendingChanges:YES];
            [testRequest setIncludesPropertyValues:YES];
            [testRequest setReturnsObjectsAsFaults:NO];
            [testRequest setFetchLimit:1];
            NSPredicate *where = [NSPredicate predicateWithFormat:@"endDate == nil"];
            [testRequest setPredicate:where];
            
            NSArray *queryResults = [currentContext executeFetchRequest:testRequest error:&error];
            [testRequest release];
            DBTest *test = (DBTest*)[queryResults lastObject];
            if(test)
            {
                mTest = [BHTest testWithDBTest:test];
            }
            else
            {
                //create it
                test = [NSEntityDescription insertNewObjectForEntityForName:@"Tests" inManagedObjectContext:currentContext];
                test.startDate = [NSDate date];
                BOOL success = [currentContext save:&error];
                if(success)
                {
                    mTest = [BHTest testWithDBTest:test];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(mTest?@[mTest]:@[]);
            });
        }];
    }
}

-(void)getAllTestsWithCompleteBlock:(BHCoreDataManagerArrayResponseBlock)completeBlock includeAllPropertyData:(BOOL)includeAllPropertyData
{
    if(completeBlock)
    {
        [self addOperationToCDQueueWithWorkerBlock:^(NSManagedObjectModel *model, NSManagedObjectContext *currentContext, NSPersistentStoreCoordinator *persistentStoreCoordinator) {
            
            NSError *error = nil;
            NSMutableArray *result = [NSMutableArray array];
            
            NSFetchRequest *testRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *testDescription = [NSEntityDescription entityForName:@"Tests" inManagedObjectContext:currentContext];
            [testRequest setEntity:testDescription];
            [testRequest setIncludesPendingChanges:YES];
            [testRequest setIncludesPropertyValues:YES];
            [testRequest setReturnsObjectsAsFaults:NO];
            if(includeAllPropertyData)
            {
                [testRequest setRelationshipKeyPathsForPrefetching:@[@"errors",@"transfers",@"logs"]];
            }
            
            NSArray *queryResults = [currentContext executeFetchRequest:testRequest error:&error];
            [testRequest release];
            for(DBTest *test in queryResults)
            {
                BHTest *mTest = [BHTest testWithDBTest:test andIncludeAllPropertData:includeAllPropertyData];
                [result addObject:mTest];
            }
            [result sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(result);
            });
        }];
    }
}

-(void)createANewTestWithCompleteBlock:(BHCoreDataManagerArrayResponseBlock)completeBlock
{
    if(completeBlock)
    {
        [self addOperationToCDQueueWithWorkerBlock:^(NSManagedObjectModel *model, NSManagedObjectContext *currentContext, NSPersistentStoreCoordinator *persistentStoreCoordinator) {
            
            NSError *error = nil;
            NSMutableArray *result = [NSMutableArray array];
            
            //stop tests that don't have an end data
            NSFetchRequest *testRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *testDescription = [NSEntityDescription entityForName:@"Tests" inManagedObjectContext:currentContext];
            [testRequest setEntity:testDescription];
            [testRequest setIncludesPendingChanges:YES];
            [testRequest setIncludesPropertyValues:YES];
            [testRequest setReturnsObjectsAsFaults:NO];
            NSPredicate *where = [NSPredicate predicateWithFormat:@"endDate == nil"];
            [testRequest setPredicate:where];
            
            NSArray *queryResults = [currentContext executeFetchRequest:testRequest error:&error];
            [testRequest release];
            for(DBTest *test in queryResults)
            {
                test.endDate = [NSDate date];
            }
            
            //create the new test
            DBTest *mNewTest = [NSEntityDescription insertNewObjectForEntityForName:@"Tests" inManagedObjectContext:currentContext];
            mNewTest.startDate = [NSDate date];
            BOOL success = [currentContext save:&error];
            if(success)
            {
                BHTest *mTest = [BHTest testWithDBTest:mNewTest];//do this after the save so we get a valid managedObjectURI, and not the temp one
                [result addObject:mTest];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(result);
            });
        }];
    }
}
@end
