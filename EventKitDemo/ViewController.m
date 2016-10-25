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
    self.tblEvents.rowHeight = UITableViewAutomaticDimension;
    self.tblEvents.estimatedRowHeight = 60.0;
    [self performSelector:@selector(loadEvents) withObject:nil afterDelay:0.5];

}


- (void)loadEvents {
    if (self.appDelegate.eventManager.eventsAccessGranted) {
        DDLogDebug(@"access granted");


        RETURN_WHEN_OBJECT_IS_EMPTY(self.selectedCalendar);

        [self.appDelegate.eventManager callbackForFetchReminders:^(NSArray *reminders){

            self.arrEvents=reminders;
            for(EKCalendar *event in self.arrEvents){
                DDLogDebug(@"arrEvents: %@",event.title);}
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tblEvents reloadData];
            });

        }];
        NSArray *calenders = @[self.selectedCalendar];
        [self.appDelegate.eventManager getRemembersOfSelectedCalendar:calenders];


    }

}

-(void)createEvent{



    UITextField *textField= (UITextField *) [[self.tblEvents cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:10];
    [textField resignFirstResponder];
    RETURN_WHEN_OBJECT_IS_EMPTY(textField.text);



// 2
    EKReminder *reminder = [EKReminder reminderWithEventStore:self.appDelegate.eventManager.ekEventStore];
    reminder.title = textField.text;
    reminder.calendar = self.selectedCalendar;

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

    if ([segue.identifier isEqualToString:@"idSegueEvent"]) {
        LOG_EMPTY_WHEN_OBJECT_IS_EMPTY(self.selectedEvent);

        UINavigationController *navigationController = segue.destinationViewController;
        EditEventViewController *controller = (EditEventViewController *)navigationController.topViewController;
        controller.delegate = self;
        controller.editedEvent = self.selectedEvent;

    }

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



-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    // Keep the identifier of the event that's about to be edited.
   NSString *reminderIdentifer = [self.arrEvents [(NSUInteger) indexPath.row] calendarItemIdentifier];
    self.appDelegate.eventManager.selectedEventIdentifier=reminderIdentifer;
  self.selectedEvent = self.arrEvents[indexPath.row];
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
       EKReminder *ekReminder = self.arrEvents[(NSUInteger) row];
        [self.appDelegate.eventManager.ekEventStore removeReminder:ekReminder commit:YES error:&error];
        if(OBJECT_ISNOT_EMPTY(error)){
            FATAL_CORE_DATA_ERROR(error);
        }
        // Reload all events and the table view.
        [self loadEvents];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedEvent = self.arrEvents[(NSUInteger) indexPath.row];
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
