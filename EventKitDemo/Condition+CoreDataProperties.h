//
//  Condition+CoreDataProperties.h
//  EventKitDemo
//
//  Created by YULIN CAI on 19/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Condition.h"

NS_ASSUME_NONNULL_BEGIN

@interface Condition (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *myKey;
@property ( nonatomic, retain) NSString *myReminderID;
@property (nullable, nonatomic, retain) id myValue;
@property ( nonatomic, retain) NSNumber *sattus;

@end

NS_ASSUME_NONNULL_END
