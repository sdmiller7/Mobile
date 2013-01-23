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

#define kMIN_CONNECTION_MEMORY 60.0 //time in sec

@interface CBLEClient ()
<CBCentralManagerDelegate, CBPeripheralDelegate>
{
    dispatch_queue_t __strong _cbQueue;
    CBCentralManager * __strong _centralManager;
    NSMutableDictionary * __strong _serverHistory;
    CBPeripheral * __strong _currentPeripheral;
    
    NSArray * __strong _serviceUUIDs;
    NSMutableArray * __strong _serviceUUIDStrings;
    
    NSArray * __strong _characteristicUUIDs;
    NSMutableArray * __strong _characteristicUUIDStrings;
    
    NSMutableData * __strong _downloadCache;
}

-(void)internalInit;
-(void)cleanUpHistory;
-(void)finish;
-(void)startScanning;

@property (nonatomic, assign) BOOL isFinishing;
@property (nonatomic, assign) BOOL hasStarted;

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

-(void)cleanUpHistory
{
    if(_serverHistory)
    {
        NSTimeInterval deltaT = 0;
        NSArray *keys = [_serverHistory allKeys];
        NSDate *storedDate = nil;;
        NSMutableArray *keysToRemove = [NSMutableArray arrayWithCapacity:keys.count];
        for(NSUInteger i=0;i<keys.count;i++)
        {
            storedDate = [_serverHistory objectForKey:[keys objectAtIndex:i]];
            deltaT = [storedDate timeIntervalSinceNow];
            if(deltaT>kMIN_CONNECTION_MEMORY)
            {
                [keysToRemove addObject:[keys objectAtIndex:i]];
            }
        }
        
        [_serverHistory removeObjectsForKeys:keysToRemove];
    }
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
        
        _currentPeripheral = nil;
        
        _serviceUUIDStrings = [NSMutableArray arrayWithCapacity:_serviceUUIDs.count];
        for(CBUUID *uuid in _serviceUUIDs)
        {
            [_serviceUUIDStrings addObject:[uuid stringRepresentation]];
        }
        
        _characteristicUUIDStrings = [NSMutableArray arrayWithCapacity:_characteristicUUIDs.count];
        for(CBUUID *uuid in _characteristicUUIDs)
        {
            [_characteristicUUIDStrings addObject:[uuid stringRepresentation]];
        }
        
        [_centralManager scanForPeripheralsWithServices:_serviceUUIDs options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        [CBLEUtils debugLog:@"Started scanning."];
    }
}

