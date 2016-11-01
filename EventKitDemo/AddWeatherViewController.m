//
//  AddWeatherViewController.m
//  EventKitDemo
//
//  Created by YULIN CAI on 15/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//



#import "AddWeatherViewController.h"
NSString * const kWeatherDetails  = @"Weather";
NSString * const kforecastTime = @"forecastTime";
NSString * const kforecastType = @"forecastType";

@interface AddWeatherViewController ()
@property(nonatomic,strong)CoreDataService *cd ;
@end

@implementation AddWeatherViewController

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
  

    section = [XLFormSectionDescriptor formSectionWithTitle:@"Weather"];
    [form addFormSection:section];





   XLFormRowDescriptor * row = [XLFormRowDescriptor formRowDescriptorWithTag:kforecastTime rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"Time Interval"];
    row.selectorOptions = @[@"Tomorrow", @"Next 3 hours"];
    row.value = @"Tomorrow";
    [section addFormRow:row];


    XLFormRowDescriptor * row2 = [XLFormRowDescriptor formRowDescriptorWithTag:kforecastType rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:@"weather type"];
    row2.selectorOptions = @[@"Clear Sky", @"Cloudy", @"Rainy"];
    row2.value = @"Clear Sky";
    [section addFormRow:row2];
    self.form = form;



}

- (IBAction)save:(id)sender {

    NSString *reminderID = [[NSUserDefaults standardUserDefaults] valueForKey:@"selected_reminder_identifier"];
    if(OBJECT_IS_EMPTY(reminderID)){
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
    }else {
        if([self saveValidation:reminderID]){
            __weak typeof(self) weakSelf=self;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ooops" message:@"We found that there is/are condition(s) repeating! \n Please delete the exsit one then add a new condition" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction){
                [weakSelf.navigationController popToViewController:[weakSelf.navigationController.viewControllers objectAtIndex:0] animated:YES];

            }]];
            [alertController show];
        }else{

            CoreDataService *coreDataService = [[CoreDataService alloc] init];
            NSDictionary *formDic = [self formValues];



             LOOP_DICTIONARY(formDic);
//             BOOL alldaySwitch = [formDic[kallDay] boolValue];
//              BOOL endtimeSwitch = [formDic[kendTimeSwitch] boolValue];
//        for(NSString *key in formDic) {
//            if ([key isEqualToString:kendTimeSwitch]) {
//                continue;
//            } else if ([key isEqualToString:kallDay] && OBJECT_ISNOT_EMPTY(formDic[kstartTime])) {
//                continue;
//            }
//            DDLogDebug(@"%@is array :%d",key, [formDic[key] isKindOfClass:[NSArray class]]);
//            DDLogDebug(@"%@is Marray :%d",key, [formDic[key] isKindOfClass:[NSMutableArray class]]);
//            DDLogDebug(@"%@is Dic :%d",key, [formDic[key] isKindOfClass:[NSDictionary class]]);


            NSData *myValue = [NSKeyedArchiver archivedDataWithRootObject:formDic];
            [coreDataService createCondition:reminderID :kWeatherDetails :myValue];
            //}

            coreDataService = nil;
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];

        }
    }

}


-(BOOL)saveValidation:(NSString *)reminderID{
    BOOL flag  = NO;
   
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Condition"];
    NSString * ID =reminderID;
    NSPredicate * predicate =  [NSPredicate predicateWithFormat:@"myReminderID == %@",ID];
    [request setPredicate:predicate];
    NSArray *result =  [self.cd fetchCondition:request];
    for(Condition * condition in result){
        if([condition.myKey isEqualToString:kWeatherDetails]){
            flag = YES;
            break;
        }
    }
        return flag;
}


@end
