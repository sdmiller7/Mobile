//
//  CBUUID+CBLE.m
//  FloatingUUID
//
//  Created by Ryan Morton on 12/12/12.
//  Copyright (c) 2012 Ryan Morton. All rights reserved.
//

#import "CBUUID+CBLE.h"

@implementation CBUUID (CBLE)

/**
 source: http://stackoverflow.com/questions/13275859/how-to-turn-cbuuid-into-string
 */
-(NSString*)stringRepresentation
{
    return [self stringRepresentationWithCase:NO];
}

-(NSString*)stringRepresentationWithCase:(BOOL)upperCase
{
    NSData *data = [self data];
    
    NSUInteger bytesToConvert = [data length];
    const unsigned char *uuidBytes = [data bytes];
    NSMutableString *outputString = [NSMutableString stringWithCapacity:16];
    
    for (NSUInteger currentByteIndex = 0; currentByteIndex < bytesToConvert; currentByteIndex++)
    {
        switch (currentByteIndex)
        {
            case 3:
            case 5:
            case 7:
            case 9:[outputString appendFormat:@"%02x-", uuidBytes[currentByteIndex]]; break;
            default:[outputString appendFormat:@"%02x", uuidBytes[currentByteIndex]];
        }
        
    }
    
    if(upperCase)
    {
        return [outputString uppercaseString];
    }
    return [outputString lowercaseString];
}
@end
