//
//  CBLEChatServer.m
//  CBLEChat
//
//  Created by Ryan Morton on 1/20/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "CBLEChatServer.h"
#import <CBLEBase/CBLEBase.h>

#pragma mark - CBLEChatInternalServer
@interface CBLEChatInternalServer : CBLEServer
<CBPeripheralManagerDelegate>
{
    NSMutableArray * __strong _pendingTransfers;
    
}
@end
@implementation CBLEChatInternalServer
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch(peripheral.state)
    {
        case CBPeripheralManagerStatePoweredOff:
        {
            [_pendingTransfers removeAllObjects];
            return;
            break;
        }
        case CBPeripheralManagerStateResetting:
        {
            [_pendingTransfers removeAllObjects];
            return;
            break;
        }
        case CBPeripheralManagerStateUnauthorized:
        {
            [_pendingTransfers removeAllObjects];
            return;
            break;
        }
        case CBPeripheralManagerStateUnknown:
        case CBPeripheralManagerStateUnsupported:
        {
            [_pendingTransfers removeAllObjects];
            return;
            break;
        }
        case CBPeripheralManagerStatePoweredOn:
        {
            break;
        }
        default:
        {
            [_pendingTransfers removeAllObjects];
            return;
            break;
        }
    }
    
    if(![_peripheralManager isAdvertising])
    {
        [_peripheralManager removeAllServices];
        for(NSObject *o in self.services)
        {
            if([o isKindOfClass:[CBMutableService class]])
            {
                [_peripheralManager addService:(CBMutableService*)o];
            }
        }
        
        NSMutableArray *serviceUUIDs = [NSMutableArray arrayWithCapacity:self.services.count];
        for(NSObject *o in self.services)
        {
            if([o isKindOfClass:[CBMutableService class]])
            {
                [serviceUUIDs addObject:[(CBMutableService*)o UUID]];
            }
        }
        
        [_peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : serviceUUIDs }];
        
        [CBLEUtils debugLog:@"Will Start Advertising" logCaller:YES];
    }
}

-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if(error)
    {
        [CBLEUtils debugLog:[CBLENode getDebugMessageForTarget:self methodName:nil andCustomErrorText:[NSString stringWithFormat:@"%@",error]]];
    }
    else
    {
        [CBLEUtils debugLog:[NSString stringWithFormat:@"Started Advertising: %@",peripheral]];
    }
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSString *characteristicUUIDString = [characteristic.UUID stringRepresentation];
    NSString *centralUUIDString = [NSString CFUUIDToNSString:central.UUID];
    [CBLEUtils debugLog:[NSString stringWithFormat:@"Central <%p><%@> subscribed to characteristic: %@",central, centralUUIDString,characteristicUUIDString]];
    
    CBMutableService *currentService = nil;
    BOOL startSendingData = NO;
    for(NSObject *o in self.services)
    {
        if([o isKindOfClass:[CBMutableService class]])
        {
            currentService = (CBMutableService*)o;
            //TODO: later, call/sync with delegate and get the data for the characteristic.
            //side note, you could pass in a data object that conforms to a protocol that has, -(NSData)getDataForUUID:(CBUUID)uuid, -(void)setData:(NSData*)data forUUID:(CBUUID)uuid
            CBLECharacteristicTransfer *trans = [CBLECharacteristicTransfer transfer];
            trans.dataToSend = [NSKeyedArchiver archivedDataWithRootObject:@{@"uuid":[NSString UUID]}];//random, for now;
            trans.characteristic = (CBMutableCharacteristic*)characteristic;
            trans.central = central;
            [_pendingTransfers addObject:trans];
            startSendingData = YES;
        }
    }
    if(startSendingData)
    {
        [self continueSendingDataToClients];
    }
    else
    {
        //TODO: cancel the connection?? timeout??
    }
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    CBLECharacteristicTransfer *transferToRemove = nil;
    for(CBLECharacteristicTransfer *trans in _pendingTransfers)
    {
        if([trans.central isEqual:central])
        {
            transferToRemove = trans;
            break;
        }
    }
    if(transferToRemove)
    {
        [_pendingTransfers removeObject:transferToRemove];
    }
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
    [CBLEUtils debugLog:@"Ready to Update" logCaller:YES];
    [self continueSendingDataToClients];
}
@end

#pragma mark - CBLEChatServer
@implementation CBLEChatServer

@end
