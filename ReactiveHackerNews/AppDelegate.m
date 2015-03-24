//
//  AppDelegate.m
//  ReactiveHackerNews
//
//  Created by syshen on 2/10/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import "AppDelegate.h"
#import "StoryViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Fabric with:@[CrashlyticsKit]];

    return YES;
}

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([url.scheme isEqual:@"rhn"]) {
        StoryViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"StoryViewController"];
        
        NSRange range = [url.query rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
        NSString *urlString = [url.query substringFromIndex:range.location+1];
        vc.presentingURLString = urlString;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
        
        return YES;
    }
    
    return NO;
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
