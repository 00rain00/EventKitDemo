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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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
    return self.arrEvents.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellEvent"];

    // Get each single event.
    EKReminder *event = self.arrEvents[(NSUInteger) indexPath.row];

    // Set its title to the cell's text label.
    cell.textLabel.text = event.title;

    // Get the event start date as a string value.
 //   NSString *startDateString = [self.appDelegate.eventManager getStringFromDate:event.startDate];

    // Get the event end date as a string value.
 //   NSString *endDateString = [self.appDelegate.eventManager getStringFromDate:event.endDate];

    // Add the start and end date strings to the detail text label.
 //   cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", startDateString, endDateString];

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

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the selected event.
        [self.appDelegate.eventManager deleteEventWithIdentifier:[self.arrEvents[(NSUInteger) indexPath.row] eventIdentifier]];

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

- (IBAction)createEvent:(id)sender {
    
}


- (void)loadEvents {
    if (self.appDelegate.eventManager.eventsAccessGranted) {
        DDLogDebug(@"access granted");
        NSArray * calendarsIdentifer  = @[self.calendarIdentifier];
        NSArray *arrCalender =[self.appDelegate.eventManager getCalendarBy:calendarsIdentifer];
       
        [self.appDelegate.eventManager callbackForFetchReminders:^(NSArray *reminders){
            DDLogDebug(@"call back executed");
            self.arrEvents=reminders;
            for(EKCalendar *event in self.arrEvents){
                DDLogDebug(@"arrEvents: %@",event.title);}
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tblEvents reloadData];
            });

        }];
        [self.appDelegate.eventManager getRemembersOfSelectedCalendar:arrCalender];


    }

}


@end
