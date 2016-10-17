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
@interface ViewController : UIViewController <EditEventViewControllerDelegate, UITableViewDelegate, UITableViewDataSource,NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblEvents;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,copy)NSString * calendarIdentifier;

- (IBAction)showCalendars:(id)sender;

- (IBAction)createEvent:(id)sender;



@end
