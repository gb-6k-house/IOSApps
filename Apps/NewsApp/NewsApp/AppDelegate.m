//
//  AppDelegate.m
//  NewsApp
//
//  Created by liukai on 14-11-19.
//  Copyright (c) 2014年 荧光生活. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "LeftViewController.h"
#import "RightViewController.h"
#import <MSDynamicsDrawerViewController.h>
#import "LogInfo.h"
#import <DDTTYLogger.h>
#import <DDFileLogger.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}
- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[[DDFileLogger alloc] init]];

    MSDynamicsDrawerViewController *drawerCtr = [[MSDynamicsDrawerViewController alloc] init];
    HomeViewController *home = [[HomeViewController alloc] init];
    home.drawerCtrl = drawerCtr;
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:home];
    drawerCtr.paneViewController = homeNav;
    LeftViewController *left = [[LeftViewController alloc] init];
    left.drawerCtrl = drawerCtr;

    UINavigationController *leftNav = [[UINavigationController alloc] initWithRootViewController:left];

    [drawerCtr setDrawerViewController:leftNav forDirection:MSDynamicsDrawerDirectionLeft];
    RightViewController *right = [[RightViewController alloc] init];
    right.drawerCtrl = drawerCtr;
    UINavigationController *rightNav = [[UINavigationController alloc] initWithRootViewController:right];

    [drawerCtr setDrawerViewController:rightNav forDirection:MSDynamicsDrawerDirectionRight];
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.window.rootViewController = drawerCtr;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
