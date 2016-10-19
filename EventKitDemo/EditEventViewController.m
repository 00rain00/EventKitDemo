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

    LOG_EMPTY_WHEN_OBJECT_IS_EMPTY(self.editedEvent);


        self.eventTitle = self.editedEvent.title;
        [self.arrAlarms addObjectsFromArray:self.editedEvent.alarms];
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
    //if there is no condition, create a new on



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


}


#pragma mark - UITableView Delegate and Datasource method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

        return 5;


}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

        return @"Event Settings";

}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        // If the cell is nil, then dequeue it. Make sure to dequeue the proper cell based on the row.

            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"idCellTitle"];
            }
            else{
                cell = [tableView dequeueReusableCellWithIdentifier:@"idCellCondition"];
            }

        switch(indexPath.row){
            case 0: {
                UITextField *titleTextfile = (UITextField *) [cell.contentView viewWithTag:10];
                titleTextfile.delegate = self;
                titleTextfile.text=self.editedEvent.title;

            }
                break;
            case 1:{

                    UILabel * label = (UILabel *)[cell.contentView viewWithTag:1];
                    label.text=@"Every Day at 0700 to 0800";

            }

            break;
            case 2:
            {
                UILabel * label = (UILabel *)[cell.contentView viewWithTag:1];

                    label.text=@"Arriving range at ...";


            }
                break;


            default:
                break;
        }
    }

    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
DDLogDebug(@"");


}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if(editingStyle == UITableViewCellEditingStyleDelete){
      [self deleteCondition];
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

- (void)deleteCondition {
        DDLogDebug(@"");
}

- (NSArray *)fetchCondition:(NSString *)reminderID {
    return nil;
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
