//
//  Reminder+CoreDataProperties.h
//  EventKitDemo
//
//  Created by YULIN CAI on 16/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Reminder.h"

NS_ASSUME_NONNULL_BEGIN

@interface Reminder (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *myCalendarID;
@property (nullable, nonatomic, retain) NSString *myReminderID;
@property (nullable, nonatomic, retain) NSString *reminderTitle;
@property (nullable, nonatomic, retain) NSSet<Condition *> *relationship;

@end

@interface Reminder (CoreDataGeneratedAccessors)

- (void)addRelationshipObject:(Condition *)value;
- (void)removeRelationshipObject:(Condition *)value;
- (void)addRelationship:(NSSet<Condition *> *)values;
- (void)removeRelationship:(NSSet<Condition *> *)values;

@end

NS_ASSUME_NONNULL_END
