//
//  AppDelegate.m
//  Example
//
//  Created by Yoshimasa Niwa on 5/26/18.
//  Copyright © 2018 Yoshimasa Niwa. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIViewController *viewController = [[ViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];

    return YES;
}

@end
