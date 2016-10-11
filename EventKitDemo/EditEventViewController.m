//
//  EditEventViewController.m
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "EditEventViewController.h"
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
        DDLogDebug(@"event title : %@",self.eventTitle);
       // self.eventStartDate = self.editedEvent.startDate;
       // self.eventEndDate = self.editedEvent.endDate;
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
        return self.arrAlarms.count +1;
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
        if(indexPath.row ==0){
            cell.textLabel.text = @"Add a new alarm...";
        }else{
            cell.textLabel.text = [self.appDelegate.eventManager getStringFromDate:self.arrAlarms[indexPath.row-1] ];
            // No selection for the alarm cells.
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            // No accessory style.
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0&&indexPath.row==1){
        [self performSegueWithIdentifier:@"idSegueCalender" sender:self];
    }

    if(indexPath.section==0&&(indexPath.row==3 || indexPath.row==2)){

        [self performSegueWithIdentifier:@"idSegueDatepicker" sender:self];
    }

    if(indexPath.section==0&&indexPath.row==4){

        [self performSegueWithIdentifier:@"idSegueCreateAlarm" sender:self];
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
    if(OBJECT_IS_EMPTY(self.eventEndDate)||OBJECT_IS_EMPTY(self.eventStartDate)){
        DDLogDebug(@"empty end or start date");
        return;
    }

    if (self.appDelegate.eventManager.selectedEventIdentifier.length > 0) {
        [self.appDelegate.eventManager deleteEventWithIdentifier:self.appDelegate.eventManager.selectedEventIdentifier];
        self.appDelegate.eventManager.selectedEventIdentifier = @"";
    }
    EKEvent *event= [EKEvent eventWithEventStore:self.appDelegate.eventManager.ekEventStore];

    
    event.title=self.eventTitle;
    event.startDate=self.eventStartDate;
    event.endDate=self.eventEndDate;
    NSArray * alCalenders = [self.appDelegate.eventManager.ekEventStore calendarsForEntityType:EKEntityTypeEvent];
    
    for (EKCalendar * calendar in alCalenders) {
        if([calendar.calendarIdentifier isEqualToString:self.appDelegate.eventManager.selectedCalenderIdentifier]){
            event.calendar= calendar;
            break;
        }
    }
    
    

    NSError *error;
    if([self.appDelegate.eventManager.ekEventStore saveEvent:event span:EKSpanFutureEvents commit:YES error:&error]){
        [self.delegate eventWasSuccessfullySaved];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        FATAL_CORE_DATA_ERROR(error);
    }

}


#pragma mark - UITextFieldDelegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField{

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
//    if(indexPath.section ==1){
//        [self.arrAlarms addObject:selectedDate];
//    }

    [self.tblEvent reloadData];
}


@end
