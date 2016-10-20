//
//  EditEventViewController.m
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "EditEventViewController.h"
#import "AddAlarm.h"
#import "AppDelegate.h"
#import <FFGlobalAlertController/UIAlertController+Window.h>
#import "UIAlertController+Window.h"
#import "NSDate+Helper.h"
@interface EditEventViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;

@property (nonatomic, strong) NSString *eventTitle;

@property (nonatomic, strong) NSMutableArray *arrAlarms;

@property (nonatomic, strong)EKAlarm *ekAlarm;

@property (nonatomic, strong)CoreDataService *coreDataService;

@property (nonatomic, strong)NSMutableArray *arrCondition;

@end

@implementation EditEventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Instantiate the appDelegate property, so we can access its eventManager property.
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Make self the delegate and datasource of the table view.
    self.tblEvent.delegate = self;
    self.tblEvent.dataSource = self;

    self.coreDataService = [[CoreDataService alloc] init];

    self.arrAlarms= [NSMutableArray new];
    self.arrCondition = [NSMutableArray new];
    RETURN_WHEN_OBJECT_IS_EMPTY(self.editedEvent);


        self.eventTitle = self.editedEvent.title;
        [self.arrAlarms addObjectsFromArray:self.editedEvent.alarms];

    [self.arrCondition addObjectsFromArray:[self fetchCondition:self.editedEvent.calendarItemIdentifier]];
        DDLogDebug(@"arr condtion count : %d",self.arrCondition.count);
    //    for(EKAlarm * alarm1 in self.arrAlarms){
//            if(OBJECT_ISNOT_EMPTY(alarm1.absoluteDate)){
//                DDLogDebug(@"%@,",[NSDate stringForDisplayFromDate:alarm1.absoluteDate]);
//            }
//
//            DDLogDebug(@"%f,%f",alarm1.structuredLocation.geoLocation.coordinate.latitude,alarm1.structuredLocation.geoLocation.coordinate.longitude);
//            DDLogDebug(@"%f",alarm1.structuredLocation.radius);
//            DDLogDebug(@"arriving : %d",alarm1.proximity);
 //       }

   // }




}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:self.editedEvent.calendarItemIdentifier forKey:@"selected_reminder_identifier"];

}


#pragma mark - UITableView Delegate and Datasource method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

        return self.arrCondition.count+1;


}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

        return @"Event Settings";

}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    

        // If the cell is nil, then dequeue it. Make sure to dequeue the proper cell based on the row.

            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"idCellTitle"];
                UITextField *titleTextfile = (UITextField *) [cell.contentView viewWithTag:10];
                titleTextfile.delegate = self;
                titleTextfile.text=self.editedEvent.title;
            }
            else{
                cell = [tableView dequeueReusableCellWithIdentifier:@"idCellCondition"];
                UILabel * key = (UILabel *)[cell.contentView viewWithTag:1];
                key.text= [(Condition *) self.arrCondition[(NSUInteger) (indexPath.row - 1)] myKey];
                UISwitch *status = (UISwitch *) [cell.contentView viewWithTag:3];
                status.on = [[(Condition *) self.arrCondition[(NSUInteger) (indexPath.row - 1)] sattus]boolValue];
//                UILabel * value = (UILabel *)[cell.contentView viewWithTag:1];
//                value.text= [(Condition *) self.arrCondition[indexPath.row - 1] myKey];
            }








    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {



}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if(editingStyle == UITableViewCellEditingStyleDelete){
     // [self deleteCondition];
  }
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    //config the button at leftside
    if(indexPath.row==0){
        return UITableViewCellEditingStyleNone;
    }else{
        return UITableViewCellEditingStyleDelete;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}


#pragma mark - IBAction method implementation

- (IBAction)saveEvent:(id)sender {
    if(OBJECT_IS_EMPTY(self.eventTitle)){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Ooops" message:@"Title is empty" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
        [alert show];
        return;

    }
    DDLogDebug(@"eventTitle:%@",self.eventTitle);
    [self dismissViewControllerAnimated:YES completion:nil];

    self.editedEvent.title = self.eventTitle;
    //TODO start engine
    self.appDelegate.engineService.setUpClipsEnvironment;

    //TODO push facts fo engine
    NSDictionary *facts = [NSDictionary new];
    facts = @{@"time": [NSDate new]};
    [self.appDelegate.engineService generateFacts:facts];
    //TODO PUSH rules to engine
    NSDictionary *rules  = [NSDictionary new];
    [self.appDelegate.engineService transformRules:facts];
    //TODO EVALUE RESULT
    //TODO ADD alarm to reminder


    NSError *error;
    if([self.appDelegate.eventManager.ekEventStore saveReminder:self.editedEvent commit:YES error:&error]){
        [self.delegate eventWasSuccessfullySaved];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        FATAL_CORE_DATA_ERROR(error);
    }
    [self.tblEvent reloadData];
}

- (IBAction)NewCondition:(id)sender {
    [self performSegueWithIdentifier:@"idSegueCreateCondition" sender:self ];
}

- (IBAction)cancle:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)deleteCondition:(NSUInteger)objectIndex {
    //Todo DELETE the object in database than delete the obj in arrCondition
    [self.arrCondition removeObjectAtIndex:objectIndex];
}

- (NSArray *)fetchCondition:(NSString *)reminderID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Condition"];
    NSString * ID =self.editedEvent.calendarItemIdentifier;
    NSPredicate * predicate =  [NSPredicate predicateWithFormat:@"myReminderID == %@",ID];
    [request setPredicate:predicate];

         return  [self.coreDataService fetchCondition:request];

}


#pragma mark - UITextFieldDelegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField{

    self.eventTitle=textField.text;

    [textField resignFirstResponder];
    return YES;
}


#pragma mark - DatePickerViewControllerDelegate method implementation



- (void)addAlarm:(AddAlarm *)controller didFinishCreateAlarm:(EKAlarm *)item {
    [self.editedEvent addAlarm:item];
}

- (void)addAlarm:(AddAlarm *)controller test:(NSString *)string {

}

- (void)addLocation:(AddLocationViewController *)controller didFinishAdding:(EKAlarm *)item {
    [self.editedEvent addAlarm:item];
}

- (void)addWeatherViewController:(AddWeatherViewController *)controller :(EKAlarm *)item {

}


@end
