//
//  SafeToEatAppDelegate.m
//  SafeToEat
//
//  Created by Dorian Karter on 3/3/14.
//  Copyright (c) 2014 SpiralTech. All rights reserved.
//

#import "SafeToEatAppDelegate.h"
#import "ViewControllers/NoInternetViewController.h"
#import <Reachability/Reachability.h>

@implementation SafeToEatAppDelegate {
    BOOL isShowingNoInternetConnectionScreen;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    isShowingNoInternetConnectionScreen = NO;
    [NSTimer scheduledTimerWithTimeInterval:3.0
                                     target:self
                                   selector:@selector(checkInternetConnection)
                                   userInfo:nil
                                    repeats:YES];
    return YES;

    
}

-(void)checkInternetConnection {
    Reachability *r = [Reachability reachabilityWithHostname:kESHostName];
    
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    UIViewController *root = self.window.rootViewController;
    
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)) {
        if (!isShowingNoInternetConnectionScreen) {

            NoInternetViewController *nivc = [root.storyboard
                                              instantiateViewControllerWithIdentifier:kESNoInternetView];
            [root presentViewController:nivc animated:YES completion:nil];
            isShowingNoInternetConnectionScreen = YES;
        }
        
    } else if (isShowingNoInternetConnectionScreen) {
        [root dismissViewControllerAnimated:YES completion:nil];
        isShowingNoInternetConnectionScreen = NO;
    }
}

- (void)reachabilityChanged {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"EatSafe Connection Error"
                                                    message:@"Cannot connect to the internet, please check your internet connection."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
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

@end
