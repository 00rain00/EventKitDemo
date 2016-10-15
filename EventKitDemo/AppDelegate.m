//
//  AppDelegate.m
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//


#import "AppDelegate.h"


NSString * const ManagedObjectContextSaveDidFailNotification = @"ManagedObjectContextSaveDidFailNotification";



@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DDTTYLogger sharedInstance].logFormatter=[CustomerFormatter new];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console

    DDLogDebug(@"application start");


    return YES;
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
    self.eventManager= [EventManager new];
    self.engineService= [EngineService new];

}
							

@end
