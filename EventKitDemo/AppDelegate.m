//
//  AppDelegate.m
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//


#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "CoreDataService.h"
#import <OpenWeatherMapAPI/OWMWeatherAPI.h>
@import INTULocationManager;

NSString * const ManagedObjectContextSaveDidFailNotification = @"ManagedObjectContextSaveDidFailNotification";
static NSString *kNSDateHelperFormatSQLDate             = @"yyyy-MM-dd";
static NSString *kNSDateHelperFormatSQLTime             = @"HH:mm:ss";
@interface AppDelegate()
@property (nonatomic, strong)NSDictionary *locationdata;
@property (nonatomic, strong)NSDictionary *weatherdata;
@property (assign, nonatomic) INTULocationRequestID locationRequestID;

@property (nonatomic, strong)AVAudioPlayer *player;
@property (nonatomic, strong)NSArray *arrEvents;

@end


@implementation AppDelegate

-(void)applicationDidEnterBackground:(UIApplication *)application {
    DDLogDebug(@"enter background");
  //  [NSTimer scheduledTimerWithTimeInterval:60.f target:self selector:@selector(generateFacts) userInfo:nil repeats:YES];


//[NSTimer scheduledTimerWithTimeInterval:60.f target:self selector:@selector(evaluationCondition) userInfo:nil repeats:YES];

    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//googleplace

    self.autoSizeScaleX = [UIScreen mainScreen].bounds.size.width/375;
    self.autoSizeScaleY = [UIScreen mainScreen].bounds.size.height/667;
    
    
    //init DDlog
    [DDTTYLogger sharedInstance].logFormatter=[CustomerFormatter new];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console



    self.eventManager= [EventManager new];
    self.engineService= [EngineService new];
    self.locationdata = [NSDictionary new];
    self.weatherdata = [NSDictionary new];
    self.cd = CoreDataService .alloc.init;
    DDLogDebug(@"application start");
    

    [NSTimer scheduledTimerWithTimeInterval:30.f target:self selector:@selector(generateFacts) userInfo:nil repeats:NO];
    NSError *error;
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/0db.mp3",
                                                         [[NSBundle mainBundle] resourcePath]];
    NSURL *url = [NSURL fileURLWithPath:soundFilePath];
    self.player = [[AVAudioPlayer alloc]
            initWithContentsOfURL:url
                            error:&error];
    NSLog(@"Error %@",error);
    [self.player prepareToPlay];
    self.player.numberOfLoops=-1;
    self.player.delegate=self;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    [self.player play];
    [NSTimer scheduledTimerWithTimeInterval:60.f target:self selector:@selector(evaluationCondition) userInfo:nil repeats:YES];
    return YES;
    
    }
-(void)printCurrentTime:(id)sender{
    NSLog(@"当前的时间是---%@---",[self getCurrentTime]);
}
-(NSString *)getCurrentTime{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-DD HH:mm:ss"];
    NSString *dateTime=[dateFormatter stringFromDate:[NSDate date]];
    self.startTime=dateTime;
    return self.startTime;
}