-(void)finish
{
    if(self.isFinishing){return;}
    self.isFinishing = YES;
    dispatch_async(_cbQueue, ^{
        @try
        {
            if(_centralManager)
            {
                _centralManager.delegate = nil;
                [_centralManager stopScan];
            }
            _centralManager = nil;
            
            if(_currentPeripheral)
            {
                [_currentPeripheral setDelegate:nil];
                if (_currentPeripheral.services != nil)
                {
                    for (CBService *service in _currentPeripheral.services)
                    {
                        if (service.characteristics != nil)
                        {
                            for (CBCharacteristic *characteristic in service.characteristics)
                            {
                                [_currentPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            }
                        }
                    }
                }
                [_centralManager cancelPeripheralConnection:_currentPeripheral];
            }
        }
        @catch(NSException *ex)
        {
            [CBLEUtils debugLog:[CBLENode getDebugMessageForTarget:self methodName:nil andCustomErrorText:[NSString stringWithFormat:@"%@",ex]]];
        }
        
        _serverHistory = nil;
        _serviceUUIDs = nil;
        _characteristicUUIDs = nil;
        _serviceUUIDStrings = nil;
        _characteristicUUIDStrings = nil;
        _downloadCache = nil;
        //dispatch_release(_cbQueue);//not needed when targeting iOS6+
        _cbQueue = NULL;
    });
}

#pragma mark - CBCentralManagerDelegate Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch(central.state)
    {
        case CBCentralManagerStatePoweredOff:
        case CBCentralManagerStateResetting:
        case CBCentralManagerStateUnknown:
        {
            [self cancel];
            return;
            break;
        }
        case CBCentralManagerStateUnauthorized:
        {
            return;
            break;
        }
        case CBCentralManagerStateUnsupported:
        {
            return;
            break;
        }
        case CBCentralManagerStatePoweredOn:
        {
            break;
        }
        default:
        {
            return;
            break;
        }
    }
    
    [self startScanning];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if(!_currentPeripheral)
    {
        // Reject any where the value is above reasonable range
        if (RSSI.integerValue > -5)
        {
            return;
        }
        
        // Reject if the signal strength is too low to be close enough (Close is around -22dB)
        if (RSSI.integerValue < -60)
        {
            return;
        }
        
        [CBLEUtils debugLog:[NSString stringWithFormat:@"Discovered peripheral at %@", RSSI]];
        
        _currentPeripheral = peripheral;
        
        //connect
        [CBLEUtils debugLog:[NSString stringWithFormat:@"Connecting to peripheral <%p>", peripheral]];
        [_centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:[NSNumber numberWithBool:YES]}];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [CBLEUtils debugLog:[NSString stringWithFormat:@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]]];
    
    if(_currentPeripheral == peripheral)
    {
        _currentPeripheral = nil;
        
        [self startScanning];//needed??
    }
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected: <%p><name: %@><UUID: %@>",peripheral,peripheral.name, peripheral.UUID);
    
    [CBLEUtils debugLog:[NSString stringWithFormat:@"Peripheral Connected: <%p><name: %@><UUID: %@>",peripheral,peripheral.name, peripheral.UUID]];
    
    if(_currentPeripheral == peripheral)
    {
        _currentPeripheral.delegate = self;
        [_centralManager stopScan];
        
        // Search only for services that match our UUID
        [_currentPeripheral discoverServices:_serviceUUIDs];
        //[_currentPeripheral discoverServices:nil];
    }
    
    /*
     //IMPORTANT: we have to connect before we can ask the peripheral for its UUID
     if(peripheral.UUID)
     {
     //have we seen this before?
     CFStringRef stringUUID = CFUUIDCreateString(NULL, peripheral.UUID);
     NSString *peripheralUUID = [[(NSString*)stringUUID autorelease] lowercaseString];
     NSDate *lastConnected = [self.serverHistory objectForKey:peripheralUUID];
     if(lastConnected)
     {
     NSTimeInterval deltaT = [lastConnected timeIntervalSinceNow];//double sec
     if(deltaT<kMIN_CONNECTION_MEMORY)
     {
     peripheral.delegate = nil;
     [self.centralManager cancelPeripheralConnection:peripheral];
     
     int64_t delayInSeconds = 5.0;//make this the diff. between now and the time that the timer started
     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
     dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
     [self startScanning];
     });
     return;
     }
     }
     }
     */
    
    
}

