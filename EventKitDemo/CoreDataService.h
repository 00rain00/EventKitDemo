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
#import <Photos/Photos.h>
@interface CoreDataService : NSObject



- (Condition *)createCondition:(NSString *)reminderId :(NSString *)myKey :(NSData *)myValue;

-(NSArray *)fetchCondition:(NSFetchRequest *)request;
-(void)deleteCondition:(NSFetchRequest *)request;
-(void)saveCondition;
-(void)saveCondtion:(NSManagedObjectContext *)managedObjectContext;
- (void)photoLibraryDidChange:(PHChange *)changeInstance;
@end