-(void)evaluationCondition{
    DDLogDebug(@"start");
     NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Condition"];
    NSPredicate * predicate =  [NSPredicate predicateWithFormat:@"sattus = YES"];
    [request setPredicate:predicate];
    NSArray *conditions = [self.cd fetchCondition:request];
        DDLogDebug(@"condition size: %lu", (unsigned long) conditions.count);

    NSArray *calendars = self.eventManager.getiCloudReminders;
    NSPredicate *predicate1 = [self.eventManager.ekEventStore predicateForRemindersInCalendars:calendars];
    [self.eventManager.ekEventStore fetchRemindersMatchingPredicate:predicate1 completion:^(NSArray *events){
        for(EKReminder *reminder in events){
            DDLogDebug(@"!!!!!!!!!!!!!!!!!!!!!!!");
            DDLogDebug(@"reminder id %@  name : %@",reminder.calendarItemIdentifier, reminder.title);

            BOOL isFulfil = NO;
            //extract conditions 把所有相同ID 的conditions 提取出来
            NSMutableArray *tempConditions = [NSMutableArray new];
            for (Condition *con in conditions) {
                if ([con.myReminderID isEqualToString:reminder.calendarItemIdentifier]) {
                    [tempConditions addObject:con];
                }

            }
            DDLogDebug(@"total condition for remindername: %@ : %lu", reminder.title, (unsigned long) tempConditions.count);
            //pass the condition to engine and collect the result
            //check the reminder is completed nor not


            DDLogDebug(@"completed : %d,, alarms count : %d", reminder.completed, reminder.alarms.count);
            if(reminder.completed){
                DDLogDebug(@"%@ completed --> skip", reminder.title);
            }else{
                DDLogDebug(@"add alarm for %@",reminder.title);
                isFulfil = [self.eventManager checkCondition:tempConditions];
                DDLogDebug(@" full fill : %d", isFulfil);
                if (isFulfil) {

                    NSDate *current = [NSDate new];
                NSArray *ALARMS = reminder.alarms;
                    if(ALARMS.count==0){
                        EKAlarm *alarm1 = [EKAlarm alarmWithAbsoluteDate:[current dateByAddingSeconds:3]];
                        NSError *error;
                        [reminder addAlarm:alarm1];
                        [self.eventManager.ekEventStore saveReminder:reminder commit:YES error:&error];
                        if (OBJECT_ISNOT_EMPTY(error)) {
                            FATAL_CORE_DATA_ERROR(error);
                        }else{
                            DDLogDebug(@"add alarm for reminder : %@", reminder.title);
                        }
                    }else {
                        BOOL haveFutureAlarms = NO;

                        EKAlarm *latest = ALARMS.firstObject;
                        int passAlarm = 0;
                        int futureAlarm = 0;
                        for (EKAlarm *alarm2 in ALARMS) {
                            NSDate *date = alarm2.absoluteDate;

                            if (date.isInFuture) {
                                futureAlarm++;
                                haveFutureAlarms = YES;

                            }
                            if (date.isInPast) {
                                passAlarm++;
                            }
                        }
                        DDLogDebug(@"total alarm : %d, future: %d, pass %d", ALARMS.count, futureAlarm, passAlarm);
                        for (EKAlarm *alarm2 in ALARMS) {
                            NSDate *date = alarm2.absoluteDate;

                            if ([date isLaterThanDate:latest.absoluteDate]) {
                                latest = alarm2;
                            }
                        }
                        NSDate *latestDate = latest.absoluteDate;

                        NSTimeInterval secondsBetween = [latestDate timeIntervalSinceNow];
                        NSInteger ti = (NSInteger) secondsBetween;
                        NSInteger seconds = ti % 60;
                        NSInteger minutes = (ti / 60) % 60;
                        NSInteger hours = (ti / 3600);
                        NSString *str = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long) hours, (long) minutes, (long) seconds];

                        DDLogDebug(@"seconds betwwen : %@", str);
                        if (minutes < 0 && !haveFutureAlarms) {
                            EKAlarm *alarm1 = [EKAlarm alarmWithAbsoluteDate:[current dateByAddingSeconds:3]];
                            NSError *error;
                            [reminder addAlarm:alarm1];
                            [self.eventManager.ekEventStore saveReminder:reminder commit:YES error:&error];
                            if (OBJECT_ISNOT_EMPTY(error)) {
                                FATAL_CORE_DATA_ERROR(error);
                            } else {
                                DDLogDebug(@"add alarm for reminder : %@", reminder.title);
                            }
                        } else {
                            DDLogDebug(@" interval too short");
                        }
                    }
                }
            }
        }
    }];



        DDLogDebug(@"end");
    
}

-(void)generateFacts{
    DDLogDebug(@"start");

  //generate weather contextual information
    __weak typeof(self) weakself = self;

    //provide API key
    NSString *apiKey = @"87d25c0b5f8ce6cbfb3f53beb86fa29d";
        OWMWeatherAPI *weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:apiKey];
        [weatherAPI setTemperatureFormat:kOWMTempCelcius];
    //set the parameters for API call
    [weatherAPI dailyForecastWeatherByCityId:@"1733046" withCount:15 andCallback:^(NSError *error,NSDictionary *result){
        DDLogDebug(@"start get weather");
        if (OBJECT_ISNOT_EMPTY(error)) {
            FATAL_CORE_DATA_ERROR(error);
        } else {

            NSString *key = @"weather";
            NSDate *current = [NSDate new];
            NSMutableArray *arrData = [NSMutableArray new];
            //store the result in array
            NSArray *weatherjson = (result[@"list"]);
            DDLogDebug(@"weatherjson size ; %lu",weatherjson.count);
            for(NSDictionary *data in weatherjson) {
                //filtering the data
                NSArray *arr = data[@"weather"];
                NSString * str;
                for (NSDictionary*dic in arr) {
                    if(OBJECT_ISNOT_EMPTY(str)){
                        break;
                    }
                    for (id key1 in dic) {
                        //change the data type in order to store in DB easily
                        if ([[key1 description] isEqualToString:@"main"]) {
                            str  = [NSString stringWithFormat:@"%@",dic[key1]];
                           
                            break;
                        } else {
                            continue;
                        }
                    }
                }
                NSDate *time = data[@"dt"];
                NSString *strDate = [time stringWithFormat:kNSDateHelperFormatSQLDate];
                NSString *strTime = [time stringWithFormat:kNSDateHelperFormatSQLTime];
                NSDictionary *dic = @{
                        @"date":strDate,
                        @"time": strTime,
                        @"main": str};
                [arrData addObject:dic]; //add to the collection
            }
            //
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@{@"weather":arrData}];
            [weakself.cd createFact:key : data:current]; //save to database


            //Rains Clouds Clear
        }
    }];


    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    dispatch_async(dispatch_get_main_queue(),^{
        weakself.locationRequestID=[locMgr requestLocationWithDesiredAccuracy:
                INTULocationAccuracyNeighborhood timeout:20.0 block:^(CLLocation * currentLocation,INTULocationAccuracy achievedAccuracy, INTULocationStatus status){
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
                NSString *string=  [weakself getLocationErrorDescription:status];
                DDLogDebug(@"%@",string);
            }
            if(OBJECT_ISNOT_EMPTY(currentLocation)){
                NSString * key  = @"location";
                NSDate * current = [NSDate new];
                NSDictionary * locationData = @{
                        @"CLLocation":currentLocation
                };
                NSData * value = [NSKeyedArchiver archivedDataWithRootObject:locationData];
                [weakself.cd createFact:key :value :current];

            }

            weakself.locationRequestID = NSNotFound;



        }];
    });





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
