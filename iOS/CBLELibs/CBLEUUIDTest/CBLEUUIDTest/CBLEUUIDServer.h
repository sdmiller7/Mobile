//
//  CBLEUUIDServer.h
//  CBLEUUIDTest
//
//  Created by Ryan Morton on 1/20/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBLEUUIDServer : NSObject
{
    
}


-(id)initServerWithDeviceID:(NSString*)deviceID;
-(void)start;
-(void)cancel;
@end
