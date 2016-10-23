//
//  ContactViewController.m
//  EventKitDemo
//
//  Created by YULIN CAI on 16/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "ContactViewController.h"
NSString * const kAnyNewContact = @"Any New Contact Switch";
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
        NSString *reminderID  = [[NSUserDefaults standardUserDefaults] valueForKey:@"selected_reminder_identifier"];
        if([self saveValidation:reminderID]){
            __weak typeof(self) weakSelf=self;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ooops" message:@"We found that there is/are condition(s) repeating! \n Please delete the exsit one then add a new condition" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction){
                [weakSelf.navigationController popToViewController:[weakSelf.navigationController.viewControllers objectAtIndex:0] animated:YES];

            }]];
            [alertController show];
        }else{
            CoreDataService *coreDataService = [[CoreDataService alloc] init];
            NSData *myValue = [NSKeyedArchiver archivedDataWithRootObject:@(YES)];
            [coreDataService createCondition:reminderID :kAnyNewContact :myValue];
            coreDataService = nil;
            [weakSelf.navigationController popToViewController:[weakSelf.navigationController.viewControllers objectAtIndex:0] animated:YES];

        }






    };


    [section addFormRow:row];



    self.form = form;



}

-(BOOL)saveValidation:(NSString *)reminderID{
    BOOL flag  = NO;
    CoreDataService *coreDataService = [[CoreDataService alloc] init];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Condition"];
    NSString * ID =reminderID;
    NSPredicate * predicate =  [NSPredicate predicateWithFormat:@"myReminderID == %@",ID];
    [request setPredicate:predicate];
    NSArray *result =  [coreDataService fetchCondition:request];
    for(Condition * condition in result){
        if([condition.myKey isEqualToString:kAnyNewContact]){
            flag = YES;
            break;
        }
    }
    coreDataService=nil;
    return flag;
}


@end
