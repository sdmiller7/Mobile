//
//  CBLEUUIDServer.m
//  CBLEUUIDTest
//
//  Created by Ryan Morton on 1/20/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "CBLEUUIDServer.h"
#import <CBLEBase/CBLEBase.h>
#import "CBLECharacteristicTransfer.h"
#import "CBLEUUIDTest.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

#define kCLMINHorizontalAccuracy 100//in meters

const unsigned short kCBLEUUIDServerVersion = 1;//16bits... 65535 versions


#pragma mark - CBLEUUIDInternalServer
@interface CBLEUUIDInternalServer : CBLEServer
<CLLocationManagerDelegate>
{
    __strong NSMutableArray * _pendingTransfers;
    __strong NSMutableArray * _transfersWaitingForLocation;
    __strong CLLocation * _currentLocation;
    __strong CLLocationManager * _locationManager;
}

@property (nonatomic, strong) NSString *deviceID;

-(BOOL)locationNeedsUpdating;
-(void)getNewLocation;
-(BOOL)canUseCoreLocation;
-(BOOL)updateWaitingTransfersWithLocation;

-(NSData*)getUUIDPayloadDataWithUUID:(NSString*)uuid;

-(void)applicationWillEnterBackground:(NSNotification*)note;
-(void)applicationDidEnterForeground:(NSNotification*)note;
@end

@implementation CBLEUUIDInternalServer
-(void)internalInit
{
    [super internalInit];
    _transfersWaitingForLocation = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
-(void)applicationWillEnterBackground:(NSNotification*)note
{
    
}
-(void)applicationDidEnterForeground:(NSNotification*)note
{
    
}
-(void)finish
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.deviceID = nil;
    _pendingTransfers = nil;
    _currentLocation = nil;
    [_locationManager setDelegate:nil];
    _locationManager = nil;
    _transfersWaitingForLocation = nil;
    [super finish];
}

-(NSData*)getUUIDPayloadDataWithUUID:(NSString*)uuid
{
    NSData *response = nil;
    if(uuid.length>0)
    {
        NSMutableDictionary *payloadDictionary = [NSMutableDictionary dictionary];
        [payloadDictionary setObject:uuid forKey:@"uuid"];
        if(_currentLocation)
        {
            NSTimeInterval deltaT = ABS([_currentLocation.timestamp timeIntervalSinceNow]);
            NSDictionary *locationDictionary = @{@"long":[NSNumber numberWithFloat:_currentLocation.coordinate.longitude],@"lat":[NSNumber numberWithFloat:_currentLocation.coordinate.latitude],@"alt":[NSNumber numberWithDouble:_currentLocation.altitude],@"hacc":[NSNumber numberWithDouble:_currentLocation.horizontalAccuracy],@"vacc":[NSNumber numberWithDouble:_currentLocation.verticalAccuracy],@"deltat":[NSNumber numberWithDouble:deltaT]};
            [payloadDictionary setObject:locationDictionary forKey:@"location"];
        }
        @try
        {
            response = [NSKeyedArchiver archivedDataWithRootObject:payloadDictionary];
        }
        @catch(NSException* ex)
        {
            [CBLEUtils debugLogWithFormat:@"CBLEInternalUUIServer(getUUIDPayloadData) Exception: %@",ex];
        }
    }
    return response;
}

#pragma mark - CLLoation

