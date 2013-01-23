//
//  CBLEUtils.m
//  FloatingUUID
//
//  Created by Ryan Morton on 12/29/12.
//  Copyright (c) 2012 Ryan Morton. All rights reserved.
//

#import "CBLEUtils.h"

@implementation CBLEUtils

+(void)debugLog:(NSString*)debugString logCaller:(BOOL)logCaller
{
#if DEBUG
    if(debugString.length>0)
    {
        if(logCaller)
        {
            NSString *caller = nil;
            @try
            {
                NSArray *callStack = [NSThread callStackSymbols];
                if(callStack.count>1)
                {
                    caller = [callStack objectAtIndex:1];//calling method name
                }
            }
            @catch(NSException *ex){}
            
            if(caller.length>0)
            {
                NSLog(@"DEBUG<caller: %@>: %@",caller,debugString);
            }
            else
            {
                NSLog(@"DEBUG: %@",debugString);
            }
        }
        else
        {
            NSLog(@"DEBUG: %@",debugString);
        }
    }
#endif
}

+(void)debugLoggingCaller:(BOOL)logCaller withStringFormat:(NSString *)format,...
{
    if(format)
    {
        va_list args;
        va_start(args, format);
        NSString *result = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        [CBLEUtils debugLog:result logCaller:logCaller];
    }
}

+(void)debugLogWithFormat:(NSString *)format,...
{
    if(format)
    {
        va_list args;
        va_start(args, format);
        NSString *result = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        [CBLEUtils debugLog:result];
    }
}

+(void)debugLog:(NSString*)debugString
{
    [CBLEUtils debugLog:debugString logCaller:NO];
}
@end
