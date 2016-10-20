//
//  ViewController.h
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditEventViewController.h"
#import "CalendarsViewController.h"
@class Reminder;
@interface ViewController : UIViewController <EditEventViewControllerDelegate, UITableViewDelegate, UITableViewDataSource,NSFetchedResultsControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblEvents;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)EKCalendar *selectedCalendar;
@property (nonatomic, strong)EKReminder *selectedEvent;

- (IBAction)showCalendars:(id)sender;

- (IBAction)editEvent:(id)sender;





@end
