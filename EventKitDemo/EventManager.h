//
//  EventManager.h
//  EventKitDemo
//
//  Created by YULIN CAI on 18/09/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>
@import EventKit;
@interface EventManager : NSObject

@property (nonatomic, strong) EKEventStore *ekEventStore;

@property (nonatomic)BOOL eventsAccessGranted;

@property (nonatomic, strong)NSString *selectedCalenderIdentifier;
-(NSArray *)getiCloudCalendars;
-(NSArray *)getLocalCalenders;
-(void)saveCustomerCalendarIdentifier:(NSString *)identifier;
-(BOOL)checkIfCalendarIsCustomerWithIdentifier:(NSString *)identifier;
-(void)removeCalendarIdentifier:(NSString *)identifier;
-(NSString *)getStringFromDate:(NSDate *)date;
@end
