//
//  NSString+CBLE.h
//  FloatingUUID
//
//  Created by Ryan Morton on 12/9/12.
//  Copyright (c) 2012 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CBLE)
{
    
}

+(NSString*)CFUUIDToNSString:(CFUUIDRef)cfUUID;
+(NSString*)CFUUIDToNSString:(CFUUIDRef)cfUUID upperCase:(BOOL)upperCase;
+(NSString*)UUID;
+(NSString*)UUIDWithCase:(BOOL)upperCase;

-(NSString *) urlEncoded;
@end
