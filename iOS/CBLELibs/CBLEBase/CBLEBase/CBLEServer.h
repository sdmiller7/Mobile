//
//  CBLEServer.h
//  FloatingUUID
//
//  Created by Ryan Morton on 12/29/12.
//  Copyright (c) 2012 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBLENode.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define kCBLEServerMaxMTU 20//size in bytes

typedef enum{
    kCBLEServerErrorCode_Unknown = 0
}CBLEServerErrorCode;



@interface CBLEServer : CBLENode
<CBPeripheralManagerDelegate>
{
    @public
    dispatch_queue_t __strong _cbQueue;
    dispatch_semaphore_t __strong _propsSema;
    CBPeripheralManager * __strong _peripheralManager;
    
    __block BOOL _isFinishing;
    __block BOOL _hasStarted;
}
-(void)finish;
-(void)internalInit;
-(void)continueSendingDataToClients;

/**
 NSArray<CBMutableService>
 */
@property (nonatomic, strong) NSArray *services;

/**
 NSArray<CBMutableService>
 */
-(id)initWithServices:(NSArray*)services;

-(void)start;
-(void)cancel;
@end
