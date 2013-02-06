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

#pragma mark - BHCoreDataOperationWrapper
/**
 Wrapper... prevents having to rewrite te same code multiple times over
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
@end
