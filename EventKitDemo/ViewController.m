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

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //request access to events
    [self performSelector:@selector(requestAccessToEvents) withObject:nil afterDelay:0.5];
    [self performSelector:@selector(requestAccessToReminders) withObject:nil afterDelay:1];

    // Do any additional setup after loading the view, typically from a nib.
    
    // Instantiate the appDelegate property.
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Make self the delegate and datasource of the table view.
    self.tblEvents.delegate = self;
    self.tblEvents.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    DDLogDebug(@"");
    if ([segue.identifier isEqualToString:@"idSegueEvent"]) {
        EditEventViewController *editEventViewController = [segue destinationViewController];
        editEventViewController.delegate = self;
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
    return 0;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}


#pragma mark - EditEventViewControllerDelegate method implementation

-(void)eventWasSuccessfullySaved{
    
}


#pragma mark - IBAction method implementation

- (IBAction)showCalendars:(id)sender {
    if(self.appDelegate.eventManager.eventsAccessGranted){
        [self performSegueWithIdentifier:@"idSegueCalendars" sender:self];
    }
}

- (IBAction)createEvent:(id)sender {
    if(self.appDelegate.eventManager.eventsAccessGranted){
        [self performSegueWithIdentifier:@"idSegueEvent" sender:self];
    }
    
}

- (void)requestAccessToEvents {
    [self.appDelegate.eventManager.ekEventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){
        if(OBJECT_IS_EMPTY(error)){
            self.appDelegate.eventManager.eventsAccessGranted=granted;
        }else{
            FATAL_CORE_DATA_ERROR(error);
        }
    }];
    
    

}

- (void)requestAccessToReminders {
    [self.appDelegate.eventManager.ekEventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error){
        if(OBJECT_IS_EMPTY(error)){
         DDLogInfo(@"reminder access Yes");
        }else{
            FATAL_CORE_DATA_ERROR(error);
        }
    }];

}


@end