-(BOOL)canUseCoreLocation
{
    return [CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized;
}

-(BOOL)locationNeedsUpdating
{
    if(_currentLocation)
    {
        NSTimeInterval deltaT = ABS([_currentLocation.timestamp timeIntervalSinceNow]);
        if(deltaT<=(60*5))//last 5 min
        {
            if(_currentLocation.horizontalAccuracy>=0 && _currentLocation.horizontalAccuracy <= kCLMINHorizontalAccuracy)
            {
                return NO;
            }
        }
        else
        {
            if(!_locationManager)
            {
                _locationManager = [[CLLocationManager alloc] init];
            }
            _currentLocation = _locationManager.location;//last cached location
            deltaT = ABS([_currentLocation.timestamp timeIntervalSinceNow]);
            if(deltaT<=(60*5))//last 5 min
            {
                //ok, check accuracy
                if(_currentLocation.horizontalAccuracy>=0 && _currentLocation.horizontalAccuracy <= kCLMINHorizontalAccuracy)
                {
                    return NO;
                }
            }
        }
    }
    return YES;
}

-(void)getNewLocation
{
    if(!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
    }
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [_locationManager startUpdatingLocation];
}

-(BOOL)updateWaitingTransfersWithLocation
{
    BOOL transfersUpdated = NO;
    NSMutableArray *itemsToDelete = [NSMutableArray arrayWithCapacity:_transfersWaitingForLocation.count];
    NSData *payload = [self getUUIDPayloadDataWithUUID:[NSString UUID]];
    for(CBLECharacteristicTransfer *trans in _transfersWaitingForLocation)
    {
        trans.dataToSend = payload;
        [itemsToDelete addObject:trans];
        
        if(![trans didConnectionTimedOut])
        {
            [_pendingTransfers addObject:trans];
            transfersUpdated = YES;
        }
    }
    if(itemsToDelete.count >0)
    {
        [_transfersWaitingForLocation removeObjectsInArray:itemsToDelete];
    }
    return transfersUpdated;
}

#pragma mark - CLLocationManagerDelegateMethods
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch(status)
    {
        case kCLAuthorizationStatusAuthorized:
        {
            [_locationManager startUpdatingLocation];
            break;
        }
        default:
        {
            _locationManager.delegate = nil;
            [_locationManager stopUpdatingLocation];
            dispatch_async(_cbQueue, ^{
                if(_transfersWaitingForLocation.count>0)
                {
                    if([self updateWaitingTransfersWithLocation])
                    {
                        [self continueSendingDataToClients];
                    }
                }
            });
            break;
        }
    }
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [CBLEUtils debugLog:[NSString stringWithFormat:@"locationManager:didFailWithError: %@",error]];
    _locationManager.delegate = nil;
    [_locationManager stopUpdatingLocation];
    dispatch_async(_cbQueue, ^{
        if(_transfersWaitingForLocation.count>0)
        {
            if([self updateWaitingTransfersWithLocation])
            {
                [self continueSendingDataToClients];
            }
        }
    });
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //last one should the most recent
    CLLocation* location = [locations lastObject];
    _currentLocation = location;
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:_currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
    {
        //dispatched on the main queue... change it to the _cbQueue
        dispatch_async(_cbQueue, ^{
            for (CLPlacemark *placemark in placemarks)
            {
                //for later... righ no, debug
                //[placemark locality];
                //NSString *city = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressCityKey];
            }
            
            [CBLEUtils debugLog:[NSString stringWithFormat:@"locationManager:didUpdateLocations: latitude %+.6f, longitude %+.6f",location.coordinate.latitude,location.coordinate.longitude]];
            
            if(_transfersWaitingForLocation.count>0)
            {
                BOOL startSendingData = [self updateWaitingTransfersWithLocation];
                if(startSendingData)
                {
                    [self continueSendingDataToClients];
                }
            }
        });
    }];
    
    [_locationManager setDelegate:nil];
    [_locationManager stopUpdatingLocation];
}

