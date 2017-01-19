//
//  CreateAlarmFormViewController.m
//  EventKitDemo
//
//  Created by YULIN CAI on 30/09/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "AppDelegate.h"
#import "CreateAlarmFormViewController.h"
#import "DBMapSelectorViewController/DBMapSelectorManager.h"

NSString *const kSelectorActionSheet = @"selectorActionSheet";
NSString *const kSlider = @"bettry";
NSString *const charge = @"charge";
NSString *const earphone = @"earphone";
@interface CreateAlarmFormViewController ()<DBMapSelectorManagerDelegate>

@property (nonatomic, strong) AppDelegate *appDelegate;

@property (nonatomic, strong)DBMapSelectorManager *mapSelectorManager;

@end

@implementation CreateAlarmFormViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    DDLogDebug(@"");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self initializeForm];
    }
    return self;
}

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
    self.ekAlarm = [EKAlarm new];
    form = [XLFormDescriptor formDescriptorWithTitle:@"Add Notification"];
    
    // First section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"contrain: time interval"];
    [form addFormSection:section];

//    // All-day
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"all-day" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"All-day"];
//    [section addFormRow:row];

    // Starts
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"starts" rowType:XLFormRowDescriptorTypeDateTimeInline title:@"Starts"];
    row.value = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
    [section addFormRow:row];

    //end
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"ends" rowType:XLFormRowDescriptorTypeDateTimeInline title:@"Ends"];
    row.value = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
    [section addFormRow:row];


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
    
    //third section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"devices"];
    [form addFormSection:section];

    //bettry level
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSlider rowType:XLFormRowDescriptorTypeSlider title:@"Bettry level"];
    row.value = @(50);
    row.cellConfigAtConfigure[@"slider.maximumValue"] = @(100);
    row.cellConfigAtConfigure[@"slider.minimumValue"] = @(10);
    row.cellConfigAtConfigure[@"steps"] = @(4);
    [section addFormRow:row];

    //charging
    row = [XLFormRowDescriptor formRowDescriptorWithTag:charge rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Charging"];
    row.selectorOptions = @[@"Yes", @"No"];
    row.value = @"No";
    [section addFormRow:row];

    //earphone plugin
    row = [XLFormRowDescriptor formRowDescriptorWithTag:earphone rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@"Connect to earphone"];
    row.selectorOptions = @[@"Yes", @"No"];
    row.value = @"No";
    [section addFormRow:row];

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
    [self print];

}

-(NSDictionary *)formValues {
    return [self.form formValues];
}

-(void)print{
    self.dictionary = [self formValues];
    for (id key in self.dictionary) {
        DDLogDebug(@"key=%@  value =%@",key, self.dictionary[key]);
    }
}

//- (IBAction)saveNotificationRules:(id)sender {
//    [self print];
//    NSDictionary *rules= [self.appDelegate.engineService transformRules:self.dictionary];
//    if(OBJECT_IS_EMPTY(rules)){
//        DDLogDebug(@"fail generate ruls");
//        return;
//    } else{
//        for (id key in rules) {
//            DDLogDebug(@"key=%@  value =%@",key, rules[key]);
//        }
//
//        //TODO use core data to save the rules and identifier
//    }
//}


@end
