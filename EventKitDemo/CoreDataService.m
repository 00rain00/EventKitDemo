//
//  CoreDataService.m
//  EventKitDemo
//
//  Created by YULIN CAI on 19/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "CoreDataService.h"

@interface CoreDataService()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation CoreDataService

-(instancetype)init{
if((self = [super init])){
    [self initCoreData];
}
    return self;
}

- (Condition *)createCondidion:(NSString *)id {
    Condition *condition = [NSEntityDescription insertNewObjectForEntityForName:@"Condition" inManagedObjectContext:self.managedObjectContext];
    condition .myReminderID = id;
    condition.myKey = @"time";
    condition.myValue= @"0800";
    condition.sattus = @YES;
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        FATAL_CORE_DATA_ERROR(error);
    }
return condition;
}

- (NSArray *)fetchCondition:(NSFetchRequest *)request {
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (OBJECT_ISNOT_EMPTY(error)) {
        FATAL_CORE_DATA_ERROR(error);

    }
    return results ;
}

- (void)deleteCondition:(NSFetchRequest *)request {
    NSBatchDeleteRequest * deleteRequest  = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    NSError *error = nil;
     [self.managedObjectContext executeRequest:deleteRequest error:&error];
    if (OBJECT_ISNOT_EMPTY(error)) {
        FATAL_CORE_DATA_ERROR(error);

    }

}


-(void)initCoreData{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Reminder" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(mom != nil, @"Error initializing Managed Object Model");

    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:psc];
    [self setManagedObjectContext:moc];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"Reminder.sqlite"];

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSError *error = nil;
        NSPersistentStoreCoordinator *psc = [[self managedObjectContext] persistentStoreCoordinator];
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
        NSAssert(store != nil, @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
    });
}


@end
