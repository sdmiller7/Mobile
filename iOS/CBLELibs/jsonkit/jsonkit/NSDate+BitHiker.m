//
//  NSDate+BitHiker.m
//  jsonkit
//
//  Created by Ryan Morton on 2/18/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "NSDate+BitHiker.h"

@implementation NSDate (BitHiker)
static NSDateFormatter *_utcFormatter;
+(void)initUTCFormatter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _utcFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [_utcFormatter setTimeZone:timeZone];
        [_utcFormatter setDateFormat:@"yyyyMMddHHmmss"];
    });
}

-(NSString*)UTCStringRepresentation
{
    [NSDate initUTCFormatter];
    return [_utcFormatter stringFromDate:self];
}

+(NSDate*)dateWithUTCStringRepresentation:(NSString*)utcDate
{
    if(utcDate.length>0)
    {
        [self initUTCFormatter];
        return [_utcFormatter dateFromString:utcDate];
    }
    return nil;
}
@end
