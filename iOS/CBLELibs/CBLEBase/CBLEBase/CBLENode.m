//
//  CBLENode.m
//  FloatingUUID
//
//  Created by Ryan Morton on 12/29/12.
//  Copyright (c) 2012 Ryan Morton. All rights reserved.
//

#import "CBLENode.h"
#import "CBLENode_EXT.h"
#import "CBLEUtils.h"

NSString * const kCBLEDebugMessageKey = @"CBLEDebugMessageKey";
NSString * const kCBLEErrorWarningLevelKey = @"CBLEErrorWarningLevelKey";

@implementation CBLENode
+(NSError*)errorWithCode:(NSUInteger)code userMessage:(NSString*)userMessage andWarningLevel:(CBLEErrorWarningLevel)warningLevel
{
    return [self errorWithCode:code userMessage:userMessage debugMessage:nil andWarningLevel:warningLevel];
}

+(NSError*)errorWithCode:(NSUInteger)code userMessage:(NSString*)userMessage andDebugMessage:(NSString*)debugMessage
{
    return [self errorWithCode:code userMessage:userMessage debugMessage:debugMessage andWarningLevel:kCBLEErrorWarningLevel_App];
}

+(NSError*)errorWithCode:(NSUInteger)code andUserMessage:(NSString*)userMessage
{
    return [self errorWithCode:code userMessage:userMessage debugMessage:nil andWarningLevel:kCBLEErrorWarningLevel_App];
}

+(NSError*)errorWithCode:(NSUInteger)code andDebugMessage:(NSString*)debugMessage
{
    NSError *error = [self errorWithCode:code userMessage:nil debugMessage:debugMessage andWarningLevel:kCBLEErrorWarningLevel_Debug];
    return error;
}

+(NSError*)errorWithCode:(NSUInteger)code userMessage:(NSString*)userMessage debugMessage:(NSString*)debugMessage andWarningLevel:(CBLEErrorWarningLevel)warningLevel
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    if(userMessage){[userInfo setObject:userMessage forKey:NSLocalizedFailureReasonErrorKey];}
    if(debugMessage){[userInfo setObject:debugMessage forKey:kCBLEDebugMessageKey];}
    [userInfo setObject:[NSNumber numberWithUnsignedInt:warningLevel] forKey:kCBLEErrorWarningLevelKey];
    
    return [NSError errorWithDomain:[self errorDomain] code:code userInfo:userInfo];
}

+(NSString*)getDebugMessageForTarget:(id)target methodName:(NSString*)methodName andCustomErrorText:(NSString*)errorText;
{
    if(target)
    {
        NSMutableString *errorString = [NSMutableString string];
        [errorString appendFormat:@"%@<%p> ERROR",NSStringFromClass([target class]),target];
        if(methodName.length>0){[errorString appendFormat:@" (%@)",methodName];}
        else
        {
            @try
            {
                NSArray *callStack = [NSThread callStackSymbols];
                if(callStack.count>1)
                {
                    [errorString appendFormat:@" (%@)",[callStack objectAtIndex:1]];
                }
            }
            @catch(NSException *ex){}
        }
        [errorString appendString:@": "];
        
        if(errorText.length>0)
        {
            [errorString appendString:errorText];
        }
        else
        {
            [errorString appendString:@"nil"];
        }
        
        return errorString;
    }
    return nil;
}

+(NSString*)errorDomain
{
    return [NSString stringWithFormat:@"%@.%@",[[NSBundle mainBundle] bundleIdentifier],@"CBLENode"];
}
@end
