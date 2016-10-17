
#import "EventManager.h"
@interface EventManager()
@property (nonatomic, strong)NSMutableArray *customerCalendarIdentifiers;
@end
@implementation EventManager

-(instancetype)init{
    if((self=[super init])){
        self.ekEventStore=[EKEventStore new];
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        if(OBJECT_ISNOT_EMPTY([userDefaults valueForKey:@"eventkit_events_access_granted"])){
            self.eventsAccessGranted= [[userDefaults valueForKey:@"eventkit_events_access_granted"] intValue];
        }
        else{
            self.eventsAccessGranted=NO;
        }
        if(OBJECT_IS_EMPTY([userDefaults objectForKey:@"eventkit_selected_calendar"])){
            self.selectedCalenderIdentifier= [userDefaults objectForKey:@"eventkit_selected_calendar"];
        }else{
            self.selectedCalenderIdentifier=@"";
        }

        if(OBJECT_ISNOT_EMPTY([userDefaults objectForKey:@"eventkit_cal_identifiers"])){
            self.customerCalendarIdentifiers= [userDefaults objectForKey:@"eventkit_cal_identifiers"];
        }else{
            self.customerCalendarIdentifiers = [NSMutableArray new];
        }
    }
    return self;
}
//override the setter
- (void)setEventsAccessGranted:(BOOL)eventsAccessGranted {
    _eventsAccessGranted = eventsAccessGranted;
    [[NSUserDefaults standardUserDefaults] setValue:@(eventsAccessGranted) forKey:@"eventkit_events_access_granted"];
}

- (void)setSelectedCalenderIdentifier:(NSString *)selectedCalenderIdentifier {
    _selectedCalenderIdentifier = selectedCalenderIdentifier;
    [[NSUserDefaults standardUserDefaults] setObject:selectedCalenderIdentifier forKey:@"eventkit_selected_calendar"];
}

- (void)callbackForFetchReminders:(FetchRemindersBlock)reminderDidRetrived {
   //给block 赋值
    self.callbackForFetchReminders=reminderDidRetrived;


}

- (NSArray *)getiCloudCalendars {
    NSArray *allCalendars = [self.ekEventStore calendarsForEntityType:EKEntityTypeEvent];
    NSMutableArray *iCloudCalenders = [NSMutableArray new];
    for(int i =0; i<allCalendars.count;i++){
        EKCalendar *calendar= allCalendars[i];

        DDLogDebug(@"calender type: %@////title:%@",[NSString stringWithFormat: @"%ld",(long)calendar.type],calendar.title);
        if(calendar.type == EKCalendarTypeCalDAV){
            [iCloudCalenders addObject:calendar];
        }
    }
    DDLogDebug(@"Size of iCloudCalenders:%lu",(unsigned long)iCloudCalenders.count);
    return (NSArray *)iCloudCalenders;
}



- (NSArray *)getLocalCalenders {
    NSArray *allCalendars = [self.ekEventStore calendarsForEntityType:EKEntityTypeEvent];
    NSMutableArray *localCalenders = [NSMutableArray new];
    for(int i =0; i<allCalendars.count;i++){
        EKCalendar *calendar= allCalendars[i];

        DDLogDebug(@"calender type: %@////title:%@",[NSString stringWithFormat: @"%ld",(long)calendar.type],calendar.title);
        if(calendar.type == EKCalendarTypeLocal){
            [localCalenders addObject:calendar];
        }
    }
    DDLogDebug(@"Size of local Calenders:%lu",(unsigned long)localCalenders.count);
    return (NSArray *)localCalenders;
}

- (NSArray *)getiCloudReminders {
    NSArray *allCalendars = [self.ekEventStore calendarsForEntityType:EKEntityTypeReminder];
    NSMutableArray *localCalenders = [NSMutableArray new];
    for(int i =0; i<allCalendars.count;i++){
        EKCalendar *calendar= allCalendars[i];

        DDLogDebug(@"calender type: %@////title:%@",[NSString stringWithFormat: @"%ld",(long)calendar.type],calendar.title);

            [localCalenders addObject:calendar];

    }
    DDLogDebug(@"Size of local Calenders:%lu",(unsigned long)localCalenders.count);
    return (NSArray *)localCalenders;
}

