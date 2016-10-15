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

@interface EditEventViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;

@property (nonatomic, strong) NSString *eventTitle;

@property (nonatomic, strong) NSDate *eventStartDate;

@property (nonatomic, strong) NSDate *eventEndDate;

@property (nonatomic, strong)NSString *enentCalender;

@property (nonatomic, strong) NSMutableArray *arrAlarms;

@property (nonatomic, strong)EKAlarm *ekAlarm;

@property (nonatomic, strong)EKReminder *editedEvent;

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
    self.eventStartDate=nil;
    self.eventEndDate=nil;

    self.arrAlarms= [NSMutableArray new];

    if (self.appDelegate.eventManager.selectedEventIdentifier.length > 0) {
        DDLogDebug(@"event identifier : %@",self.appDelegate.eventManager.selectedEventIdentifier);
        self.editedEvent = (EKReminder *) [self.appDelegate.eventManager.ekEventStore calendarItemWithIdentifier:self.appDelegate.eventManager.selectedEventIdentifier];

        self.eventTitle = self.editedEvent.title;
        [self.arrAlarms addObjectsFromArray:self.editedEvent.alarms];
        for(EKAlarm * alarm1 in self.arrAlarms){
//            if(OBJECT_ISNOT_EMPTY(alarm1.absoluteDate)){
//                DDLogDebug(@"%@,",[NSDate stringForDisplayFromDate:alarm1.absoluteDate]);
//            }
//
//            DDLogDebug(@"%f,%f",alarm1.structuredLocation.geoLocation.coordinate.latitude,alarm1.structuredLocation.geoLocation.coordinate.longitude);
//            DDLogDebug(@"%f",alarm1.structuredLocation.radius);
//            DDLogDebug(@"arriving : %d",alarm1.proximity);
        }
        DDLogDebug(@"event title : %@",self.eventTitle);
           }else{
        DDLogDebug(@"no selected event ");
    }
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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"idSegueDatepicker"]) {
        DatePickerViewController *datePickerViewController = [segue destinationViewController];
        datePickerViewController.delegate = self;
    }
//TODO complete viewcontroller
    if ([segue.identifier isEqualToString:@"idSegueCalender"]) {

    }
    if ([segue.identifier isEqualToString:@"idSegueAddAlarm"]) {
        AddAlarm *controller = segue.destinationViewController;

        controller.delegate=self;
    }
    if([segue.identifier isEqualToString:@"idSegueLocation"]){
        AddLocationViewController *controller  = segue.destinationViewController;
        controller.delegate=self;
    }
    if([segue.identifier isEqualToString:@"idSegueWeather"]){
        AddWeatherViewController *controller  = segue.destinationViewController;
        controller.delegate=self;
    }
}


