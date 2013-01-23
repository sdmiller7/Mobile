//
//  NSObject+CBLEDebug.m
//  FloatingUUID
//
//  Created by Ryan Morton on 12/29/12.
//  Copyright (c) 2012 Ryan Morton. All rights reserved.
//

#import "NSObject+CBLEDebug.h"

@implementation NSObject (CBLEDebug)
-(NSString*)methodName
{
    //NSString *methodName = NSStringFromSelector(_cmd);//current method name
    @try
    {
        NSArray *callStack = [NSThread callStackSymbols];
        if(callStack.count>1)
        {
            return [callStack objectAtIndex:1];//calling method name
        }
    }
    @catch(NSException *ex){}
    return nil;
}
@end
