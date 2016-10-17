//
//  DatePickerViewController.m
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "DatePickerViewController.h"
#import "XLFormWeekDaysCell.h"
#import "DateAndTimeViewController.h"

//NSString * const XLFormRowDescriptorTypeWeekDays = @"XLFormRowDescriptorTypeWeekDays";

//NSString *const kSunday= @"sunday";
//NSString *const kMonday = @"monday";
//NSString *const kTuesday = @"tuesday";
//NSString *const kWednesday = @"wednesday";
//NSString *const kThursday = @"thursday";
//NSString *const kFriday = @"friday";
//NSString *const kSaturday = @"saturday";
//

@interface DatePickerViewController ()

@property (nonatomic,strong) DateAndTimeViewController * controller;
@end

@implementation DatePickerViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self initializeForm];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder

{
    
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeForm];
    }
    return self;
}

-(void)initializeForm{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.selection = [[userDefaults valueForKey:@"dateAndTime_selected_option"] intValue];
    DDLogDebug(@"selection : %d",self.selection);
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    form = [XLFormDescriptor formDescriptor];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Pick Date & Time"];
    [form addFormSection:section];
    
    if (self.selection == 1) {
      XLFormRowDescriptor * row = [XLFormRowDescriptor formRowDescriptorWithTag:@"time" rowType:XLFormRowDescriptorTypeTimeInline title:@"Time"];
        row.value = [NSDate new];
        [section addFormRow:row];
    }
    else if (self.selection==2){
        XLFormRowDescriptor  *row = [XLFormRowDescriptor formRowDescriptorWithTag:@"time" rowType:XLFormRowDescriptorTypeTimeInline title:@"Time"];
        row.value = [NSDate new];
        [section addFormRow:row];
        
        section = [XLFormSectionDescriptor formSectionWithTitle:@"Weekdays"];
        [form addFormSection:section];
        
        // WeekDays
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"WeekDay" rowType:XLFormRowDescriptorTypeWeekDays];
        row.value =  @{
                       kSunday: @(NO),
                       kMonday: @(NO),
                       kTuesday: @(YES),
                       kWednesday: @(NO),
                       kThursday: @(NO),
                       kFriday: @(NO),
                       kSaturday: @(NO)
                       };
        [section addFormRow:row];

        
    }
    else if (self.selection==3){

       XLFormRowDescriptor *  row = [XLFormRowDescriptor formRowDescriptorWithTag:@"Day selector" rowType:XLFormRowDescriptorTypeMultipleSelector title:@"Date"];
        row.selectorOptions = @[@"Day 1",@"Day 2",@"Day 3",@"Day 4",@"Day 5",@"Day 6",@"Day 7",@"Day 8",@"Day 9",@"Day 10",@"Day 11",@"Day 12",@"Day 13",@"Day 14",@"Day 15",@"Day 16",@"Day 17",@"Day 18",@"Day 19",@"Day 20",@"Day 21",@"Day 22",@"Day 23",@"Day 24",@"Day 25",@"Day 26",@"Day 27",@"Day 28",@"Day 29",@"Day 30"];
        row.value = @[@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30];
        [section addFormRow:row];

        XLFormRowDescriptor  *row2 = [XLFormRowDescriptor formRowDescriptorWithTag:@"time" rowType:XLFormRowDescriptorTypeTimeInline title:@"Time"];
        row2.value = [NSDate new];
        [section addFormRow:row2];
        
    }
    
    
    
    
    
    
    
    
    self.form = form;
    
    
    
}



#pragma mark - IBAction method implementation

- (IBAction)acceptDate:(id)sender {
    // Notify the caller that a date was selected.
 //   [self.delegate dateWasSelected:self.dtDatePicker.date];
    
    // Pop the view controller.
   
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];

    

}

@end
