
#import <NSDate_Escort/NSDate+Escort.h>
#import "EventManager.h"
#import "Fact+CoreDataClass.h"
@import INTULocationManager;
static NSString *kNSDateHelperFormatTime                = @"h:mm a";
static NSString *kNSDateHelperFormatSQLDateWithTime     = @"yyyy-MM-dd HH:mm:ss";
static NSString *kNSDateHelperFormatSQLDate             = @"yyyy-MM-dd";
static NSString *kNSDateHelperFormatSQLTime             = @"HH:mm:ss";
@interface EventManager()
@property (nonatomic, strong)NSMutableArray *customerCalendarIdentifiers;
@property (assign, nonatomic) INTULocationRequestID locationRequestID;
@property (nonatomic, strong)CoreDataService *cd;
@end
@implementation EventManager

-(instancetype)init{
    if((self=[super init])){
        self.ekEventStore=[EKEventStore new];
        self.cd = [[CoreDataService alloc] init];
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


        BOOL isAny  = NO;
        NSMutableArray *fullfillConditions = [NSMutableArray new];
        //loop the condition to check if the condition fullfill
        for(Condition *condition in conditions){
            NSString *key  = condition.myKey;
            NSDictionary *myValue = [NSKeyedUnarchiver unarchiveObjectWithData:condition.myValue];
            if([key containsString:@"Time"]){
                BOOL result = [self compareTime:myValue];
                DDLogDebug(@"Time : %d",result);
                [fullfillConditions addObject:@(result)];
            }
            if([key containsString:@"Location"]){
                BOOL result = [self compareLocation:myValue];
                DDLogDebug(@"location: %d",result);
                [fullfillConditions addObject:@(result)];
            }
            if([key containsString:@"Weather"]){
                BOOL result = [self compareWeather:myValue];
                [fullfillConditions addObject:@(result)];
                DDLogDebug(@"weather : %d", result);
            }
            if([key containsString:@"ruleType"]){
                NSInteger flag = [[NSKeyedUnarchiver unarchiveObjectWithData:condition.myValue] integerValue];
                isAny = (BOOL) flag;
                DDLogDebug(@"rule type: %@",isAny? @"any":@"all");
            }

        }
        //check whether add alarm to conditions
        int i = 0;
        BOOL flag;
    //1 for any 0 for all
        if(isAny){
            for(id result in fullfillConditions){
               if([result boolValue]){
                   i+=1;
               }
                if(i>=1){
                    flag = YES;
                    break;
                }
            }
        }else{
            for(id result in fullfillConditions){
                if([result boolValue]){
                    i+=1;
                }

            }
            if(i==fullfillConditions.count){
                flag = YES;
            }
        }
        DDLogDebug(@"flag : %d",flag);
        return flag;




}

-(BOOL)compareTime:(NSDictionary *)myValue{
    @try {
        if(OBJECT_ISNOT_EMPTY(myValue)){
       //     LOOP_DICTIONARY(myValue);
        }else{
            DDLogDebug(@"myValue is empty");
        }
        
        DDLogDebug(@"start");
        BOOL haveWeekDay = NO;
        BOOL haveMonthDay = NO;
        BOOL isALlDay = NO;
        BOOL haveEndTime = NO;
        NSDate *current = [NSDate new];

        NSString *endSwitch = [NSString stringWithFormat:@"%@",myValue[@"endSwitch"]];
        //identify the compare type
        for(NSObject * kkkey in myValue){
            NSString *str = [NSString stringWithFormat:@"%@",kkkey.description];

            if([str isEqualToString: @"WeekDay"]){
                haveWeekDay = YES;
            }
            if([str isEqualToString:@"MonthDay"]){
                haveMonthDay = YES;
            }
            if([str isEqualToString:@"allDaySwitch"]){
                NSString *allDaySwitch = [NSString stringWithFormat:@"%@",myValue[@"allDaySwitch"]];
                if([allDaySwitch isEqualToString:@"1"]){
                    isALlDay = YES;
                }
            }
            if([str isEqualToString:@"endSwitch"]){
                NSString *endSwitch = [NSString stringWithFormat:@"%@",myValue[@"endSwitch"]];
                if([endSwitch isEqualToString:@"1"]){
                    haveEndTime = YES;
                }
            }
            
        }
        //  DDLogDebug(@"have Weed Day: %d have monthDay: %d, is all day %d",haveWeekDay,haveMonthDay,isALlDay);
        DDLogDebug(@"cueent week : %lu, current day: %lu",(unsigned long)current.weekday,(unsigned long)current.day);
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
                DDLogDebug(@"current week day : %lu   numDay : %ld",(unsigned long)current.weekday,(long)numDay.integerValue);
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
                DDLogDebug(@"current date : %lu   range date : %@",(unsigned long)current.day,date);
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
            return isInTheTimeRange;
        }else{
            isInTheTimeRange=YES;
        }


        DDLogDebug(@"end of class");

    } @catch (NSException *exception) {
        DDLogDebug(@"exp : %@",exception.description);
    }     //抽象出一个tempate?
     return YES;


}

