//
//  DatePickerViewController.h
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XLForm/XLForm.h>
#import "CoreDataService.h"
@protocol DatePickerViewControllerDelegate

-(void)dateWasSelected:(NSDate *)selectedDate;

@end


@interface DatePickerViewController : XLFormViewController
@property (nonatomic, strong) id<DatePickerViewControllerDelegate> delegate;



@property (strong, nonatomic)XLFormRowDescriptor * rowDescriptor1;

@property(nonatomic)int selection;



@end
