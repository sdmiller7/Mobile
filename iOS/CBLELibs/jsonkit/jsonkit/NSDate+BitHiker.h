//
//  NSDate+BitHiker.h
//  jsonkit
//
//  Created by Ryan Morton on 2/18/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (BitHiker)
-(NSString*)UTCStringRepresentation;
+(NSDate*)dateWithUTCStringRepresentation:(NSString*)utcDate;
@end
