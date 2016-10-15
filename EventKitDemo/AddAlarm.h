//
//  AddAlarm.h
//  EventKitDemo
//
//  Created by YULIN CAI on 13/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <XLForm/XLForm.h>
#import <UIKit/UIKit.h>
@class EKAlarm;
@class EKReminder;
@class AppDelegate;
@class AddAlarm;

@protocol AddAlarmDelegate<NSObject>
-(void)addAlarm:(AddAlarm *)controller didFinishCreateAlarm:(EKAlarm *)item;

@end
@interface AddAlarm : XLFormViewController
@property (nonatomic, weak)id <AddAlarmDelegate> delegate;
@property (nonatomic, strong)EKAlarm *ekAlarm;
@property (nonatomic, strong) AppDelegate *appDelegate;


@end
