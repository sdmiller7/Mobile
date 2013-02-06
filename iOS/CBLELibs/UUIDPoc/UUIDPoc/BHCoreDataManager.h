//
//  BHCoreDataManager.h
//  UUIDPoc
//
//  Created by Ryan Morton on 2/5/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^BHCoreDataManagerBOOLResponseBlock)(BOOL success);


@interface BHCoreDataManager : NSObject
{
    
}

+(BHCoreDataManager*)sharedManager;
@end
