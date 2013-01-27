//
//  CBLECharacteristicTransfer.h
//  FloatingUUID
//
//  Created by Ryan Morton on 12/29/12.
//  Copyright (c) 2012 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define kCBLECharacteristicTransferTimeout 8.0 //in sec.

extern NSString * const kCBLECharacteristicTransferEOM;

@interface CBLECharacteristicTransfer : NSObject
{
    
}

@property (nonatomic, assign) NSUInteger byteOffset;
@property (nonatomic, strong) CBMutableCharacteristic *characteristic;
@property (nonatomic, strong) NSTimer *connectionTimer;

//Server-specific
@property (nonatomic, strong) NSData *dataToSend;
@property (nonatomic, assign) BOOL didSendEOM;
@property (nonatomic, strong) CBCentral *central;
@property (nonatomic, assign) NSUInteger errorCount;

//Client-specific
@property (nonatomic, strong) NSMutableData *receiveCache;
@property (nonatomic, strong) CBPeripheral *peripheral;

+(CBLECharacteristicTransfer*)transfer;

+(CBLECharacteristicTransfer*)transferWithCentral:(CBCentral*)central characteristic:(CBMutableCharacteristic*)characteristic andDataToSend:(NSData*)data;

+(CBLECharacteristicTransfer*)transferWithPeripheral:(CBPeripheral*)peripheral andCharacteristic:(CBMutableCharacteristic*)characteristic;

+(NSString*)getUUIDStringRepresentationForPeripheral:(CBPeripheral*)peripheral andCharacteristic:(CBCharacteristic*)characteristic;

+(NSString*)getUUIDStringRepresentationForCentral:(CBCentral*)central andCharacteristic:(CBCharacteristic*)characteristic;

/**
 Thread-safe
 */
-(BOOL)isFinishedSendingPayload;

/**
 Thread-safe
 */
-(BOOL)isFinishedReceivingPayload;

/**
 Thread-safe
 */
-(BOOL)didConnectionTimedOut;

/**
 Thread-safe
 */
-(void)stopConnectionTimer;

/**
 Thread-safe
 @return YES if receiveBuffer != nil and (receiveBuffer.length + data.length) < 16MB... NO otherwise
 */
-(BOOL)appendData:(NSData*)data;

/**
 Thread-safe
 @return YES if receiveBuffer != nil and (receiveBuffer.length + data.length) < 16MB... NO otherwise
 */
-(BOOL)appendData:(NSData *)data andFinish:(BOOL)isFinished;

/**
 Thread-safe
 @return a UUID that is either a concatenation of the peripheral.UUID and the characteristic.UUID or the central.UUID and the characteristic.UUID... nil if either self.central.UUID or self.peripheral.UUID if we cannot be represented as a string.
 */
-(NSString *)UUIDStringRepresentation;

@end
