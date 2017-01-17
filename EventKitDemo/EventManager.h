//
//  EventManager.h
//  EventKitDemo
//
//  Created by YULIN CAI on 18/09/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EngineService.h"
@import EventKit;

//declare a block
typedef void(^FetchRemindersBlock)(NSArray *reminders);
@interface EventManager : NSObject

@property (nonatomic, strong)FetchRemindersBlock callbackForFetchReminders;
@property (nonatomic, strong) EKEventStore *ekEventStore;
@property (nonatomic, strong)EngineService *es;
@property (nonatomic)BOOL eventsAccessGranted;

@property (nonatomic, strong)NSString *selectedCalenderIdentifier;

@property (nonatomic, strong)NSString *selectedEventIdentifier;
-(void)callbackForFetchReminders:(FetchRemindersBlock)reminderDidRetrived;
-(NSArray *)getiCloudCalendars;
-(NSArray *)getLocalCalenders;
-(NSArray *)getiCloudReminders;
-(void)saveCustomerCalendarIdentifier:(NSString *)identifier;
-(BOOL)checkIfCalendarIsCustomerWithIdentifier:(NSString *)identifier;
-(void)removeCalendarIdentifier:(NSString *)identifier;
-(void)deleteEventWithIdentifier:(NSString *)identifier;
-(NSString *)getStringFromDate:(NSDate *)date;
-(NSArray *)getEventsOfSelectedCalendar;
-(NSMutableArray*)getCalendarBy:(NSArray *)calendarIdentifiers;
-(void)getRemembersOfSelectedCalendar:(NSArray *)calenders;
-(BOOL)checkCondition:(NSArray *)conditions;
@end
