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

@interface AppDelegate()
@property (nonatomic, strong)NSDictionary *locationdata;
@property (nonatomic, strong)NSDictionary *weatherdata;
@property (assign, nonatomic) INTULocationRequestID locationRequestID;
@property (nonatomic, strong)CoreDataService *cd;
@property (nonatomic, strong)AVAudioPlayer *player;

@end


@implementation AppDelegate

-(void)applicationDidEnterBackground:(UIApplication *)application {
    DDLogDebug(@"enter background");
    [NSTimer scheduledTimerWithTimeInterval:60.f target:self selector:@selector(generateFacts) userInfo:nil repeats:YES];


[NSTimer scheduledTimerWithTimeInterval:90.f target:self selector:@selector(evaluationCondition) userInfo:nil repeats:YES];

    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //init DDlog
    [DDTTYLogger sharedInstance].logFormatter=[CustomerFormatter new];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console



    self.eventManager= [EventManager new];
    self.engineService= [EngineService new];
    self.locationdata = [NSDictionary new];
    self.weatherdata = [NSDictionary new];
    self.cd = CoreDataService .alloc.init;
    DDLogDebug(@"application start");
    

    [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(generateFacts) userInfo:nil repeats:NO];
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
        NSMutableArray *remindersID = [NSMutableArray new];
        //extract the reminder ID
        for (Condition *condition in conditions) {
            NSDictionary *data  = [NSKeyedUnarchiver unarchiveObjectWithData:condition.myValue];
            @try {
                LOOP_DICTIONARY(data);

            } @catch (NSException *exception) {
                DDLogDebug(@"expection: %@",exception.reason);
                LOOP_DICTIONARY(exception.userInfo);
            }

            [remindersID addObject:condition.myReminderID];
        }
        NSSet *IDsets = [NSSet setWithArray:remindersID];

        DDLogDebug(@"IDsets size: %lu", (unsigned long) IDsets.count);
        for (NSString *rID in IDsets) {
            DDLogDebug(@" reminder id :%@", rID);
            BOOL isFulfil = NO;
            NSMutableArray *tempConditions = [NSMutableArray new];
            for (Condition *con in conditions) {
                if ([con.myReminderID isEqualToString:rID]) {
                    [tempConditions addObject:con];
                }

            }
            DDLogDebug(@"total condition for %@ : %lu", rID, (unsigned long) tempConditions.count);
            isFulfil = [self.eventManager checkCondition:tempConditions];
            DDLogDebug(@" full fill : %d", isFulfil);
            if (isFulfil) {

                EKReminder *reminder = (EKReminder *) [self.eventManager.ekEventStore calendarItemWithIdentifier:rID];
                NSDate *current = [NSDate new];

                EKAlarm *alarm1 = [EKAlarm alarmWithAbsoluteDate:[current dateByAddingSeconds:60]];
                NSError *error;
                [reminder addAlarm:alarm1];
                [self.eventManager.ekEventStore saveReminder:reminder commit:YES error:&error];
                if (OBJECT_ISNOT_EMPTY(error)) {
                    FATAL_CORE_DATA_ERROR(error);
                }else{
                    DDLogDebug(@"add alarm for reminder : %@", reminder.title);
                }
            }
        }


        DDLogDebug(@"end");
    
}

-(void)generateFacts{
    DDLogDebug(@"start");

    //todo change to localnoticiation that can fire at midnight every day
    __weak typeof(self) weakself = self;

        DDLogDebug(@"start get weather");
          NSString *apiKey = @"87d25c0b5f8ce6cbfb3f53beb86fa29d";
        OWMWeatherAPI *weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:apiKey];
        [weatherAPI setTemperatureFormat:kOWMTempCelcius];

    [weatherAPI dailyForecastWeatherByCityId:@"1733046" withCount:15 andCallback:^(NSError *error,NSDictionary *result){
        DDLogDebug(@"start get weather");
        if (OBJECT_ISNOT_EMPTY(error)) {
            FATAL_CORE_DATA_ERROR(error);
        } else {

            NSString *key = @"weather";
            NSDate *current = [NSDate new];
            NSMutableArray *arrData = [NSMutableArray new];

            NSArray *weatherjson = (result[@"list"]);
            DDLogDebug(@"weatherjson size ; %d",weatherjson.count);
            for(NSDictionary *data in weatherjson) {
                //  LOOP_DICTIONARY(data);
                NSArray *arr = data[@"weather"];
                NSString * str;
                for (NSDictionary*dic in arr) {
                    if(OBJECT_ISNOT_EMPTY(str)){
                        break;
                    }
                    for (id key1 in dic) {
                        if ([[key1 description] isEqualToString:@"main"]) {
                            str  = dic[key1];
                            break;
                        } else {
                            continue;
                        }
                    }
                }
                NSDate *time = data[@"dt"];

                NSDictionary *dic = @{@"time": time,
                        @"main": str};
                [arrData addObject:dic];
            }
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@{@"weather":arrData}];
            [weakself.cd createFact:key : data:current];
              ;

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