- (void)saveCustomerCalendarIdentifier:(NSString *)identifier {
    [self.customerCalendarIdentifiers addObject:identifier];
    [[NSUserDefaults standardUserDefaults] setObject:self.customerCalendarIdentifiers forKey:@"eventkit_cal_identifiers"];

}

- (BOOL)checkIfCalendarIsCustomerWithIdentifier:(NSString *)identifier {
    BOOL isCustomerCalendar = NO;
    for(int i =0; i<self.customerCalendarIdentifiers.count;i++){
        if([self.customerCalendarIdentifiers[i] isEqualToString:identifier]){
            isCustomerCalendar = YES;
            break;
        }
    }

    return isCustomerCalendar;
}

- (void)removeCalendarIdentifier:(NSString *)identifier {
    [self.customerCalendarIdentifiers removeObject:identifier];
    [[NSUserDefaults standardUserDefaults] setObject:self.customerCalendarIdentifiers forKey:@"eventkit_cal_identifiers"];

}

- (void)deleteEventWithIdentifier:(NSString *)identifier {
    // Get the event that's about to be deleted.
    EKEvent *event = [self.ekEventStore eventWithIdentifier:identifier];

    // Delete it.
    NSError *error;
    if (![self.ekEventStore removeEvent:event span:EKSpanFutureEvents error:&error]) {
        // Display the error description.
        FATAL_CORE_DATA_ERROR(error);
    }
}


- (NSString *)getStringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter= [NSDateFormatter new];
    dateFormatter.locale= [NSLocale currentLocale];
    [dateFormatter setDateFormat:@"d MMM yyyy, HH:mm"];
    NSString *stringFromDate= [dateFormatter stringFromDate:date];
    return stringFromDate;
}

- (NSArray *)getEventsOfSelectedCalendar {
    // Specify the calendar that will be used to get the events from.
    EKCalendar *calendar = nil;
    if (self.selectedCalenderIdentifier != nil && self.selectedCalenderIdentifier.length > 0) {
        calendar = [self.ekEventStore calendarWithIdentifier:self.selectedCalenderIdentifier];
        DDLogDebug(@"selected calenderidentifer : %@",calendar.title);
    }else{
        DDLogDebug(@"no selected calender identifier!");
    }

    // If no selected calendar identifier exists and the calendar variable has the nil value, then all calendars will be used for retrieving events.
    NSArray *calendarsArray = nil;
    if (calendar != nil) {
        calendarsArray = @[calendar];
    }


    // Create a predicate value with start date a year before and end date a year after the current date.
    int yearSeconds = 365 * (60 * 60 * 24);
    NSPredicate *predicate = [self.ekEventStore predicateForEventsWithStartDate:[NSDate dateWithTimeIntervalSinceNow:-yearSeconds] endDate:[NSDate dateWithTimeIntervalSinceNow:yearSeconds] calendars:calendarsArray];

    // Get an array with all events.
    NSArray *eventsArray = [self.ekEventStore eventsMatchingPredicate:predicate];

    // Sort the array based on the start date.
    eventsArray = [eventsArray sortedArrayUsingSelector:@selector(compareStartDateWithEvent:)];

    // Return that array.
    return eventsArray;

}

- (NSMutableArray *)getCalendarBy:(NSArray *)calendarIdentifiers {
    if(OBJECT_ISNOT_EMPTY(calendarIdentifiers)){
        NSMutableArray * result;
        for(NSString *identifier in calendarIdentifiers){
            EKCalendar *calendar = [self.ekEventStore calendarWithIdentifier:identifier];
            [result addObject:calendar];
        }
        DDLogDebug(@"total fetch calendars: %lu",(unsigned long)result.count);
        return result;
    }else{
        DDLogDebug(@"calendarIdentifiers is empty");
        return nil;
    }
}


- (void)getRemembersOfSelectedCalendar:(NSArray *)calenders {


   
    NSPredicate *predicate = [self.ekEventStore predicateForIncompleteRemindersWithDueDateStarting:nil ending:nil calendars:nil];
    NSPredicate *predicate1 = [self.ekEventStore predicateForRemindersInCalendars:calenders];

    // Get an array with all events.
    //completion is ascynomous
    [self.ekEventStore fetchRemindersMatchingPredicate:predicate1 completion:^(NSArray *reminders){

        //call the block
        if(self.callbackForFetchReminders){
            self.callbackForFetchReminders(reminders);
        }

    }];
   
}


@end
