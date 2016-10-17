//
//  DateAndTimeViewController.m
//  EventKitDemo
//
//  Created by YULIN CAI on 16/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "DateAndTimeViewController.h"
#import "DatePickerViewController.h"

NSString * const kEveryDay = @"Every Day At";
NSString * const kEveryDayOfWeekAt = @"Every Day Of Week At";

NSString * const kEveryMonthOn = @"Every Month On";

NSString * const kEveryYear = @"Every Year on";



@interface DateAndTimeViewController ()

@end

@implementation DateAndTimeViewController

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
    DDLogDebug(@"");
    
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeForm];
    }
    return self;
}

-(void)initializeForm{
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
   
       form = [XLFormDescriptor formDescriptor];
     __typeof(self) __weak weakSelf = self;
   
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Date & Time"];
    [form addFormSection:section];

 XLFormRowDescriptor *  everyDayRow = [XLFormRowDescriptor formRowDescriptorWithTag:kEveryDay rowType:XLFormRowDescriptorTypeButton title:kEveryDay];
 
everyDayRow.action.formBlock=^(XLFormRowDescriptor *sender){
    weakSelf.datePicker = 1;
    [[NSUserDefaults standardUserDefaults] setObject:@((NSInteger) weakSelf.datePicker) forKey:@"dateAndTime_selected_option"];
    [weakSelf performSegueWithIdentifier:@"idSeguePickDate" sender:weakSelf];
};


    [section addFormRow:everyDayRow];
    
    
XLFormRowDescriptor*    everyDayOfWeekrow = [XLFormRowDescriptor formRowDescriptorWithTag:kEveryDayOfWeekAt rowType:XLFormRowDescriptorTypeButton title:kEveryDayOfWeekAt];
   everyDayOfWeekrow.action.formBlock=^(XLFormRowDescriptor *sender){
       weakSelf.datePicker=2;
       [[NSUserDefaults standardUserDefaults] setObject:@((NSInteger) weakSelf.datePicker) forKey:@"dateAndTime_selected_option"];
       [weakSelf performSegueWithIdentifier:@"idSeguePickDate" sender:weakSelf];
   };
   [section addFormRow:everyDayOfWeekrow];
    
    XLFormRowDescriptor * everyMonthrow = [XLFormRowDescriptor formRowDescriptorWithTag:kEveryMonthOn rowType:XLFormRowDescriptorTypeButton title:kEveryMonthOn];
    everyMonthrow.action.formBlock=^(XLFormRowDescriptor * sender){
        weakSelf.datePicker = 3;
        [[NSUserDefaults standardUserDefaults] setObject:@((NSInteger) weakSelf.datePicker) forKey:@"dateAndTime_selected_option"];
        [weakSelf performSegueWithIdentifier:@"idSeguePickDate" sender:weakSelf];
    };
    

    [section addFormRow:everyMonthrow];
    

    self.form = form;
    
    
    
}

-(void)didPressRow:(XLFormRowDescriptor *)sender selection:(int)option{
    
    DDLogDebug(@"");
  //      if ([sender.tag isEqualToString:kEveryDay]) {
        self.datePicker = 1;
 //   };
        
//        else if([sender.tag isEqualToString:k) {
//
//    }
    DatePickerViewController * controller = [[DatePickerViewController alloc]initWithNibName:@"DatePickerViewController" bundle:nil];
    DDLogDebug(@"date picker : %d",self.datePicker);
    controller.selection = self.datePicker;
    [self performSegueWithIdentifier:@"idSeguePickDate" sender:self ];

    
}





@end
