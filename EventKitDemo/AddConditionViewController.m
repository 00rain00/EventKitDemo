//
//  AddConditionViewController.m
//  EventKitDemo
//
//  Created by YULIN CAI on 16/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "AddConditionViewController.h"

NSString * const kSelectors = @"Selectors";

@interface AddConditionViewController ()

@end

@implementation AddConditionViewController

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
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    form = [XLFormDescriptor formDescriptor];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Condition"];
    [form addFormSection:section];
    
    
    
    
  XLFormRowDescriptor *     Daterow = [XLFormRowDescriptor formRowDescriptorWithTag:kSelectors rowType:XLFormRowDescriptorTypeButton title:@"Date & Time"];
    Daterow.action.formSegueIdentifier = @"idSegueDateAndTime";
    [section addFormRow:Daterow];
    
    
    

XLFormRowDescriptor *    Locationrow = [XLFormRowDescriptor formRowDescriptorWithTag:kSelectors rowType:XLFormRowDescriptorTypeButton title:@"Location"];
    Locationrow.action.formSegueIdentifier=@"idSegueAddLocation";
    [section addFormRow:Locationrow];


    XLFormRowDescriptor *    weatherrow = [XLFormRowDescriptor formRowDescriptorWithTag:kSelectors rowType:XLFormRowDescriptorTypeButton title:@"Weather"];
    weatherrow.action.formSegueIdentifier=@"idSegueAddWeather";
    [section addFormRow:weatherrow];


        self.form = form;
    

    
}


@end
