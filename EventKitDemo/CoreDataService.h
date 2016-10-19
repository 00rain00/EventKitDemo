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

@interface CoreDataService : NSObject

-(Condition *)createCondidion:(NSString *)id;
-(NSArray *)fetchCondition:(NSFetchRequest *)request;
-(void)deleteCondition:(NSFetchRequest *)request;
@end
