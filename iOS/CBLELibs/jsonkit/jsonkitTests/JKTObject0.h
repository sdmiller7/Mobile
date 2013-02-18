//
//  JKTObject0.h
//  jsonkit
//
//  Created by Ryan Morton on 2/12/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKTObject0 : NSObject
{
    
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *count;
@property (nonatomic, retain) JKTObject0 *linkedObject;
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, assign) NSUInteger rows;
@property (nonatomic, assign) int mInt;
@property (nonatomic, assign) unsigned long long mUll;
@property (nonatomic, assign) id object;
@property (nonatomic, assign) double mFloat;
@property (nonatomic, retain) NSMutableArray *linkedObjects;//@[JKTObject0, ... ,JKTObject0]
@property (nonatomic, retain) NSMutableDictionary *mDictionaryObjects;

@end
