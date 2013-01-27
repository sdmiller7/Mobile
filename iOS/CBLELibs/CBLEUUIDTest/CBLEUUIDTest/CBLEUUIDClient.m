//
//  CBLEUUIDClient.m
//  CBLEUUIDTest
//
//  Created by Ryan Morton on 1/26/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "CBLEUUIDClient.h"
#import <CBLEBase/CBLEBase.h>
#import "CBLEUUIDTest.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "CBLECharacteristicTransfer.h"

#define kMIN_CONNECTION_MEMORY 60.0 //time in sec


const unsigned short kCBLEUUIDClientVersion = 1;

#pragma mark - CBLEUUIDInternalClient
@interface CBLEUUIDInternalClient : CBLEClient
{
    NSMutableDictionary * __strong _serverHistory;
    NSMutableDictionary * __strong _currentTransfers;
    NSMutableDictionary * __strong _peripheralConnections;
    
    __strong CLLocationManager * _locationManager;//when do we use this? when communicating with the server?
    __strong CLLocation * _currentLocation;//when do we use this? when communicating with the server?
}
@property (nonatomic, strong) NSString *deviceID;//when do we use this? when communicating with the server?
-(void)cleanUpHistory;
@end

@implementation CBLEUUIDInternalClient

-(void)dealloc
{
    
}

-(void)finish
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.deviceID = nil;
    _currentLocation = nil;
    [_locationManager setDelegate:nil];
    _locationManager = nil;
    
    for(CBLECharacteristicTransfer *trans in _currentTransfers)
    {
        if(trans.peripheral)
        {
            trans.peripheral.delegate = nil;
            if(trans.characteristic)
            {
                [trans.peripheral setNotifyValue:NO forCharacteristic:trans.characteristic];
            }
        }
    }
    for(CBPeripheral *peripheral in _peripheralConnections)
    {
        peripheral.delegate = nil;
        [_centralManager cancelPeripheralConnection:peripheral];
    }
    _currentTransfers = nil;
    _peripheralConnections = nil;
    [super finish];
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

#pragma mark -- CBCentralManagerDelegate Methods
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
    [CBLEUtils debugLogWithFormat:@"Discovered peripheral at %@", RSSI];
    
    // Reject any where the value is above reasonable range
    if (RSSI.integerValue > -5)//TODO: play with this
    {
        return;
    }
    
    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
    if (RSSI.integerValue < -60)//TODO: play with this
    {
        return;
    }
    
    //look to see if the peripheral.UUID is resolved (from a previous connection)... if it is, check the last connection date
    NSString *peripheralUUIDStringRep = [NSString CFUUIDToNSString:peripheral.UUID];
    if(peripheralUUIDStringRep.length>0)
    {
        NSDate *lastConnected = [_serverHistory objectForKey:peripheralUUIDStringRep];//TODO: use the deviceID instead...
        NSTimeInterval deltaT = ABS([lastConnected timeIntervalSinceNow]);
        if(lastConnected && deltaT<= kMIN_CONNECTION_MEMORY)
        {
            //we've seen this peripheral in the past kMIN_CONNECTION_MEMORY, don't connect
            [CBLEUtils debugLogWithFormat:@"CentralManager<%p><didDiscoverPeripheral> connected to this peripheral<%p> %d second(s) ago. We won't allow another re-connect for anthoer %d second(s).",central,peripheral,deltaT,ABS(deltaT-kMIN_CONNECTION_MEMORY)];
            [self cleanUpHistory];
            return;
        }
    }
    
    //connect
    [CBLEUtils debugLog:[NSString stringWithFormat:@"Connecting to peripheral <%p>", peripheral]];
    [_centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:[NSNumber numberWithBool:YES]}];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [CBLEUtils debugLog:[NSString stringWithFormat:@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]]];
    
    //[self startScanning];//needed??
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSString *peripheralUUIDStringRep = [NSString CFUUIDToNSString:peripheral.UUID];
    [CBLEUtils debugLogWithFormat:@"Peripheral Connected: <%p><name: %@><UUID: %@>",peripheral,peripheral.name, peripheralUUIDStringRep];
    
    if(peripheralUUIDStringRep.length>0)
    {
        NSDate *lastConnected = [_serverHistory objectForKey:peripheralUUIDStringRep];//TODO: use the deviceID instead...
        NSTimeInterval deltaT = ABS([lastConnected timeIntervalSinceNow]);
        if(lastConnected && deltaT<= kMIN_CONNECTION_MEMORY)
        {
            //we've seen this peripheral in the past kMIN_CONNECTION_MEMORY, disconnect from it
            [CBLEUtils debugLogWithFormat:@"CentralManager<%p><didDiscoverPeripheral> connected to this peripheral<%p> %d second(s) ago. We won't allow another re-connect for anthoer %d second(s).",central,peripheral,deltaT,ABS(deltaT-kMIN_CONNECTION_MEMORY)];
            [_centralManager cancelPeripheralConnection:peripheral];
            [self cleanUpHistory];
            return;
        }
    }
    
    peripheral.delegate = self;
    [peripheral discoverServices:_serviceUUIDs];//limit the search to what we're interested in
    //[peripheral discoverServices:nil];//get them all
    
    if(peripheralUUIDStringRep.length>0)
    {
        [_peripheralConnections setObject:peripheral forKey:peripheralUUIDStringRep];
    }
}

