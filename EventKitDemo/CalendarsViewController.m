//
//  CalendarsViewController.m
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <FFGlobalAlertController/UIAlertController+Window.h>
#import "CalendarsViewController.h"
#import "AppDelegate.h"
#pragma clang diagnostic push
#pragma ide diagnostic ignored "CannotResolve"
#import "UIAlertController+Window.h"


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
    self.tblCalendars.delegate = self;
    self.tblCalendars.dataSource = self;
    
    // Instantiate the appDelegate property.
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self loadEventCalendars];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadEventCalendars {
    self.calendars= [self.appDelegate.eventManager getLocalCalenders];
   // self.calendars= [self.appDelegate.eventManager getiCloudCalendars];

    [self.tblCalendars reloadData];
}

- (void)createCalendar {
    //get textfield
    UITextField *textField= (UITextField *) [[self.tblCalendars cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:10];
    [textField resignFirstResponder];
    if(textField.text.length==0){
        return;
    }
    EKCalendar *calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.appDelegate.eventManager.ekEventStore];
    calendar.title = textField.text;

    //the type cannot assign directly
    for(int i = 0; i<self.appDelegate.eventManager.ekEventStore.sources.count;i++){
        EKSource *source = [self.appDelegate.eventManager.ekEventStore.sources objectAtIndex:i];
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
    if(![self.appDelegate.eventManager checkIfCalendarIsCustomerWithIdentifier:identifier]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Global Alert" message:@"You are not allowed to delete this calendar." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
        [alert show];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Global Alert" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
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
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - UITableView Delegate and Datasource method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    DDLogInfo(@"calendars count:%lu", (unsigned long)[self.calendars count]);
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

        EKCalendar *currentCalendar = [self.calendars objectAtIndex:row];

        cell.textLabel.text = currentCalendar.title;

        if (!self.tblCalendars.isEditing) {
            cell.accessoryType = UITableViewCellAccessoryNone;

            if (self.appDelegate.eventManager.selectedCalenderIdentifier.length > 0) {
                if ([currentCalendar.calendarIdentifier isEqualToString:self.appDelegate.eventManager.selectedCalenderIdentifier]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            else{

                if (indexPath.row == 0) {
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
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.appDelegate.eventManager.selectedCalenderIdentifier = [self.calendars[(NSUInteger) indexPath.row] calendarIdentifier];



    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        self.appDelegate.eventManager.selectedCalenderIdentifier =@"";
       }
    [self.tblCalendars reloadData];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleInsert){
        [self createCalendar];
    }

    if(editingStyle==UITableViewCellEditingStyleDelete){
        self.indexOfCalendarToDelete = (NSUInteger) (indexPath.row-1);
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



@end

#pragma clang diagnostic pop