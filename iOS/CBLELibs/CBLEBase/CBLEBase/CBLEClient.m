//
//  CBLEClient.m
//  FloatingUUID
//
//  Created by Ryan Morton on 12/29/12.
//  Copyright (c) 2012 Ryan Morton. All rights reserved.
//

#import "CBLEClient.h"
#import "CBLENode_EXT.h"
#import "CBLEUtils.h"



@interface CBLEClient ()
{
    
}

@end



@implementation CBLEClient
+(NSString*)errorDomain
{
    return [NSString stringWithFormat:@"%@.%@",[[NSBundle mainBundle] bundleIdentifier],@"CBLEClient"];
}

-(void)internalInit
{
    self.isFinishing = NO;
    self.hasStarted = NO;
    _cbQueue = dispatch_queue_create([[NSString stringWithFormat:@"%@<%p>",@"CBLEClientQueue",self] cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
    //_cbQueue = dispatch_get_main_queue();
}

-(id)initWithServiceUUIDs:(NSArray*)serviceUUIDs andCharacteristicUUIDs:(NSArray*)characteristicUUIDs
{
    if(self = [super init])
    {
        [self internalInit];
        _serviceUUIDs = serviceUUIDs;
        _characteristicUUIDs = characteristicUUIDs;
    }
    return self;
}



#pragma mark - Start/Stop
-(void)cancel
{
    [self finish];
}

-(void)start
{
    if(!self.hasStarted)
    {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:_cbQueue];
    }
}

-(void)startScanning
{
    if(_serviceUUIDs.count>0 && _characteristicUUIDs.count>0)
    {
        self.hasStarted = YES;
        
        [_centralManager scanForPeripheralsWithServices:_serviceUUIDs options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        [CBLEUtils debugLog:@"Started scanning."];
    }
}

-(void)finish
{
    if(self.isFinishing){return;}
    self.isFinishing = YES;
    @try
    {
        if(_centralManager)
        {
            _centralManager.delegate = nil;
            [_centralManager stopScan];
        }
        _centralManager = nil;
    }
    @catch(NSException *ex)
    {
        [CBLEUtils debugLog:[CBLENode getDebugMessageForTarget:self methodName:nil andCustomErrorText:[NSString stringWithFormat:@"%@",ex]]];
    }
    
    _serviceUUIDs = nil;
    _characteristicUUIDs = nil;
    //dispatch_release(_cbQueue);//not needed when targeting iOS6+
    _cbQueue = NULL;
}

#pragma mark - CBCentralManagerDelegate Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
}

#pragma mark - CBPeripheralDelegate Methods
-(void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}
@end
