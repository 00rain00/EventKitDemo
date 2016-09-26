
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
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:eventsAccessGranted] forKey:@"eventkit_events_access_granted"];
}

- (void)setSelectedCalenderIdentifier:(NSString *)selectedCalenderIdentifier {
    _selectedCalenderIdentifier = selectedCalenderIdentifier;
    [[NSUserDefaults standardUserDefaults] setObject:selectedCalenderIdentifier forKey:@"eventkit_selected_calendar"];
}

- (NSArray *)getiCloudCalendars {
    NSArray *allCalendars = [self.ekEventStore calendarsForEntityType:EKEntityTypeEvent];
    NSMutableArray *iCloudCalenders = [NSMutableArray new];
    for(int i =0; i<allCalendars.count;i++){
        EKCalendar *calendar= [allCalendars objectAtIndex:i];

        DDLogDebug(@"calender type: %@////title:%@",[NSString stringWithFormat: @"%ld",(long)calendar.type],calendar.title);
        if(calendar.type == EKCalendarTypeCalDAV){
            [iCloudCalenders addObject:calendar];
        }
    }
    DDLogDebug(@"Size of iCloudCalenders:%lu",(unsigned long)iCloudCalenders.count);
    return (NSArray *)iCloudCalenders;
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


@end
