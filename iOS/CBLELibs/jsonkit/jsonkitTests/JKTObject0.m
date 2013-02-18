//
//  JKTObject0.m
//  jsonkit
//
//  Created by Ryan Morton on 2/12/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "JKTObject0.h"

@implementation JKTObject0
-(void)dealloc
{
    self.object = nil;
    self.count = nil;
    self.name = nil;
    self.linkedObject = nil;
    self.linkedObjects = nil;
    self.mDictionaryObjects = nil;
    [super dealloc];
}
@end
