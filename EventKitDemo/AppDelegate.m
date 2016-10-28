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

@interface AppDelegate()<PHPhotoLibraryChangeObserver>
@property (nonatomic, strong)NSDictionary *locationdata;
@property (nonatomic, strong)NSDictionary *weatherdata;
@property (assign, nonatomic) INTULocationRequestID locationRequestID;

@end


@implementation AppDelegate

-(BOOL)applicationDidEnterBackground:(UIApplication *)application {
    DDLogDebug(@"enter background");
    [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(generateFacts) userInfo:nil repeats:YES];

 //[NSTimer scheduledTimerWithTimeInterval:10.f target:self selector:@selector(evaluationCondition) userInfo:nil repeats:YES];

    return YES;
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
    DDLogDebug(@"application start");
    
    
    //stay in background
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    //让 app 支持接受远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    //播放背景音乐
    NSString *musicPath=[[NSBundle mainBundle] pathForResource:@"0db" ofType:@"mp3"];
    NSURL *url=[[NSURL alloc]initFileURLWithPath:musicPath];

    //创建播放器
    AVAudioPlayer *audioPlayer;
   audioPlayer= [AVAudioPlayer alloc];
    assert(audioPlayer);
    NSError * error;
    audioPlayer = [audioPlayer initWithContentsOfURL:url error:&error];
    if (OBJECT_ISNOT_EMPTY(error)) {
        FATAL_CORE_DATA_ERROR(error);
    }
    [audioPlayer prepareToPlay];

    //无限循环播放
    audioPlayer.numberOfLoops=-1;
    [audioPlayer play];
   // play
    [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(generateFacts) userInfo:nil repeats:NO];

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
    CoreDataService * cd = [[CoreDataService alloc] init];
    NSArray *conditions = [cd fetchCondition:request];
    NSMutableArray *remindersID = [NSMutableArray new];
    //extract the reminder ID
    for(Condition *condition in conditions){
        [remindersID addObject:condition.myReminderID];
    }
    NSSet *IDsets  = [NSSet setWithArray:remindersID];
    DDLogDebug(@"IDsets size: %d",IDsets.count);
    for(NSString *id in IDsets){
        DDLogDebug(@" reminder id :%@",id);
        BOOL isFulfil = NO;
        NSMutableArray *tempConditions = [NSMutableArray new];
            for(Condition *con in conditions){
                if([con.myReminderID isEqualToString:id]){
                    [tempConditions addObject:con];
                }

            }
        DDLogDebug(@"total condition for %@ : %d",id,tempConditions.count);
       isFulfil= [self.eventManager checkCondition:tempConditions];
        DDLogDebug(@" full fill : %d",isFulfil);
        if(isFulfil){
            EKReminder *reminder = (EKReminder *)[self.eventManager.ekEventStore calendarItemWithIdentifier:id];
            NSDate * current = [NSDate new];

            EKAlarm *alarm1 = [EKAlarm alarmWithAbsoluteDate: [current dateByAddingSeconds:30]];
            NSError *error ;
            [self.eventManager.ekEventStore saveReminder:reminder commit:YES error:&error];
            if(OBJECT_ISNOT_EMPTY(error)){
                FATAL_CORE_DATA_ERROR(error);
            }
        }
    }

cd = nil;
    DDLogDebug(@"end");
}

-(void)generateFacts{
    DDLogDebug(@"start");

    //todo change to localnoticiation that can fire at midnight every day
    __weak typeof(self) weakself = weakself;

        DDLogDebug(@"start get weather");
          NSString *apiKey = @"87d25c0b5f8ce6cbfb3f53beb86fa29d";
        OWMWeatherAPI *weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:apiKey];
        [weatherAPI setTemperatureFormat:kOWMTempCelcius];

    [weatherAPI dailyForecastWeatherByCityId:@"1733046" withCount:15 andCallback:^(NSError *error,NSDictionary *result){
        DDLogDebug(@"start get weather");
        if (OBJECT_ISNOT_EMPTY(error)) {
            FATAL_CORE_DATA_ERROR(error);
        } else {
            CoreDataService *cd = [[CoreDataService alloc] init];
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
            [cd createFact:key : data:current];
                cd = nil;

            //Rains Clouds Clear
        }
    }];


    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    dispatch_async(dispatch_get_main_queue(),^{
        weakself.locationRequestID=[locMgr requestLocationWithDesiredAccuracy:
                INTULocationAccuracyNeighborhood timeout:5.0 block:^(CLLocation * currentLocation,INTULocationAccuracy achievedAccuracy, INTULocationStatus status){
            if (status == INTULocationStatusSuccess) {
                // achievedAccuracy is at least the desired accuracy (potentially better)

                NSString *location = [NSString stringWithFormat:@"Location request successful! Current Location:\n%@", currentLocation];
                DDLogDebug(@"%@",location);

                CoreDataService *cd  = [[CoreDataService alloc]init];
                NSString * key  = @"location";
                NSDate * current = [NSDate new];
                NSDictionary * locationData = @{
                        @"CLLocation":currentLocation
                };
                NSData * value = [NSKeyedArchiver archivedDataWithRootObject:locationData];
                [cd createFact:key :value :current];
                cd = nil;



            }
            else if (status == INTULocationStatusTimedOut) {
                // You may wish to inspect achievedAccuracy here to see if it is acceptable, if you plan to use currentLocation
                NSString *sutt= [NSString stringWithFormat:@"Location request timed out. Current Location:\n%@", currentLocation];
                DDLogDebug(@"%@",sutt);
            }
            else {
                // An error occurred
                NSString *string=  [weakself getLocationErrorDescription:status];
                DDLogDebug(string);
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
