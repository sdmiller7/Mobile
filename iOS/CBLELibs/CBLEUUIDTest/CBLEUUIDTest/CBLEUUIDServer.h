//
//  CBLEUUIDServer.h
//  CBLEUUIDTest
//
//  Created by Ryan Morton on 1/20/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const unsigned short kCBLEUUIDServerVersion;

@interface CBLEUUIDServer : NSObject
{
    
}


-(id)initServerWithDeviceID:(NSString*)deviceID;
/**
 Thread-safe
 */
-(void)start;

/**
 Thread-safe
 */
-(void)cancel;
@end
