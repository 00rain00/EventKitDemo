//
//  Condition+CoreDataProperties.h
//  EventKitDemo
//
//  Created by YULIN CAI on 16/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Condition.h"

NS_ASSUME_NONNULL_BEGIN

@interface Condition (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *myReminderID;
@property (nullable, nonatomic, retain) NSString *myKey;
@property (nullable, nonatomic, retain) id myValue;

@end

NS_ASSUME_NONNULL_END