#pragma mark - UITableView Delegate and Datasource method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 5;
    }
    else{
        return 3;
    }
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"Event Settings";
    }
    else {
        return @"Alarms";
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        // If the cell is nil, then dequeue it. Make sure to dequeue the proper cell based on the row.
        if (OBJECT_IS_EMPTY(cell)) {
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"idCellTitle"];
            }
            else{
                cell = [tableView dequeueReusableCellWithIdentifier:@"idCellGeneral"];
            }
        }
        switch(indexPath.row){
            case 0: {
                UITextField *titleTextfile = (UITextField *) [cell.contentView viewWithTag:10];
                titleTextfile.delegate = self;
                titleTextfile.text=self.eventTitle;

            }
                break;
            case 1:{

                if(OBJECT_IS_EMPTY(self.enentCalender)){
                    cell.textLabel.text=@"Select a calender";
                }else{
                    //TODO better call in the services layer
                    cell.textLabel.text= self.enentCalender;

                }
            }

            break;
            case 2:
            {
                if(OBJECT_IS_EMPTY(self.eventStartDate)){
                    cell.textLabel.text=@"Select a start date...";
                }else{
                    cell.textLabel.text= [self.appDelegate.eventManager getStringFromDate:self.eventStartDate];

                }


            }
                break;
            case 3:
            {
                if(OBJECT_IS_EMPTY(self.eventEndDate)){
                    cell.textLabel.text=@"Select an end date...";
                }else{
                    cell.textLabel.text= [self.appDelegate.eventManager getStringFromDate:self.eventEndDate];
                }
            }
                break;
            case 4:{
                if(OBJECT_IS_EMPTY(self.ekAlarm)){
                    cell.textLabel.text=@"Select a notification...";
                }else{
                    cell.textLabel.text= [self.appDelegate.eventManager getStringFromDate:self.ekAlarm.absoluteDate];
                }
            }
                break;

            default:
                break;
        }
    }
    else{
        if (OBJECT_IS_EMPTY(cell)) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idCellGeneral"];
        }
        switch (indexPath.row){
            case 0 : {
                cell.textLabel.text = @"Add a new time alarm...";
            }
                break;
            case 1: {
                cell.textLabel.text = @"add a new location alarm...";
            }
                break;
            case 2: {
                cell.textLabel.text = @"add a new weather alarm...";
            }
                break;
            default:
                break;
        }




    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogDebug(@"section :%ld ,  row :%ld",(long)indexPath.section, (long)indexPath.row);
    if(indexPath.section==0&&indexPath.row==1){
        [self performSegueWithIdentifier:@"idSegueCalender" sender:self];
    }

    if(indexPath.section==0&&(indexPath.row==3 || indexPath.row==2)){

        [self performSegueWithIdentifier:@"idSegueDatepicker" sender:self];
    }

    if(indexPath.section==0&&indexPath.row==4){

        [self performSegueWithIdentifier:@"idSegueCreateAlarm" sender:self];
    }
    
    if(indexPath.section==1&&indexPath.row==0){
        [self performSegueWithIdentifier:@"idSegueAddAlarm" sender:self ];
    }
    if(indexPath.section==1&&indexPath.row==1){
        [self performSegueWithIdentifier:@"idSegueLocation" sender:self ];
    }
    if(indexPath.section==1&&indexPath.row==2){
        [self performSegueWithIdentifier:@"idSegueWeather" sender:self ];
    }



}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}


#pragma mark - IBAction method implementation

- (IBAction)saveEvent:(id)sender {
    if(self.eventTitle.length==0){
        DDLogDebug(@"empty title");
        return;
    }


//    if (self.appDelegate.eventManager.selectedEventIdentifier.length > 0) {
//        [self.appDelegate.eventManager deleteEventWithIdentifier:self.appDelegate.eventManager.selectedEventIdentifier];
//        self.appDelegate.eventManager.selectedEventIdentifier = @"";
//    }
    DDLogDebug(@"eventTitle:%@",self.eventTitle);
    self.editedEvent.title = self.eventTitle;
//    EKEvent *event= [EKEvent eventWithEventStore:self.appDelegate.eventManager.ekEventStore];
//
//
//    event.title=self.eventTitle;
//    event.startDate=self.eventStartDate;
//    event.endDate=self.eventEndDate;
//    NSArray * alCalenders = [self.appDelegate.eventManager.ekEventStore calendarsForEntityType:EKEntityTypeEvent];
//
//    for (EKCalendar * calendar in alCalenders) {
//        if([calendar.calendarIdentifier isEqualToString:self.appDelegate.eventManager.selectedCalenderIdentifier]){
//            event.calendar= calendar;
//            break;
//        }
//    }



    NSError *error;
    if([self.appDelegate.eventManager.ekEventStore saveReminder:self.editedEvent commit:YES error:&error]){
        [self.delegate eventWasSuccessfullySaved];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        FATAL_CORE_DATA_ERROR(error);
    }
    [self.tblEvent reloadData];
}


#pragma mark - UITextFieldDelegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    DDLogInfo(@"");
    self.eventTitle=textField.text;
    DDLogDebug(@"event title :%@",self.eventTitle);
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - DatePickerViewControllerDelegate method implementation

-(void)dateWasSelected:(NSDate *)selectedDate{
    NSIndexPath *indexPath= [self.tblEvent indexPathForSelectedRow];
    if(indexPath.section==0){
        if(indexPath.row==2){
            self.eventStartDate=selectedDate;
        }else if (indexPath.row==3){
            self.eventEndDate=selectedDate;
        }
    }

    [self.tblEvent reloadData];
}

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
