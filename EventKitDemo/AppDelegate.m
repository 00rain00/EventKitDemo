//
//  AppDelegate.m
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//


#import "AppDelegate.h"


NSString * const ManagedObjectContextSaveDidFailNotification = @"ManagedObjectContextSaveDidFailNotification";
static NSString * const kReminderStoreName = @"Reminder.sqlite";


@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DDTTYLogger sharedInstance].logFormatter=[CustomerFormatter new];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console

    DDLogDebug(@"application start");
    [self copyDefaultStoreIfNecessary];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelVerbose];
    [MagicalRecord setupCoreDataStackWithStoreNamed:kReminderStoreName];
    self.controller.managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    self.eventManager= [EventManager new];
    self.engineService= [EngineService new];
    return YES;
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
    DDLogDebug(@"");


}
- (void) copyDefaultStoreIfNecessary;
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:kReminderStoreName];
    
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:[storeURL path]])
    {
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:[kReminderStoreName stringByDeletingPathExtension] ofType:[kReminderStoreName pathExtension]];
        
        if (defaultStorePath)
        {
            NSError *error;
            BOOL success = [fileManager copyItemAtPath:defaultStorePath toPath:[storeURL path] error:&error];
            if (!success)
            {
                DDLogDebug(@"Failed to install default reminder store");
            }
        }
    }
    
}

							

@end
