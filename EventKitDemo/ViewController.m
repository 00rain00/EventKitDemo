//
//  ViewController.m
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"


@interface ViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;

@property (nonatomic, strong) NSArray *arrEvents;

@property (nonatomic, strong)NSArray *arrCalendars;

@property (nonatomic)BOOL isEditing;

-(void)loadEvents;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //request access to events
   
    // Do any additional setup after loading the view, typically from a nib.
    
    // Instantiate the appDelegate property.
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Make self the delegate and datasource of the table view.
    self.tblEvents.delegate = self;
    self.tblEvents.dataSource = self;

    [self performSelector:@selector(loadEvents) withObject:nil afterDelay:0.5];

}


- (void)loadEvents {
    if (self.appDelegate.eventManager.eventsAccessGranted) {
        DDLogDebug(@"access granted");
        NSArray * calendarsIdentifer  = @[self.calendarIdentifier];
        self.arrCalendars =[self.appDelegate.eventManager getCalendarBy:calendarsIdentifer];
        RETURN_WHEN_OBJECT_IS_EMPTY(self.arrCalendars);

        [self.appDelegate.eventManager callbackForFetchReminders:^(NSArray *reminders){

            self.arrEvents=reminders;
            for(EKCalendar *event in self.arrEvents){
                DDLogDebug(@"arrEvents: %@",event.title);}
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tblEvents reloadData];
            });

        }];

        [self.appDelegate.eventManager getRemembersOfSelectedCalendar:self.arrCalendars];


    }

}

-(void)createEvent{



    UITextField *textField= (UITextField *) [[self.tblEvents cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:10];
    [textField resignFirstResponder];
    RETURN_WHEN_OBJECT_IS_EMPTY(textField.text);

    EKCalendar *calendar = (EKCalendar *)self.arrCalendars.firstObject;

// 2
    EKReminder *reminder = [EKReminder reminderWithEventStore:self.appDelegate.eventManager.ekEventStore];
    reminder.title = textField.text;
    reminder.calendar = calendar;

    // 3
    NSError *error = nil;
    BOOL success = [self.appDelegate.eventManager.ekEventStore saveReminder:reminder commit:YES error:&error];
    if (!success) {
       FATAL_CORE_DATA_ERROR(error);
    }else{
        [self.tblEvents setEditing:NO animated:YES];

        [self loadEvents];
    }


    textField.text = @"";

}

#pragma mark - UItransction
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    DDLogDebug(@"");
    if ([segue.identifier isEqualToString:@"idSegueEvent"]) {


        UINavigationController *navigationController = segue.destinationViewController;
        EditEventViewController *controller = (EditEventViewController *)navigationController.topViewController;
        controller.delegate = self;


    }
//    if ([segue.identifier isEqualToString:@"idSegueCalendars"]) {
//        CalendarsViewController *calendarsViewController = [segue destinationViewController];
//        calendarsViewController.delegate = self;
//    }
}


#pragma mark - UITableView Delegate and Datasource method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(!self.tblEvents.isEditing){
        return self.arrEvents.count;
    }else{
        return self.arrEvents.count+1;
    }

}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellEvent"];
    if(self.tblEvents.isEditing){
        if(indexPath.row == 0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"idCellEdit"];
            UITextField *textField = (UITextField *)[cell viewWithTag:10];
            textField.delegate = self;
        }
    }
    if(!self.tblEvents.isEditing || (self.tblEvents.isEditing&& indexPath.row!=0)){
        NSInteger row = self.tblEvents.isEditing ? indexPath.row - 1 : indexPath.row;
        // Get each single event.
        EKReminder *event = self.arrEvents[(NSUInteger) row];

        // Set its title to the cell's text label.
        cell.textLabel.text = event.title;

        if (!self.tblEvents.isEditing) {
            cell.accessoryType = UITableViewCellAccessoryDetailButton;
        }
    }





    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    // Keep the identifier of the event that's about to be edited.
   NSString *reminderIdentifer = [self.arrEvents [(NSUInteger) indexPath.row] calendarItemIdentifier];
    self.appDelegate.eventManager.selectedEventIdentifier=reminderIdentifer;
    // Perform the segue.
    [self performSegueWithIdentifier:@"idSegueEvent" sender:self];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row==0){
        return UITableViewCellEditingStyleInsert;
    }else{
        return UITableViewCellEditingStyleDelete;
    }

}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    int numSession = [self.tblEvents numberOfSections];
    int numRow = 0;
    for (int i = 0; i <numSession ; ++i) {
         numRow += [self.tblEvents numberOfRowsInSection:i];
    }


    if(editingStyle == UITableViewCellEditingStyleInsert){
      [self createEvent];
  }


    if (editingStyle == UITableViewCellEditingStyleDelete) {


        // Delete the selected event.
        NSError *error;
       // [self.appDelegate.eventManager deleteEventWithIdentifier:[self.arrEvents[(NSUInteger) indexPath.row] eventIdentifier]];
        NSInteger row = (self.arrEvents.count==numRow)? indexPath.row:indexPath.row-1;
       EKReminder *ekReminder = self.arrEvents[row];
        [self.appDelegate.eventManager.ekEventStore removeReminder:ekReminder commit:YES error:&error];
        if(OBJECT_ISNOT_EMPTY(error)){
            FATAL_CORE_DATA_ERROR(error);
        }
        // Reload all events and the table view.
        [self loadEvents];
    }
}


#pragma mark - EditEventViewControllerDelegate method implementation

-(void)eventWasSuccessfullySaved{
    [self loadEvents];
}


#pragma mark - IBAction method implementation

- (IBAction)showCalendars:(id)sender {
    if(self.appDelegate.eventManager.eventsAccessGranted){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)editEvent:(id)sender {
    [self.tblEvents setEditing:!self.tblEvents.isEditing animated:YES];
    [self.tblEvents reloadData];
}

#pragma mark - UITextFieldDelegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self createEvent];
    return YES;
}




@end
