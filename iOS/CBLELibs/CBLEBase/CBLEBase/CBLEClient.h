//
//  CBLEClient.h
//  FloatingUUID
//
//  Created by Ryan Morton on 12/29/12.
//  Copyright (c) 2012 Ryan Morton. All rights reserved.
//

#import "CBLENode.h"

typedef enum{
    kCBLEClientErrorCode_Unknown = 0
}CBLEClientCode;

@interface CBLEClient : CBLENode
{
    
}

/**
 @param serviceUUIDs NSArray<CBUUID>
 @param characteristicUUIDs NSArray<CBUUID>
 */
-(id)initWithServiceUUIDs:(NSArray*)serviceUUIDs andCharacteristicUUIDs:(NSArray*)characteristicUUIDs;

-(void)cancel;
-(void)start;
@end
