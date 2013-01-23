//
//  NSString+CBLE.m
//  FloatingUUID
//
//  Created by Ryan Morton on 12/9/12.
//  Copyright (c) 2012 Ryan Morton. All rights reserved.
//

#import "NSString+CBLE.h"

@implementation NSString (Utils)

+(NSString*)CFUUIDToNSString:(CFUUIDRef)cfUUID
{
    return [NSString CFUUIDToNSString:cfUUID upperCase:NO];
}

+(NSString*)CFUUIDToNSString:(CFUUIDRef)cfUUID upperCase:(BOOL)upperCase
{
    if(cfUUID)
    {
        CFStringRef stringUUID = CFUUIDCreateString(NULL, cfUUID);
        NSString *result = (NSString *)CFBridgingRelease(stringUUID);
        if(upperCase)
        {
            return [result uppercaseString];
        }
        return [result lowercaseString];
    }
    return nil;
}

+(NSString*)UUID
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef stringUUID = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return [(NSString *)CFBridgingRelease(stringUUID) lowercaseString];
}

+(NSString*)UUIDWithCase:(BOOL)upperCase
{
    NSString *uuid = [NSString UUID];
    
    if(upperCase)
    {
        return [uuid uppercaseString];
    }
    return uuid;
}

-(NSString *) urlEncoded
{
    CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(
        NULL,
        (CFStringRef)self,
        NULL,
        (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
        kCFStringEncodingUTF8 );
    return (NSString *)CFBridgingRelease(urlString);
}
@end
