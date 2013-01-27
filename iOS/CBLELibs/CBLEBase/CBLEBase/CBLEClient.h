//
//  CBLEClient.h
//  FloatingUUID
//
//  Created by Ryan Morton on 12/29/12.
//  Copyright (c) 2012 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBLENode.h"
#import <CoreBluetooth/CoreBluetooth.h>

typedef enum{
    kCBLEClientErrorCode_Unknown = 0
}CBLEClientCode;

@interface CBLEClient : CBLENode
<CBCentralManagerDelegate, CBPeripheralDelegate>
{
    @public
    dispatch_queue_t __strong _cbQueue;
    CBCentralManager * __strong _centralManager;
    NSArray * __strong _serviceUUIDs;
    NSArray * __strong _characteristicUUIDs;
}

@property (nonatomic, assign) BOOL isFinishing;
@property (nonatomic, assign) BOOL hasStarted;

/**
 @param serviceUUIDs NSArray<CBUUID>
 @param characteristicUUIDs NSArray<CBUUID>
 */
-(id)initWithServiceUUIDs:(NSArray*)serviceUUIDs andCharacteristicUUIDs:(NSArray*)characteristicUUIDs;

-(void)internalInit;
-(void)finish;
-(void)startScanning;

-(void)cancel;
-(void)start;
@end
