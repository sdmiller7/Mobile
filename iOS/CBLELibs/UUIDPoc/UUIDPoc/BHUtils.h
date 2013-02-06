//
//  BHUtils.h
//  UUIDPoc
//
//  Created by Ryan Morton on 2/5/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHUtils : NSObject
{
    
}

+ (NSString *)applicationPublicDocumentsDirectory;
+(NSString*)applicationLibraryDirectory;
+(BOOL)setSkipBackupAttribOfFileWithURL:(NSURL*)fileURL;
+(void)debugLogWithFormat:(NSString*)format,...;

+(UIBarButtonItem*)getFlexibleToolbarItem;
@end