-(BOOL)compareLocation:(NSDictionary *)myValue{
   NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Fact"];
    NSSortDescriptor *timesorter = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"factKey == %@",@"location"];
    [request setSortDescriptors:@[timesorter]];
    [request setPredicate:predicate];

    NSArray *facts = [self.cd fetchFacts:request];
    Fact *fact = facts.firstObject;
    NSDictionary *locationdata = [NSKeyedUnarchiver unarchiveObjectWithData:fact.factValue];
    CLLocation *location = locationdata[@"CLLocation"];
    if(OBJECT_IS_EMPTY(location)){
        DDLogDebug(@"empty location");
        return NO;
    }else{
        CLLocationDegrees latidude =  [myValue[@"locationLatitude"] doubleValue];
        CLLocationDegrees longtitidue =  [myValue[@"locationLongtitude"] doubleValue];
        CLLocationDistance radius = [myValue[@"locationRadius"] doubleValue];
        BOOL isOutside = [myValue[@"locationType"] boolValue];
        DDLogDebug(@"target:lat : %g , long :%g radius : %g , inside : %d",latidude,longtitidue,radius, isOutside);
        DDLogDebug(@"current:lat : %g , long :%g ",location.coordinate.latitude,location.coordinate.longitude);
        CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:latidude longitude:longtitidue];
        if(isOutside){
            return [location distanceFromLocation:targetLocation]>=radius;

        }else{
            return  [location distanceFromLocation:targetLocation]<=radius;
        }
    }


}

