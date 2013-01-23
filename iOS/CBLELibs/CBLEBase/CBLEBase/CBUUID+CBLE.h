//
//  CBUUID+CBLE.h
//  FloatingUUID
//
//  Created by Ryan Morton on 12/12/12.
//  Copyright (c) 2012 Ryan Morton. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBUUID (CBLE)
-(NSString*)stringRepresentation;
-(NSString*)stringRepresentationWithCase:(BOOL)upperCase;
@end
