//
//  AddAlarm.m
//  EventKitDemo
//
//  Created by YULIN CAI on 13/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "AddAlarm.h"
#import "AppDelegate.h"
#import "EditEventViewController.h"

NSString *const kTime = @"time";
@implementation AddAlarm
- (id)initWithCoder:(NSCoder *)aDecoder {
    DDLogDebug(@"");
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeForm];


    }
    return self;
}
- (void)initializeForm {
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;

    form = [XLFormDescriptor formDescriptorWithTitle:@"Time setting"];

    // First section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Time contrasins"];
    [form addFormSection:section];

//    // All-day
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"all-day" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"All-day"];
//    [section addFormRow:row];

    // Starts
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kTime rowType:XLFormRowDescriptorTypeDateTimeInline title:@"Starts"];
    row.value = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
    [section addFormRow:row];

//    //end
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"ends" rowType:XLFormRowDescriptorTypeDateTimeInline title:@"Ends"];
//    row.value = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
//    [section addFormRow:row];


    // Second Section
//    section = [XLFormSectionDescriptor formSectionWithTitle:@"contrain: location"];
//    [form addFormSection:section];
//
//
//
//    // Location
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"location" rowType:XLFormRowDescriptorTypeText];
//    [row.cellConfigAtConfigure setObject:@"Location" forKey:@"textField.placeholder"];
//    [section addFormRow:row];

//    //third section
//    section = [XLFormSectionDescriptor formSectionWithTitle:@"devices"];
//    [form addFormSection:section];
//


//    //charging
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:charge rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Charging"];
//    row.selectorOptions = @[@"Yes", @"No"];
//    row.value = @"No";
//    [section addFormRow:row];
//
//    //earphone plugin
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:earphone rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Connect to earphone"];
//    row.selectorOptions = @[@"Yes", @"No"];
//    row.value = @"No";
//    [section addFormRow:row];

//    //Constrains
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSelectorActionSheet rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Condition"];
//    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"All"],
//            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"None"],
//            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Any"],
//
//    ];
//    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"All"];
//    [section addFormRow:row];


    self.form = form;


}
#pragma mark - preparefortransition
-(void)viewWillDisappear:(BOOL)animated {
    DDLogDebug(@"");
   NSDictionary *formValue = [self.form formValues];
    for(id key in formValue){
        DDLogDebug(@"key:%@",key);
        if(  [key isEqualToString:kTime]){

            NSDate *alarmTime = (NSDate *)formValue[key];
           EKAlarm *alarm1= [EKAlarm alarmWithAbsoluteDate:alarmTime];
            self.ekAlarm=alarm1;
            break;
        }
    }
    //pass alerm back
    [self.delegate addAlarm:self didFinishCreateAlarm:self.ekAlarm];
}



@end
