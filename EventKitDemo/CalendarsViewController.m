//
//  CalendarsViewController.m
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <FFGlobalAlertController/UIAlertController+Window.h>
#import "UIAlertController+Window.h"
#import "CalendarsViewController.h"
#import "AppDelegate.h"





@interface CalendarsViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong)NSArray *calendars;
@property (nonatomic)NSUInteger  indexOfCalendarToDelete;
-(void)loadEventCalendars;
-(void)createCalendar;
-(void)confirmCalendarDeletion;
@end

@implementation CalendarsViewController



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
    
    // Make self the delegate and datasource of the table view.
    [self performSelector:@selector(requestAccessToEvents) withObject:nil afterDelay:0.5];
    [self performSelector:@selector(requestAccessToReminders) withObject:nil afterDelay:1];

    
    self.tblCalendars.delegate = self;
    self.tblCalendars.dataSource = self;
    
    // Instantiate the appDelegate property.
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self loadEventCalendars];

    // register change in photo library


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
            dispatch_async(dispatch_get_main_queue(), ^{

            });


        }else{
            FATAL_CORE_DATA_ERROR(error);
        }
    }];
    
}

-(int)selectRow:(UITableView *)table{
    int numSession = [table numberOfSections];
    int numRow = 0;
    for (int i = 0; i <numSession ; ++i) {
        numRow += [table numberOfRowsInSection:i];
    }
return numRow;
}



- (void)loadEventCalendars {


   LOG_EMPTY_WHEN_OBJECT_IS_EMPTY(self.appDelegate.eventManager);
    self.calendars= [self.appDelegate.eventManager getiCloudReminders];
    [self.tblCalendars reloadData];
}

- (void)createCalendar {
    //get textfield
    UITextField *textField= (UITextField *) [[self.tblCalendars cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:10];
    [textField resignFirstResponder];
    RETURN_WHEN_OBJECT_IS_EMPTY(textField.text);

    EKCalendar *calendar = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.appDelegate.eventManager.ekEventStore];
    calendar.title = textField.text;


    for(int i = 0; i<self.appDelegate.eventManager.ekEventStore.sources.count;i++){
        EKSource *source = self.appDelegate.eventManager.ekEventStore.sources[i];
        EKSourceType ekSourceType = source.sourceType;

        if(ekSourceType == EKSourceTypeLocal){
            calendar.source  = source;
            NSError *error;
            [self.appDelegate.eventManager.ekEventStore saveCalendar:calendar commit:YES error:&error];
            if(OBJECT_IS_EMPTY(error)){
                [self.tblCalendars setEditing:NO animated:YES];
                [self.appDelegate.eventManager saveCustomerCalendarIdentifier:calendar.calendarIdentifier];
                [self loadEventCalendars];
            }else{
                FATAL_CORE_DATA_ERROR(error);
            }
        }
    }
    textField.text = @"";
}

- (void)confirmCalendarDeletion {
    NSString *identifier = [self.calendars[self.indexOfCalendarToDelete] calendarIdentifier];

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Are you sure to delete this list?" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
        __weak typeof(self) weakSelf=self;
        [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            EKCalendar *calendarToDelete = weakSelf.calendars[weakSelf.indexOfCalendarToDelete];

            NSError *error;
            if([weakSelf.appDelegate.eventManager.ekEventStore removeCalendar:calendarToDelete commit:YES error:&error]){
                if([weakSelf.appDelegate.eventManager.selectedCalenderIdentifier isEqualToString:identifier]){
                    weakSelf.appDelegate.eventManager.selectedCalenderIdentifier=@"";
                }
                [weakSelf.appDelegate.eventManager removeCalendarIdentifier:identifier];
                [weakSelf loadEventCalendars];
            }else{
                FATAL_CORE_DATA_ERROR(error);
            }

        }]];
        [alert show];

}





#pragma mark - UITableView Delegate and Datasource method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //DDLogInfo(@"calendars count:%lu", (unsigned long)[self.calendars count]);
   if(!self.tblCalendars.isEditing){
       return self.calendars.count;
   }else{
       return self.calendars.count+1;
   }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellCalendar"];

    if (self.tblCalendars.isEditing) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"idCellEdit"];

            UITextField *textfield = (UITextField *)[cell viewWithTag:10];
            textfield.delegate = self;
        }
    }

    if (!self.tblCalendars.isEditing || (self.tblCalendars.isEditing && indexPath.row != 0)) {
        NSInteger row = self.tblCalendars.isEditing ? indexPath.row - 1 : indexPath.row;

        EKCalendar *currentCalendar = self.calendars[(NSUInteger) row];

        cell.textLabel.text = currentCalendar.title;

        if (!self.tblCalendars.isEditing) {
            cell.accessoryType = UITableViewCellAccessoryNone;

            if (self.appDelegate.eventManager.selectedCalenderIdentifier.length > 0) {
                if ([currentCalendar.calendarIdentifier isEqualToString:self.appDelegate.eventManager.selectedCalenderIdentifier]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            
        }
    }

    return cell;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
   //config the button at leftside
    if(indexPath.row==0){
        return UITableViewCellEditingStyleInsert;
    }else{
        return UITableViewCellEditingStyleDelete;
    }
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.selected&&cell.accessoryType==UITableViewCellAccessoryNone){
        DDLogDebug(@"selected cell");
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.appDelegate.eventManager.selectedCalenderIdentifier = [self.calendars[(NSUInteger) indexPath.row] calendarIdentifier];



    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        self.appDelegate.eventManager.selectedCalenderIdentifier = [self.calendars[(NSUInteger) indexPath.row] calendarIdentifier];

    }
    self.selectedCalendar = self.calendars[(NSUInteger) indexPath.row];
    [self.tblCalendars reloadData];
    [self performSegueWithIdentifier:@"idSegueShowEvent" sender:self];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
   int numRow = [self selectRow:self.tblCalendars];

    if(editingStyle == UITableViewCellEditingStyleInsert){
        [self createCalendar];
    }
    NSInteger row = (self.calendars.count==numRow)? indexPath.row:indexPath.row-1;
    if(editingStyle==UITableViewCellEditingStyleDelete){
        self.indexOfCalendarToDelete = (NSUInteger) row;
        [self confirmCalendarDeletion];

    }
}



#pragma mark - IBAction method implementation

- (IBAction)editCalendars:(id)sender {
    [self.tblCalendars setEditing:!self.tblCalendars.isEditing animated:YES];

    [self.tblCalendars reloadData];

}


#pragma mark - UITextFieldDelegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self createCalendar];
    return YES;
}

#pragma mark - UITransction
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
        ViewController *controller = (ViewController *)segue.destinationViewController;
    controller.selectedCalendar = self.selectedCalendar;

}



@end

