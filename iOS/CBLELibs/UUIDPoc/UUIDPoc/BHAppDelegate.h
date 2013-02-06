//
//  BHAppDelegate.h
//  UUIDPoc
//
//  Created by Ryan Morton on 2/5/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BHRootViewController,BHDashboardViewController;

@interface BHAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BHRootViewController *rootViewController;
@property (nonatomic, retain) BHDashboardViewController *dashboardViewController;

@end
