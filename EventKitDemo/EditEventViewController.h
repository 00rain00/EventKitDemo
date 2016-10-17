//
//  EditEventViewController.h
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePickerViewController.h"
#import "AddAlarm.h"
#import "AddLocationViewController.h"
#import "AddWeatherViewController.h"
@protocol EditEventViewControllerDelegate

-(void)eventWasSuccessfullySaved;

@end


@interface EditEventViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource,
        AddAlarmDelegate,AddLocationViewControllerDelegate,AddWeatherViewControllerDelegate>

@property (nonatomic, strong) id<EditEventViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tblEvent;
@property (nonatomic, strong)EKReminder *editedEvent;



- (IBAction)saveEvent:(id)sender;
-(IBAction)NewCondition:(id)sender;
-(IBAction)cancle:(id)sender;
-(NSArray *)fetchCondition:(NSString *)reminderID;
@end