#pragma mark - CBPeripheralManagerDelegate Methods
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if(!_isFinishing)
    {
        switch(peripheral.state)
        {
            case CBPeripheralManagerStatePoweredOff:
            {
                [_pendingTransfers removeAllObjects];
                [_transfersWaitingForLocation removeAllObjects];
                return;
                break;
            }
            case CBPeripheralManagerStateResetting:
            {
                [_pendingTransfers removeAllObjects];
                [_transfersWaitingForLocation removeAllObjects];
                return;
                break;
            }
            case CBPeripheralManagerStateUnauthorized:
            {
                [_pendingTransfers removeAllObjects];
                [_transfersWaitingForLocation removeAllObjects];
                return;
                break;
            }
            case CBPeripheralManagerStateUnknown:
            case CBPeripheralManagerStateUnsupported:
            {
                [_pendingTransfers removeAllObjects];
                [_transfersWaitingForLocation removeAllObjects];
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
                [_transfersWaitingForLocation removeAllObjects];
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
}

-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if(!_isFinishing)
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
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    if(!_isFinishing)
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
                trans.characteristic = (CBMutableCharacteristic*)characteristic;
                trans.central = central;
                
                if([characteristicUUIDString isEqual:kFLOATINGUUID_CHARACTERISTIC_UUID])
                {
                    if([self canUseCoreLocation])
                    {
                        if(![self locationNeedsUpdating])
                        {
                            trans.dataToSend = [self getUUIDPayloadDataWithUUID:[NSString UUID]];//random, for now;
                            [_pendingTransfers addObject:trans];
                            startSendingData = YES;
                        }
                        else
                        {
                            [_transfersWaitingForLocation addObject:trans];
                            [self getNewLocation];
                            //startSendingData = YES;
                        }
                    }
                    else
                    {
                        trans.dataToSend = [self getUUIDPayloadDataWithUUID:[NSString UUID]];//random, for now;
                        [_pendingTransfers addObject:trans];
                        startSendingData = YES;
                    }
                }
                else if([characteristicUUIDString isEqual:kDEVICEID_CHARACTERISTIC_UUID])
                {
                    NSDictionary *payloadDictionary = @{@"deviceid":_deviceID};
                    trans.dataToSend = [NSKeyedArchiver archivedDataWithRootObject:payloadDictionary];
                    [_pendingTransfers addObject:trans];
                    startSendingData = YES;
                }
                else
                {
                    //?? nothing should come here... for later...
                }
            }
        }
        if(startSendingData)
        {
            [self continueSendingDataToClients];
        }
        else
        {
            //TODO: cancel the connection?? timeout?? ... client should timout naturally?? <- need to add that logic to client
        }
    }
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    if(!_isFinishing)
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
        else
        {
            for(CBLECharacteristicTransfer *trans in _transfersWaitingForLocation)
            {
                if([trans.central isEqual:central])
                {
                    transferToRemove = trans;
                    break;
                }
            }
            if(transferToRemove)
            {
                [_transfersWaitingForLocation removeObject:transferToRemove];
            }
        }
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
    if(!_isFinishing)
    {
        [CBLEUtils debugLog:@"Ready to Update" logCaller:YES];
        [self continueSendingDataToClients];
    }
}
@end



#pragma mark - CBLEUUIDServer
@interface CBLEUUIDServer ()
{
    __strong CBLEUUIDInternalServer * _cbServer;
}
@property (nonatomic, strong) NSArray *services;
@property (nonatomic, strong) NSString *deviceID;
-(void)internalInit;
@end

@implementation CBLEUUIDServer
-(id)initServerWithDeviceID:(NSString*)deviceID
{
    self = [super init];
    if(self)
    {
        self.deviceID = deviceID;
        [self internalInit];
    }
    return self;
}

-(void)dealloc
{
    [self cancel];
}

-(void)internalInit
{
    CBMutableService *service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:kFLOATINGUUID_SERVICE_UUID] primary:YES];
    
    CBMutableCharacteristic *UUIDCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kFLOATINGUUID_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    CBMutableCharacteristic *deviceIDCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kFLOATINGUUID_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    NSData *versionData = [NSData dataWithBytes:&kCBLEUUIDServerVersion length:sizeof(kCBLEUUIDServerVersion)];
    CBMutableCharacteristic *versionCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kFLOATINGUUID_SERVICE_VERSION_UUID] properties:CBCharacteristicPropertyBroadcast value:versionData permissions:CBAttributePermissionsReadable];//should be ale to read this in 1 transmission... no need to register for notification changes, the client should just try to read this value and wait for the callback
    
    [service setCharacteristics:@[UUIDCharacteristic, deviceIDCharacteristic, versionCharacteristic]];
    self.services = @[service];
    _cbServer = [[CBLEUUIDInternalServer alloc] initWithServices:self.services];
    _cbServer.deviceID = self.deviceID;
}
-(void)start
{
    [_cbServer start];
}
-(void)cancel
{
    [_cbServer cancel];
}
@end
