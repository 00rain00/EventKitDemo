//
//  AddConditionViewController.m
//  EventKitDemo
//
//  Created by YULIN CAI on 16/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "AddConditionViewController.h"

NSString * const kDates = @"Date";
NSString * const kSelectors = @"Selectors";
NSString * const kFormatters = @"Formatters";
NSString * const  kPhoto = @"Photo";
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
    
    
    

XLFormRowDescriptor *    Locationrow = [XLFormRowDescriptor formRowDescriptorWithTag:kDates rowType:XLFormRowDescriptorTypeButton title:@"Location"];
    Locationrow.action.formSegueIdentifier=@"idSegueAddLocation";
    [section addFormRow:Locationrow];

 XLFormRowDescriptor *   Contactsrow = [XLFormRowDescriptor formRowDescriptorWithTag:kFormatters rowType:XLFormRowDescriptorTypeButton title:@"Contacts"];
    Contactsrow.action.formSegueIdentifier=@"idSegueContacts";
    [section addFormRow:Contactsrow];
    
XLFormRowDescriptor *    Photorow = [XLFormRowDescriptor formRowDescriptorWithTag:kPhoto rowType:XLFormRowDescriptorTypeButton title:@"photo"];
    Photorow.action.formSegueIdentifier=@"idSeguePhotos";
    [section addFormRow:Photorow];
        self.form = form;
    

    
}


@end
