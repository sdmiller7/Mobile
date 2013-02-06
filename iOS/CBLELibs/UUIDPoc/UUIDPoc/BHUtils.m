//
//  BHUtils.m
//  UUIDPoc
//
//  Created by Ryan Morton on 2/5/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "BHUtils.h"
#import <sys/xattr.h>

@implementation BHUtils
+ (NSString *)applicationPublicDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+(NSString*)applicationLibraryDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

+(BOOL)setSkipBackupAttribOfFileWithURL:(NSURL*)fileURL
{
    NSError *error = nil;
    BOOL success = YES;
    if(&NSURLIsExcludedFromBackupKey == nil)//iOS <=5.0.1
    {
        const char* filePath = [[fileURL path] fileSystemRepresentation];
        
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        success &= (result == 0);
    }
    else
    {
        //iOS >= 5.1
        success &= [fileURL setResourceValue: [NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success){
            //NSLog(@"Error excluding %@ from backup %@", [fileURL lastPathComponent], error);
        }
    }
    return success;
}

+(void)debugLogWithFormat:(NSString*)format,...
{
#if DEBUG
    if(format.length>0)
    {
        va_list args;
        va_start(args, format);
        NSString *debugString = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
        va_end(args);
        
        NSLog(@"%@",debugString);
    }
#endif
}

#pragma mark - UI
+(UIBarButtonItem*)getFlexibleToolbarItem
{
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    return [flex autorelease];
}
@end
