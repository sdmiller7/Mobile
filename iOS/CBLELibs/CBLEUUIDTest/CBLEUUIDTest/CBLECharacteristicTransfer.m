//
//  CBLECharacteristicTransfer.m
//  FloatingUUID
//
//  Created by Ryan Morton on 12/29/12.
//  Copyright (c) 2012 Ryan Morton. All rights reserved.
//

#import "CBLECharacteristicTransfer.h"

#import <CBLEBase/NSString+CBLE.h>
#import <CBLEBase/CBUUID+CBLE.h>

#define kCBLECharacteristicTransferMAXReceiveSize 16777216L //16MB MAX cache

NSString * const kCBLECharacteristicTransferEOM = @"EOM";

@interface CBLECharacteristicTransfer ()
{
    BOOL _connectionHasTimedOut;
    BOOL _isFinishedReceivingData;
    __block __strong dispatch_semaphore_t _propsSema;
}
-(void)setConnectionTimedOut:(BOOL)connectionTimedOut;
-(void)cancelTimer;
-(void)connectionTimerDidFire:(NSTimer*)connectionTimer;

@end

@implementation CBLECharacteristicTransfer

+(CBLECharacteristicTransfer*)transfer
{
    return [[CBLECharacteristicTransfer alloc] init];
}

+(CBLECharacteristicTransfer*)transferWithCentral:(CBCentral*)central characteristic:(CBMutableCharacteristic*)characteristic andDataToSend:(NSData*)data
{
    CBLECharacteristicTransfer *result = [[CBLECharacteristicTransfer alloc] init];
    result.dataToSend = data;
    result.central = central;
    result.characteristic = characteristic;
    return result;
}

+(CBLECharacteristicTransfer*)transferWithPeripheral:(CBPeripheral*)peripheral andCharacteristic:(CBMutableCharacteristic*)characteristic
{
    CBLECharacteristicTransfer *result = [[CBLECharacteristicTransfer alloc] init];
    result.receiveCache = [NSMutableData data];
    result.peripheral = peripheral;
    result.characteristic = characteristic;
    return result;
}

+(NSString*)getUUIDStringRepresentationForPeripheral:(CBPeripheral*)peripheral andCharacteristic:(CBCharacteristic*)characteristic
{
    NSString *result = nil;
    NSString *peripheralUUIDStringRep = [NSString CFUUIDToNSString:peripheral.UUID];
    NSString *characteristicUUIDStringRep = [characteristic.UUID stringRepresentation];
    
    if(characteristicUUIDStringRep.length>0 && peripheralUUIDStringRep.length>0)
    {
        result = [NSString stringWithFormat:@"%@-%@", peripheralUUIDStringRep,characteristicUUIDStringRep];
    }
    return result;
}

+(NSString*)getUUIDStringRepresentationForCentral:(CBCentral*)central andCharacteristic:(CBCharacteristic*)characteristic
{
    NSString *result = nil;
    NSString *centralUUIDStringRep = [NSString CFUUIDToNSString:central.UUID];
    NSString *characteristicUUIDStringRep = [characteristic.UUID stringRepresentation];
    
    if(characteristicUUIDStringRep.length>0 && centralUUIDStringRep.length>0)
    {
        result = [NSString stringWithFormat:@"%@-%@",centralUUIDStringRep,characteristicUUIDStringRep];
    }
    return result;
}

-(void)dealloc
{
    [self cancelTimer];
    //[super dealloc];
}

-(id)init
{
    self = [super init];
    if(self)
    {
        self.byteOffset = 0L;
        self.errorCount = 0L;
        _isFinishedReceivingData = NO;
        _propsSema = dispatch_semaphore_create(1);
        void(^createTimer)(void) = ^{
            _connectionTimer = [NSTimer timerWithTimeInterval:kCBLECharacteristicTransferTimeout target:self selector:@selector(connectionTimerDidFire:) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:_connectionTimer forMode:NSRunLoopCommonModes];
        };
        if([NSThread isMainThread])
        {
            createTimer();
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), createTimer);
        }
        
    }
    return self;
}

-(void)cancelTimer
{
    void(^stopTimer)(void) = ^{
        [_connectionTimer invalidate];
        _connectionTimer = nil;
    };
    if([NSThread isMainThread])
    {
        stopTimer();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), stopTimer);
    }
}

-(void)connectionTimerDidFire:(NSTimer*)connectionTimer
{
    [self cancelTimer];
    [self setConnectionTimedOut:YES];
}

-(BOOL)isFinishedSendingPayload
{
    dispatch_semaphore_wait(_propsSema, DISPATCH_TIME_FOREVER);
    return self.byteOffset >= (self.dataToSend.length-1);
    dispatch_semaphore_signal(_propsSema);
}

-(BOOL)isFinishedReceivingPayload
{
    dispatch_semaphore_wait(_propsSema, DISPATCH_TIME_FOREVER);
    return _isFinishedReceivingData;
    dispatch_semaphore_signal(_propsSema);
}

-(void)setConnectionTimedOut:(BOOL)connectionTimedOut
{
    dispatch_semaphore_wait(_propsSema, DISPATCH_TIME_FOREVER);
    _connectionHasTimedOut = connectionTimedOut;
    dispatch_semaphore_signal(_propsSema);
}

-(BOOL)didConnectionTimedOut
{
    dispatch_semaphore_wait(_propsSema, DISPATCH_TIME_FOREVER);
    BOOL result = _connectionHasTimedOut;
    dispatch_semaphore_signal(_propsSema);
    return result;
}

-(void)stopConnectionTimer
{
    [self cancelTimer];
}

-(BOOL)appendData:(NSData*)data
{
    return [self appendData:data andFinish:NO];
}

-(BOOL)appendData:(NSData *)data andFinish:(BOOL)isFinished
{
    //limit the receive buffer, just in case someone tries to flood
    BOOL success = NO;
    dispatch_semaphore_wait(_propsSema, DISPATCH_TIME_FOREVER);
    if(self.receiveCache)
    {
        if((self.receiveCache.length + data.length) < kCBLECharacteristicTransferMAXReceiveSize)
        {
            if(data.length>0)
            {
                [self.receiveCache appendData:data];
            }
        }
        else{success = NO;}
    }
    else{success= NO;}
    if(success && isFinished)
    {
        _isFinishedReceivingData = YES;
    }
    dispatch_semaphore_signal(_propsSema);
    return success;
}

-(NSString*)UUIDStringRepresentation
{
    
    dispatch_semaphore_wait(_propsSema, DISPATCH_TIME_FOREVER);
    NSString *result = [CBLECharacteristicTransfer getUUIDStringRepresentationForPeripheral:self.peripheral andCharacteristic:self.characteristic];
    if(result.length == 0)
    {
        result = [CBLECharacteristicTransfer getUUIDStringRepresentationForCentral:self.central andCharacteristic:self.characteristic];
    }
    dispatch_semaphore_signal(_propsSema);
    return result;
}

@end
