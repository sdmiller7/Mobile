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

@property (nonatomic, strong) NSData *dataToSend;
@property (nonatomic, assign) NSUInteger byteOffset;
@property (nonatomic, strong) CBMutableCharacteristic *characteristic;
@property (nonatomic, assign) BOOL didSendEOM;
@property (nonatomic, assign) NSUInteger errorCount;
@property (nonatomic, strong) CBCentral *central;
@property (nonatomic, strong) NSTimer *connectionTimer;

+(CBLECharacteristicTransfer*)transfer;
+(CBLECharacteristicTransfer*)transferWithData:(NSData*)data;

-(BOOL)isFinishedSendingPayload;
-(BOOL)didConnectionTimedOut;
-(void)stopConnectionTimer;

@end
