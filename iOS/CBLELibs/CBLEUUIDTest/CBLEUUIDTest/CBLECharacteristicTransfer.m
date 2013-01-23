//
//  CBLECharacteristicTransfer.m
//  FloatingUUID
//
//  Created by Ryan Morton on 12/29/12.
//  Copyright (c) 2012 Ryan Morton. All rights reserved.
//

#import "CBLECharacteristicTransfer.h"

NSString * const kCBLECharacteristicTransferEOM = @"EOM";

@interface CBLECharacteristicTransfer ()
{
    BOOL _connectionHasTimedOut;
    __block __strong dispatch_semaphore_t _propsSema;
}
-(void)setConnectionTimedOut:(BOOL)connectionTimedOut;
-(void)cancelTimer;
-(void)connectionTimerDidFire:(NSTimer*)connectionTimer;

@end

@implementation CBLECharacteristicTransfer

+(CBLECharacteristicTransfer*)transfer
{
    return [CBLECharacteristicTransfer transferWithData:nil];
}

+(CBLECharacteristicTransfer*)transferWithData:(NSData*)data
{
    CBLECharacteristicTransfer *result = [[CBLECharacteristicTransfer alloc] init];
    result.dataToSend = data;
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
    return self.byteOffset >= (self.dataToSend.length-1);
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

@end
