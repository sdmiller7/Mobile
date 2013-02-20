//
//  DBTest.h
//  CBLEBase
//
//  Created by Ryan Morton on 2/18/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBDebugLog, DBError, DBTransfer;

@interface DBTest : NSManagedObject

@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSSet *debugLogs;
@property (nonatomic, retain) NSSet *errors;
@property (nonatomic, retain) NSSet *transfers;
@end

@interface DBTest (CoreDataGeneratedAccessors)

- (void)addDebugLogsObject:(DBDebugLog *)value;
- (void)removeDebugLogsObject:(DBDebugLog *)value;
- (void)addDebugLogs:(NSSet *)values;
- (void)removeDebugLogs:(NSSet *)values;

- (void)addErrorsObject:(DBError *)value;
- (void)removeErrorsObject:(DBError *)value;
- (void)addErrors:(NSSet *)values;
- (void)removeErrors:(NSSet *)values;

- (void)addTransfersObject:(DBTransfer *)value;
- (void)removeTransfersObject:(DBTransfer *)value;
- (void)addTransfers:(NSSet *)values;
- (void)removeTransfers:(NSSet *)values;

@end
