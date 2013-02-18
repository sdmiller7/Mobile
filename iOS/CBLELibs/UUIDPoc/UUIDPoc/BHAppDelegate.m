//
//  BHAppDelegate.m
//  UUIDPoc
//
//  Created by Ryan Morton on 2/5/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "BHAppDelegate.h"

#import "BHViewController.h"
#import "BHRootViewController.h"
#import "BHCoreDataManager.h"
#import "BHDashboardViewController.h"
#import <jsonkit/NSObject+BitHiker.h>

@implementation BHAppDelegate

static BHAppDelegate *_appDelegate;

- (void)dealloc
{
    _appDelegate = nil;
    self.dashboardViewController = nil;
    [_window release];
    [_rootViewController release];
    self.currentTest = nil;
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _appDelegate = self;
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    self.dashboardViewController = [[[BHDashboardViewController alloc] init] autorelease];
    
    self.rootViewController = [[[BHRootViewController alloc] initWithRootViewController:self.dashboardViewController] autorelease];
    [self.rootViewController setToolbarHidden:NO];
    self.window.rootViewController = self.rootViewController;
    [self.window makeKeyAndVisible];
    
    [[BHCoreDataManager sharedManager] getAllTestsWithCompleteBlock:^(NSArray *queryResults) {
        if(queryResults.count == 0)
        {
            //we don't have a valid test... create a new one
            [self createANewTestAndStart];
        }
        else
        {
            BHTest *lastTest = [queryResults lastObject];
            if(lastTest.endDate)
            {
                //we don't have a valid test... create a new one
                [self createANewTestAndStart];
            }
            else
            {
                [self startWithValidTest:lastTest];
            }
        }
    } includeAllPropertyData:YES];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Start
-(void)createANewTestAndStart
{
    [[BHCoreDataManager sharedManager] createANewTestWithCompleteBlock:^(NSArray *queryResults) {
        BHTest *test = [queryResults lastObject];
        [self startWithValidTest:test];
    }];
}

-(void)startWithValidTest:(BHTest*)test
{
    if(test)
    {
        self.currentTest = test;
    }
    else
    {
        //error
    }
}

@end
