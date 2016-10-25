
#import <NSDate_Escort/NSDate+Escort.h>
#import "EventManager.h"
#import <Photos/Photos.h>
static NSString *kNSDateHelperFormatTime                = @"h:mm a";
@interface EventManager()<PHPhotoLibraryChangeObserver>
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
        if(OBJECT_ISNOT_EMPTY([userDefaults objectForKey:@"eventkit_selected_calendar"])){
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
 //   [self.customerCalendarIdentifiers addObject:identifier];
  //  [[NSUserDefaults standardUserDefaults] setObject:self.customerCalendarIdentifiers forKey:@"eventkit_cal_identifiers"];

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
    //[self.customerCalendarIdentifiers removeObject:identifier];
   // [[NSUserDefaults standardUserDefaults] setObject:self.customerCalendarIdentifiers forKey:@"eventkit_cal_identifiers"];

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
        NSMutableArray * result = [NSMutableArray new];
        NSArray *allCalendars = [self.ekEventStore calendarsForEntityType:EKEntityTypeReminder];
        NSString *identifier  = calendarIdentifiers.firstObject;
        for(EKCalendar *calendar1 in allCalendars){
           if([calendar1.calendarIdentifier isEqualToString:identifier]){
               [result addObject:calendar1];
           }

        }
        DDLogDebug(@"total fetch calendars: %lu",(unsigned long)result.count);
        return result;
    }else{
        DDLogDebug(@"calendarIdentifiers is empty");
        return nil;
    }
}


