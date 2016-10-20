//
//  ContactViewController.m
//  EventKitDemo
//
//  Created by YULIN CAI on 16/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "ContactViewController.h"
NSString * const kAnyNewContact = @"Any New Contact";
@interface ContactViewController ()

@end

@implementation ContactViewController

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


    section = [XLFormSectionDescriptor formSectionWithTitle:@"Contacts"];
    [form addFormSection:section];

    XLFormRowDescriptor *  row = [XLFormRowDescriptor formRowDescriptorWithTag:kAnyNewContact rowType:XLFormRowDescriptorTypeButton title:kAnyNewContact];
    
    

    row.action.formBlock=^(XLFormRowDescriptor *sender){
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
       
    };


    [section addFormRow:row];



    self.form = form;



}


@end
