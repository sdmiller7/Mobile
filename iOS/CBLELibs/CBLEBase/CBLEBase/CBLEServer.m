//
//  CBLEServer.m
//  FloatingUUID
//
//  Created by Ryan Morton on 12/29/12.
//  Copyright (c) 2012 Ryan Morton. All rights reserved.
//

#import "CBLEServer.h"
#import "CBLENode_EXT.h"
#import "CBLEUtils.h"

#define MAX_TRANS_ERROR_COUNT 5


@interface CBLEServer ()
{
    
}
@end

@implementation CBLEServer

+(NSString*)errorDomain
{
    return [NSString stringWithFormat:@"%@.%@",[[NSBundle mainBundle] bundleIdentifier],@"CBLEServer"];
}

-(void)dealloc
{
    [self finish];
    //[super dealloc];
}

#pragma mark - Init
-(id)initWithServices:(NSArray*)services
{
    if(self = [super init])
    {
        [self internalInit];
        self.services = services;
    }
    return self;
}

-(void)internalInit
{
    _isFinishing = NO;
    _hasStarted = NO;
    _cbQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@<%p>",@"CBLEServerQueue",self] cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
    //_cbQueue = dispatch_get_main_queue();
    _propsSema = dispatch_semaphore_create(1);
}

#pragma mark - Start/Stop
-(void)cancel
{
    if(_isFinishing){return;}
    dispatch_async(_cbQueue, ^{
        [self finish];
    });
}

-(void)start
{
    if(!_hasStarted)
    {
        _hasStarted = YES;
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:_cbQueue];
    }
}

-(void)finish
{
    if(!_isFinishing)
    {
        _isFinishing = YES;
        @try
        {
            if(_peripheralManager)
            {
                _peripheralManager.delegate = nil;
                [_peripheralManager stopAdvertising];
            }
            _peripheralManager = nil;
        }
        @catch(NSException *ex)
        {
            [CBLEUtils debugLog:[CBLENode getDebugMessageForTarget:self methodName:nil andCustomErrorText:[NSString stringWithFormat:@"%@",ex]]];
        }
        
        _propsSema = nil;
        _cbQueue = nil;
    }
}

#pragma mark - Other
-(void)continueSendingDataToClients
{
}

#pragma mark - CBPeripheralManagerDelegate Methods
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
}

-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
}

/*
-(void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    
}
*/



-(void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
}
@end