#pragma mark -- CBPeripheralDelegate Methods
-(void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral
{
    //[self startScanning];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        [CBLEUtils debugLog:[NSString stringWithFormat:@"Error discovering services for peripheral: <%p> %@,\nlocalizedDescription: %@", peripheral, peripheral.name, [error localizedDescription]]];
        
        //[self startScanning];
    }
    else
    {
        NSString *peripheralUUIDStringRep = [NSString CFUUIDToNSString:peripheral.UUID];
        if(peripheralUUIDStringRep.length>0 && ![_peripheralConnections objectForKey:peripheralUUIDStringRep])
        {
            [_peripheralConnections setObject:peripheral forKey:peripheralUUIDStringRep];
        }
        
        //find what we want
        NSArray *services = peripheral.services;
        BOOL foundInterestingService = NO;
        for (CBService *service in services)
        {
            [CBLEUtils debugLog:[NSString stringWithFormat:@"Peripheral<%@> has service: {uuid: %@, description: %@}",peripheral,service.UUID,service]];
            
            if([_serviceUUIDs containsObject:service.UUID])
            {
                [peripheral discoverCharacteristics:_characteristicUUIDs forService:service];
                foundInterestingService = YES;
            }
        }
        
        if(!foundInterestingService)
        {
            peripheral.delegate = nil;
            [_centralManager cancelPeripheralConnection:peripheral];
            if(peripheralUUIDStringRep.length>0)
            {
                [_peripheralConnections removeObjectForKey:peripheralUUIDStringRep];
            }
            //[self startScanning];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        [CBLEUtils debugLog:[NSString stringWithFormat:@"Error discovering characteristics for peripheral: <%p> %@,\nlocalizedDescription: %@",peripheral,peripheral.name, [error localizedDescription]]];
        //[self startScanning];
    }
    else
    {
        BOOL foundAnInterestingCharacteristic = NO;
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            // And check if it's the right one
            if ([_characteristicUUIDs containsObject:characteristic.UUID])
            {
                if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kFLOATINGUUID_CHARACTERISTIC_VERSION_UUID]])
                {
                    //try to read it directly... no need to wait for server to update value
                    //the version number should transfer in one send window
                    [peripheral readValueForCharacteristic:characteristic];
                    foundAnInterestingCharacteristic = YES;
                }
            }
        }
        
        /*
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            // And check if it's the right one
            if ([_characteristicUUIDs containsObject:characteristic.UUID])
            {
                if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kFLOATINGUUID_CHARACTERISTIC_VERSION_UUID]])
                {
                    //try to read it directly... no need to wait for server to update value
                    //the version number should transfer in one send window
                    [peripheral readValueForCharacteristic:characteristic];
                    foundAnInterestingCharacteristic = YES;
                }
                else
                {
                    CBLECharacteristicTransfer *trans = [CBLECharacteristicTransfer transferWithPeripheral:peripheral andCharacteristic:(CBMutableCharacteristic*)characteristic];
                    NSString *transKey = [trans UUIDStringRepresentation];
                    
                    if(transKey.length>0)
                    {
                        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                        foundAnInterestingCharacteristic = YES;
                        [_currentTransfers setObject:trans forKey:transKey];
                    }
                    else
                    {
                        [CBLEUtils debugLogWithFormat:@"Cannot create transfer: characteristic or peripheral UUID cannot be represented as a string. CharacteristicUUID: <%@>, PeripheralUUID: <%@>",[characteristic.UUID stringRepresentation],[NSString CFUUIDToNSString:peripheral.UUID]];
                        
                        peripheral.delegate = nil;
                        [_centralManager cancelPeripheralConnection:peripheral];
                        NSString *peripheralUUIDStringRep = [NSString CFUUIDToNSString:peripheral.UUID];
                        if(peripheralUUIDStringRep.length>0)
                        {
                            [_peripheralConnections removeObjectForKey:peripheralUUIDStringRep];
                        }
                    }
                }              
            }
        }
        */
        
        if(!foundAnInterestingCharacteristic)
        {
            [_centralManager cancelPeripheralConnection:peripheral];
            NSString *peripheralUUIDStringRep = [NSString CFUUIDToNSString:peripheral.UUID];
            [_peripheralConnections removeObjectForKey:peripheralUUIDStringRep];
            [self cleanUpHistory];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error updating characteristic <%@> for peripheral <%p> %@,\nlocalizedDescription: %@",[characteristic.UUID stringRepresentation],peripheral,peripheral.name, [error localizedDescription]);
        //[self startScanning];
    }
    else
    {
        NSString *peripheralUUIDStringRep = [NSString CFUUIDToNSString:peripheral.UUID];
        BOOL disconnect = NO;
        
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kFLOATINGUUID_CHARACTERISTIC_UUID]])
        {
            NSString *transKey = [CBLECharacteristicTransfer getUUIDStringRepresentationForPeripheral:peripheral andCharacteristic:characteristic];
            CBLECharacteristicTransfer *trans = [_currentTransfers objectForKey:transKey];
            
            if(trans)
            {
                NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
                
                // Log it
                [CBLEUtils debugLogWithFormat:@"Received: %@", (stringFromData?stringFromData:[NSString stringWithFormat:@"%lu bytes",(unsigned long)characteristic.value.length])];
                
                if(![trans didConnectionTimedOut])
                {
                    if ([stringFromData isEqualToString:@"EOM"])
                    {
                        [trans appendData:nil andFinish:YES];
                        NSDictionary *payloadDictionary = nil;
                        if(trans.receiveCache.length>0)
                        {
                            @try
                            {
                                payloadDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:trans.receiveCache];
                                if(payloadDictionary)
                                {
                                    NSString *uuidString = [payloadDictionary objectForKey:@"uuid"];
                                    [CBLEUtils debugLogWithFormat:@"<PASSED!!!> UUID: %@, location:%@",uuidString,[payloadDictionary objectForKey:@"location"]];
                                }
                                else
                                {
                                    @throw [NSException exceptionWithName:@"Nil payloadDictionary" reason:@"Nil payloadDictionary" userInfo:@{NSLocalizedFailureReasonErrorKey:@"Nil payloadDictionary"}];
                                }
                            }
                            @catch(NSException *ex)
                            {
                                [CBLEUtils debugLogWithFormat:@"Error updating characteristic <%@> for peripheral <%p> %@,\nNSException: %@",[characteristic.UUID stringRepresentation],peripheral,peripheral.name, ex];
                                //[self startScanning];
                            }
                        }
                        else
                        {
                            [CBLEUtils debugLogWithFormat:@"Error updating characteristic <%@> for peripheral <%p> %@,\ndownloadCache was empty",[characteristic.UUID stringRepresentation],peripheral,peripheral.name];
                        }
                        [_currentTransfers removeObjectForKey:transKey];
                        disconnect = YES;
                        //[self startScanning];
                    }
                    else
                    {
                        // Otherwise, just add the data on to what we already have
                        BOOL success = [trans appendData:characteristic.value];
                        if(!success)
                        {
                            [_currentTransfers removeObjectForKey:transKey];
                            disconnect = YES;
                        }
                    }
                }
                else
                {
                    [CBLEUtils debugLogWithFormat:@"Conenction to peripheral<%p> %@ characteristic with UUID: %@ timed out",peripheral,peripheral.name,[characteristic.UUID stringRepresentation]];
                    [_currentTransfers removeObjectForKey:transKey];
                    disconnect = YES;
                }
            }
            else
            {
                [CBLEUtils debugLogWithFormat:@"Cannot find transfer: CharacteristicUUID: <%@>, PeripheralUUID: <%@>",[characteristic.UUID stringRepresentation],[NSString CFUUIDToNSString:peripheral.UUID]];
                disconnect = YES;
            }
        }
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kFLOATINGUUID_CHARACTERISTIC_VERSION_UUID]])
        {
            NSData *versiondata = characteristic.value;
            unsigned short serverVersion = 0;
            if(versiondata.length == sizeof(serverVersion))
            {
                [versiondata getBytes:&serverVersion length:sizeof(serverVersion)];
            }
            [CBLEUtils debugLogWithFormat:@"Connected to server<%p> with version: %i",serverVersion];
            
            BOOL foundAnInterestingCharacteristic = NO;
            for(CBService *service in peripheral.services)
            {
                if([_serviceUUIDs containsObject:service.UUID])
                {
                    for (CBCharacteristic *characteristic in service.characteristics)
                    {
                        // And check if it's the right one
                        if ([_characteristicUUIDs containsObject:characteristic.UUID])
                        {
                            //here is where we'd probably want to use the version # to determine what we can download
                            if(![characteristic.UUID isEqual:[CBUUID UUIDWithString:kFLOATINGUUID_CHARACTERISTIC_VERSION_UUID]])
                            {
                                CBLECharacteristicTransfer *trans = [CBLECharacteristicTransfer transferWithPeripheral:peripheral andCharacteristic:(CBMutableCharacteristic*)characteristic];
                                NSString *transKey = [trans UUIDStringRepresentation];
                                
                                if(transKey.length>0)
                                {
                                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                                    foundAnInterestingCharacteristic = YES;
                                    [_currentTransfers setObject:trans forKey:transKey];
                                }
                            }             
                        }
                    }
                }
            }
        }
        else
        {
            //nada, error?... for the future
        }
        
        if(disconnect)
        {
            [peripheral setNotifyValue:NO forCharacteristic:characteristic];
            [_centralManager cancelPeripheralConnection:peripheral];
            [_peripheralConnections removeObjectForKey:peripheralUUIDStringRep];
            if(peripheralUUIDStringRep.length>0)
            {
                [_serverHistory setObject:[NSDate date] forKey:peripheralUUIDStringRep];
            }
            [self cleanUpHistory];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (characteristic.isNotifying)
    {
        [CBLEUtils debugLogWithFormat:@"Notification began on %@", characteristic];
    }
    else
    {
        [CBLEUtils debugLogWithFormat:@"Notification stopped on %@", characteristic];
    }
}

@end



#pragma mark - CBLEUUIDClient
@interface CBLEUUIDClient ()
{
    CBLEUUIDInternalClient __strong * _cbClient;
}

@property (nonatomic, strong) NSString *deviceID;

-(void)internalInit;
@end

@implementation CBLEUUIDClient
-(void)dealloc
{
    
}

-(id)initServerWithDeviceID:(NSString*)deviceID
{
    if(self = [super init])
    {
        self.deviceID = deviceID;
        [self internalInit];
    }
    return self;
}

-(void)internalInit
{  
    _cbClient = [[CBLEUUIDInternalClient alloc] initWithServiceUUIDs:@[[CBUUID UUIDWithString:kFLOATINGUUID_SERVICE_UUID]] andCharacteristicUUIDs:@[[CBUUID UUIDWithString:kFLOATINGUUID_CHARACTERISTIC_VERSION_UUID],[CBUUID UUIDWithString:kFLOATINGUUID_CHARACTERISTIC_UUID]]];
    _cbClient.deviceID = self.deviceID;
}


-(void)start
{
    [_cbClient start];
}


-(void)cancel
{
    [_cbClient cancel];
}
@end