- (void)getRemembersOfSelectedCalendar:(NSArray *)calenders {


   
  //  NSPredicate *predicate = [self.ekEventStore predicateForIncompleteRemindersWithDueDateStarting:nil ending:nil calendars:nil];
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

- (BOOL)checkCondition:(NSArray *)conditions {
    DDLogDebug(@"start");



        NSMutableArray *fullfillConditions = [NSMutableArray new];
        //loop the condition to check if the condition fullfill
        for(Condition *condition in conditions){
            NSString *key  = condition.myKey;
            NSDictionary *myValue = [NSKeyedUnarchiver unarchiveObjectWithData:condition.myValue];
            if([key containsString:@"Time"]){
                [fullfillConditions addObject:@([self compareTime:myValue])];
            }
            if([key containsString:@"Location"]){
                [fullfillConditions addObject:@([self compareLocation:myValue])];
            }
            if([key containsString:@"Contact"]){

            }

        }
        //check whether add alarm to conditions
        BOOL flag  = YES;
        for(id result in fullfillConditions){
            flag  = flag && [result boolValue];
        }
        return flag;




}

-(BOOL)compareTime:(NSDictionary *)myValue{
    //抽象出一个tempate?
    DDLogDebug(@"start");
    BOOL haveWeekDay = NO;
    BOOL haveMonthDay = NO;
    BOOL isALlDay = NO;
    BOOL haveEndTime = NO;
    NSDate *current = [NSDate new];
    NSObject *monthDaySwitch;
    //identify the compare type
    for(NSObject *key in myValue){
        if([key.description isEqualToString: @"WeekDay"]){
            haveWeekDay = YES;
        }
        if([key.description isEqualToString:@"MonthDay"]){
            haveMonthDay = YES;
        }
        if([key.description isEqualToString:@"allDaySwitch"]){
            NSString *allDaySwitch = [NSString stringWithFormat:@"%@",myValue[@"allDaySwitch"]];
            if([allDaySwitch isEqualToString:@"1"]){
                isALlDay = YES;
            }
        }
        if([key.description isEqualToString:@"endSwitch"]){
            NSString *endSwitch = [NSString stringWithFormat:@"%@",myValue[@"endSwitch"]];
            if([endSwitch isEqualToString:@"1"]){
                haveEndTime = YES;
            }
        }

    }
  //  DDLogDebug(@"have Weed Day: %d have monthDay: %d, is all day %d",haveWeekDay,haveMonthDay,isALlDay);
    DDLogDebug(@"cueent week : %d, current day: %d",current.weekday,current.day);
    BOOL isTodayTheWeekDay = NO;
    BOOL isTodayTheMonthDay = NO;
    BOOL isInTheTimeRange = NO;
    if(haveWeekDay){
        DDLogDebug(@"haveWeekDay : %d",haveWeekDay);
        //extract the week day
        NSDictionary *dicWeek   = myValue[@"WeekDay"];
        NSMutableArray *marrWeekDays = [NSMutableArray new];
        for(NSObject *weekDay in dicWeek){
            if([[NSString stringWithFormat:@"%@", dicWeek[weekDay]] isEqualToString:@"1"]){
                [marrWeekDays addObject:weekDay.description];
            }
        }
        NSMutableArray *marrNumberWeekDay = [self wordWeekDay2NumberWeekDay:marrWeekDays];
        //check if it is today
        for(NSNumber *numDay in marrNumberWeekDay){
            DDLogDebug(@"current week day : %d   numDay : %d",current.weekday,numDay.integerValue);
            if([numDay isEqualToNumber:@(current.weekday)]){
                DDLogDebug(@"check is today");
                isTodayTheWeekDay = YES;
                break;
            }
        }
        //check if it is in time-range
        DDLogDebug(@"isAllDay : %d",isALlDay);
        if(!isALlDay){
            NSDate * startTime = myValue[@"startTime"];
            DDLogDebug(@"startTime : %@",[startTime stringWithFormat:kNSDateHelperFormatTime]);
            if(haveEndTime){

                NSDate *endTime = myValue[@"endTime"];
                DDLogDebug(@"endTime : %@",[endTime stringWithFormat:kNSDateHelperFormatTime]);
                isInTheTimeRange = [current isLaterThanOrEqualDateIgnoringDate:startTime]&& [current isEarlierThanOrEqualDateIgnoringDate:endTime];
                DDLogDebug(@"is in the time range : %d",isInTheTimeRange);
            }else{
                isInTheTimeRange = [current isLaterThanOrEqualDateIgnoringDate:startTime];
                DDLogDebug(@"is in the time range : %d",isInTheTimeRange);
            }

        }else{
            isInTheTimeRange=YES;
        }

        return isInTheTimeRange&&isTodayTheWeekDay;
    }
        if(haveMonthDay){
            DDLogDebug(@"haveMonthDay : %d",haveMonthDay);
            //extract the month day
            NSMutableArray *marrMonthDays   = myValue[@"MonthDay"];

            NSMutableArray *marrNumberDate = [self extractMonthDay:marrMonthDays];
            //check if it is today
            for(NSString *date in marrNumberDate){
                DDLogDebug(@"current date : %d   range date : %@",current.day,date);
                if(current.day==date.integerValue){
                    DDLogDebug(@"check is today");
                    isTodayTheMonthDay = YES;
                    break;
                }
            }
            //check if it is in time-range
            DDLogDebug(@"isAllDay : %d",isALlDay);
            if(!isALlDay){
                NSDate * startTime = myValue[@"startTime"];
                DDLogDebug(@"startTime : %@",[startTime stringWithFormat:kNSDateHelperFormatTime]);
                if(haveEndTime){

                    NSDate *endTime = myValue[@"endTime"];
                    DDLogDebug(@"endTime : %@",[endTime stringWithFormat:kNSDateHelperFormatTime]);
                    isInTheTimeRange = [current isLaterThanOrEqualDateIgnoringDate:startTime]&& [current isEarlierThanOrEqualDateIgnoringDate:endTime];
                    DDLogDebug(@"is in the time range : %d",isInTheTimeRange);
                }else{
                    isInTheTimeRange = [current isLaterThanOrEqualDateIgnoringDate:startTime];
                    DDLogDebug(@"is in the time range : %d",isInTheTimeRange);
                }

            }else{
                isInTheTimeRange=YES;
            }

            return isInTheTimeRange&&isTodayTheMonthDay;


        }
    DDLogDebug(@"isAllDay : %d",isALlDay);
    if(!isALlDay){
        NSDate * startTime = myValue[@"startTime"];
        DDLogDebug(@"startTime : %@",[startTime stringWithFormat:kNSDateHelperFormatTime]);
        if(haveEndTime){

            NSDate *endTime = myValue[@"endTime"];
            DDLogDebug(@"endTime : %@",[endTime stringWithFormat:kNSDateHelperFormatTime]);
            isInTheTimeRange = [current isLaterThanOrEqualDateIgnoringDate:startTime]&& [current isEarlierThanOrEqualDateIgnoringDate:endTime];
            DDLogDebug(@"is in the time range : %d",isInTheTimeRange);
        }else{
            isInTheTimeRange = [current isLaterThanOrEqualDateIgnoringDate:startTime];
            DDLogDebug(@"is in the time range : %d",isInTheTimeRange);
        }

    }else{
        isInTheTimeRange=YES;
    }


        DDLogDebug(@"end of class");
    return isInTheTimeRange;


}

-(BOOL)compareLocation:(NSDictionary *)dic{
    return  YES;
}



-(NSMutableArray *)wordWeekDay2NumberWeekDay:(NSMutableArray *)marrWeekDay{
    NSMutableArray *re = [NSMutableArray new];
    for(NSString *weekDay in marrWeekDay){
        if([weekDay isEqualToString:@"sunday"]){
            [re addObject:@(1)];
        }
        if([weekDay isEqualToString:@"monday"]){
            [re addObject:@(2)];
        }
        if([weekDay isEqualToString:@"tuesday"]){
            [re addObject:@(3)];
        }
        if([weekDay isEqualToString:@"wednesday"]){
            [re addObject:@(4)];
        }
        if([weekDay isEqualToString:@"thursday"]){
            [re addObject:@(5)];
        }
        if([weekDay isEqualToString:@"friday"]){
            [re addObject:@(6)];
        }
        if([weekDay isEqualToString:@"saturday"]){
            [re addObject:@(7)];
        }
    }
    return re;
}

-(NSMutableArray *)extractMonthDay:(NSMutableArray *)marrMonthdays{
    NSMutableArray *re = [NSMutableArray new];

    for(NSObject *day in marrMonthdays){
        if([[day description] containsString:@"Day"]){
          NSArray *temp = [day.description componentsSeparatedByString:@" "];
            [re addObject:temp.lastObject];
        }
    }
    return re;
}

@end
