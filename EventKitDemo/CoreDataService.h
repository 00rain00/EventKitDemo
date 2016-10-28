//
//  CoreDataService.h
//  EventKitDemo
//
//  Created by YULIN CAI on 19/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Condition.h"
#import "Fact+CoreDataClass.h"

@interface CoreDataService : NSObject



- (Condition *)createCondition:(NSString *)reminderId :(NSString *)myKey :(NSData *)myValue;
-(NSArray *)fetchCondition:(NSFetchRequest *)request;
-(Fact *)createFact:(NSString *)factKey:(NSData *)factValue:(NSDate *)createTime;
-(NSArray *)fetchFacts:(NSFetchRequest *)request;
-(void)deleteCondition:(NSFetchRequest *)request;
-(void)save;
-(void)saveCondtion:(NSManagedObjectContext *)managedObjectContext;

@end