#pragma mark - CBPeripheralDelegate Methods
-(void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral
{
    [self startScanning];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        [CBLEUtils debugLog:[NSString stringWithFormat:@"Error discovering services for peripheral: <%p> %@,\nlocalizedDescription: %@", peripheral, peripheral.name, [error localizedDescription]]];
        _currentPeripheral = nil;
        
        [self startScanning];
    }
    else
    {
        if(_currentPeripheral == peripheral)
        {
            //find what we want
            NSArray *services = _currentPeripheral.services;
            for (CBService *service in services)
            {
                [CBLEUtils debugLog:[NSString stringWithFormat:@"Peripheral<%@> has service: {uuid: %@, description: %@}",peripheral,service.UUID,service]];
                [peripheral discoverCharacteristics:_characteristicUUIDs forService:service];
            }
            
            if(services.count == 0)
            {
                [_centralManager cancelPeripheralConnection:peripheral];
                _currentPeripheral = nil;
                [self startScanning];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        [CBLEUtils debugLog:[NSString stringWithFormat:@"Error discovering characteristics for peripheral: <%p> %@,\nlocalizedDescription: %@",peripheral,peripheral.name, [error localizedDescription]]];
        
        _currentPeripheral = nil;
        
        [self startScanning];
    }
    else
    {
        if(_currentPeripheral == peripheral)
        {
            BOOL foundAnInterestingCharacteristic = NO;
            for (CBCharacteristic *characteristic in service.characteristics)
            {
                // And check if it's the right one
                NSString *characteristicUUIDString = [characteristic.UUID stringRepresentation];
                if ([_characteristicUUIDStrings containsObject:characteristicUUIDString])
                {
                    // If it is, subscribe to it
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    foundAnInterestingCharacteristic = YES;
                }
            }
            
            if(!foundAnInterestingCharacteristic)
            {
                [_centralManager cancelPeripheralConnection:peripheral];
                _currentPeripheral = nil;
                [self startScanning];
            }
            else
            {
                _downloadCache = nil;
                _downloadCache = [NSMutableData data];
            }
            
            /*
             if(!foundCharacteristic)
             {
             NSLog(@"Error discovering characteristics for peripheral: <%p> %@,\nDid not find characteristic match for UUID: %@",peripheral,peripheral.name,kFLOATINGUUID_CHARACTERISTIC_UUID);
             [self reset];
             }
             */
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error updating characteristic <%@> for peripheral <%p> %@,\nlocalizedDescription: %@",[characteristic.UUID stringRepresentation],peripheral,peripheral.name, [error localizedDescription]);
        [self startScanning];
    }
    else
    {
        if(_currentPeripheral == peripheral)
        {
            NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
            
            // Log it
            [CBLEUtils debugLog:[NSString stringWithFormat:@"Received: %@", (stringFromData?stringFromData:[NSString stringWithFormat:@"%lu bytes",(unsigned long)characteristic.value.length])]];
            
            if ([stringFromData isEqualToString:@"EOM"])
            {
                NSDictionary *payloadDictionary = nil;
                if(_downloadCache.length>0)
                {
                    @try
                    {
                        payloadDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:_downloadCache];
                        if(payloadDictionary)
                        {
                            NSString *uuidString = [payloadDictionary objectForKey:@"uuid"];
                            NSLog(@"PASSED!!!: %@",uuidString);
                        }
                        else
                        {
                            @throw [NSException exceptionWithName:@"Nil payloadDictionary" reason:@"Nil payloadDictionary" userInfo:@{NSLocalizedFailureReasonErrorKey:@"Nil payloadDictionary"}];
                        }
                    }
                    @catch(NSException *ex)
                    {
                        NSLog(@"Error updating characteristic <%@> for peripheral <%p> %@,\nNSException: %@",[characteristic.UUID stringRepresentation],peripheral,peripheral.name, ex);
                        //[self startScanning];
                    }
                }
                else
                {
                    NSLog(@"Error updating characteristic <%@> for peripheral <%p> %@,\ndownloadCache was empty",[characteristic.UUID stringRepresentation],peripheral,peripheral.name);
                }
                
                // Cancel our subscription to the characteristic
                [peripheral setNotifyValue:NO forCharacteristic:characteristic];
                
                CFStringRef stringUUID = CFUUIDCreateString(NULL, peripheral.UUID);
                NSString *peripheralUUID = [(NSString*)CFBridgingRelease(stringUUID) lowercaseString];
                if(peripheralUUID.length>0)
                {
                    [_serverHistory setObject:[NSDate date] forKey:peripheralUUID];
                }
                
                [self cleanUpHistory];
                [self startScanning];
            }
            else
            {
                // Otherwise, just add the data on to what we already have
                [_downloadCache appendData:characteristic.value];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    }
    
    // Notification has stopped
    else {
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [_centralManager cancelPeripheralConnection:peripheral];
        _currentPeripheral = nil;
        [self startScanning];
    }
}
@end
