//
//  CBLEUtils.h
//  FloatingUUID
//
//  Created by Ryan Morton on 12/29/12.
//  Copyright (c) 2012 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBLEUtils : NSObject
{
    
}

+(void)debugLog:(NSString*)debugString;
+(void)debugLog:(NSString*)debugString logCaller:(BOOL)logCaller;
@end