-(BOOL)compareWeather:(NSDictionary *)myValue{

    NSFetchRequest * request2 = [NSFetchRequest fetchRequestWithEntityName:@"Fact"];
    NSSortDescriptor *timesorter = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"factKey == %@",@"weather"];
    [request2 setSortDescriptors:@[timesorter]];
    [request2 setPredicate:predicate2];
    NSArray * re2 = [self.cd fetchFacts:request2];
    DDLogDebug(@"size: %lu",(unsigned long)re2.count);

    Fact * fact = re2.firstObject;
    NSDictionary *weatherDetails = [NSKeyedUnarchiver unarchiveObjectWithData:fact.factValue];
    //LOOP_DICTIONARY(weatherDetails);
    NSMutableArray *mutableArray = weatherDetails[@"weather"];
    DDLogDebug(@"mutableArray size: %lu",mutableArray.count);

    NSString *forecastType = myValue[@"forecastType"];
    NSString *forecastTime = myValue[@"forecastTime"];



    BOOL fullfil = NO;
    NSString *compareType ;
    if([forecastType isEqualToString:@"Clear Sky"]){
        compareType = @"Clear";
    }else if([forecastType isEqualToString:@"Rainy"]){
        compareType = @"Rain";
    }else{
        compareType = @"Clouds";
    }
    if([forecastTime isEqualToString:@"Tomorrow"]){
        DDLogDebug(@"forecast tomottow");
        for(NSDictionary *data in mutableArray){
            NSString *strDate = data[@"date"];
          NSDate *date = [NSDate dateFromString:strDate withFormat:kNSDateHelperFormatSQLDate];
            if( date.isTomorrow){
                DDLogDebug(@"tomorrow");
                NSString *type = data[@"main"];
                DDLogDebug(@"constrain:%@  fact:%@",type,compareType);
                if([type isEqualToString:compareType]){
                    DDLogDebug(@"checked");

                    fullfil=YES;
                    break;
                }
            }else{
                continue;
            }
        }
    }
    if([forecastTime isEqualToString:@"Next 3 hours"]){

        DDLogDebug(@"forecast next 3");
        for(NSDictionary *data in mutableArray){
            NSString *strDate = data[@"date"];
            NSString *strTime = data[@"time"];

            NSDate *date = [NSDate dateFromString:strDate withFormat:kNSDateHelperFormatSQLDate];
            if(date.isToday){
                NSDate *time = [NSDate dateFromString:strTime withFormat:kNSDateHelperFormatSQLTime];
                if([time isEarlierThanOrEqualDateIgnoringDate:[[NSDate new] dateByAddingHours:6]]&& [time isLaterThanOrEqualDateIgnoringDate:[NSDate new]]){
                    DDLogDebug(@" next 6 time interval");
                    NSString *type = data[@"main"];
                    DDLogDebug(@" %@ %@",type,compareType);
                    if([type isEqualToString:compareType]){
                        DDLogDebug(@"checked");
                        fullfil = YES;
                        break;
                    }

                }else{
                    continue;
                }
            }else{
                continue;
            }

        }
    }

    DDLogDebug(@"fullfill : %d",fullfil);
    return fullfil;

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


-(CLLocation *)getCurrentLocation{
    DDLogDebug(@"start");
    __block CLLocation *clLocation = nil;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0),^{
        __weak __typeof(self) weakSelf = self;

        INTULocationManager *locMgr = [INTULocationManager sharedInstance];
        self.locationRequestID = [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyNeighborhood
                                                                    timeout:5.0
                                                       delayUntilAuthorized:YES
                                                                      block:
                                                                              ^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
DDLogDebug(@"start");
                                                                                  clLocation = currentLocation;
                                                                                  if (status == INTULocationStatusSuccess) {
                                                                                      // achievedAccuracy is at least the desired accuracy (potentially better)

                                                                                      NSString *location = [NSString stringWithFormat:@"Location request successful! Current Location:\n%@", currentLocation];
                                                                                      DDLogDebug(@"%@",location);

                                                                                  }
                                                                                  else if (status == INTULocationStatusTimedOut) {
                                                                                      // You may wish to inspect achievedAccuracy here to see if it is acceptable, if you plan to use currentLocation
                                                                                      NSString *sutt= [NSString stringWithFormat:@"Location request timed out. Current Location:\n%@", currentLocation];
                                                                                      DDLogDebug(@"%@",sutt);
                                                                                  }
                                                                                  else {
                                                                                      // An error occurred
                                                                                      NSString *string=  [weakSelf getLocationErrorDescription:status];
                                                                                      DDLogDebug(string);
                                                                                  }

                                                                                  weakSelf.locationRequestID = NSNotFound;



                                                                              }];

    });
DDLogDebug(@"end");
    return clLocation;
}

- (NSString *)getLocationErrorDescription:(INTULocationStatus)status
{
    if (status == INTULocationStatusServicesNotDetermined) {
        return @"Error: User has not responded to the permissions alert.";
    }
    if (status == INTULocationStatusServicesDenied) {
        return @"Error: User has denied this app permissions to access device location.";
    }
    if (status == INTULocationStatusServicesRestricted) {
        return @"Error: User is restricted from using location services by a usage policy.";
    }
    if (status == INTULocationStatusServicesDisabled) {
        return @"Error: Location services are turned off for all apps on this device.";
    }
    return @"An unknown error occurred.\n(Are you using iOS Simulator with location set to 'None'?)";
}




@end
