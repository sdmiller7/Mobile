//
//  CBLENode.h
//  FloatingUUID
//
//  Created by Ryan Morton on 12/29/12.
//  Copyright (c) 2012 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kCBLEDebugMessageKey;
extern NSString * const kCBLEErrorWarningLevelKey;

typedef enum{
    kCBLEErrorWarningLevel_App = 0,
    kCBLEErrorWarningLevel_Debug = 1
}CBLEErrorWarningLevel;

@interface CBLENode : NSObject
{
    
}

+(NSString*)errorDomain;
+(NSString*)getDebugMessageForTarget:(id)target methodName:(NSString*)methodName andCustomErrorText:(NSString*)errorText;
@end
