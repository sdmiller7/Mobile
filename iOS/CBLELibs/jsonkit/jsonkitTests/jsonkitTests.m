//
//  jsonkitTests.m
//  jsonkitTests
//
//  Created by Ryan Morton on 2/12/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "jsonkitTests.h"
#import "JKTObject0.h"
#import "JSONKit.h"

@implementation jsonkitTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

-(void)testPropertyNamesAndTypes
{
    JKTObject0 *obj0 = [[[JKTObject0 alloc] init] autorelease];
    NSLog(@"obj0<propertyNamesAndTypes>: %@",[obj0 propertyNamesAndTypes]);
}

-(void)testJSONRepresentation
{
    JKTObject0 *obj0 = [[[JKTObject0 alloc] init] autorelease];
    obj0.name = @"testOBJ0";
    obj0.linkedObject = [[[JKTObject0 alloc] init] autorelease];
    
    obj0.mDictionaryObjects = [NSMutableDictionary dictionary];
    for(NSUInteger i = 0; i<1;i++)
    {
        JKTObject0 *obj1 = [[[JKTObject0 alloc] init] autorelease];
        obj1.linkedObjects = [NSMutableArray array];
        for(NSUInteger i = 0; i<1;i++)
        {
            [obj1.linkedObjects addObject:[[[JKTObject0 alloc] init] autorelease]];
        }
        [obj0.mDictionaryObjects setObject:obj1 forKey:[NSString stringWithFormat:@"object%i",i]];
    }
    
    NSLog(@"obj0<JSONRepresentation>: %@",[obj0 jsonRepresentation]);
}
@end
