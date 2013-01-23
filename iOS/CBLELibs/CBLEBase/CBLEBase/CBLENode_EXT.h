//
//  CBLENode_EXT.h
//  FloatingUUID
//
//  Created by Ryan Morton on 12/29/12.
//  Copyright (c) 2012 Ryan Morton. All rights reserved.
//

#import "CBLENode.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "NSString+CBLE.h"
#import "CBUUID+CBLE.h"
#import "NSObject+CBLEDebug.h"



@interface CBLENode ()
{
    
}

+(NSError*)errorWithCode:(NSUInteger)code userMessage:(NSString*)userMessage debugMessage:(NSString*)debugMessage andWarningLevel:(CBLEErrorWarningLevel)warningLevel;
+(NSError*)errorWithCode:(NSUInteger)code userMessage:(NSString*)userMessage andWarningLevel:(CBLEErrorWarningLevel)warningLevel;
+(NSError*)errorWithCode:(NSUInteger)code userMessage:(NSString*)userMessage andDebugMessage:(NSString*)debugMessage;
+(NSError*)errorWithCode:(NSUInteger)code andUserMessage:(NSString*)userMessage;
+(NSError*)errorWithCode:(NSUInteger)code andDebugMessage:(NSString*)debugMessage;

+(NSString*)getDebugMessageForTarget:(id)target methodName:(NSString*)methodName andCustomErrorText:(NSString*)errorText;

@end
