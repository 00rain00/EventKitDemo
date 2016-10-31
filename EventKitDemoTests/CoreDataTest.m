//
//  CoreDataTest.m
//  EventKitDemo
//
//  Created by YULIN CAI on 19/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoreDataService.h"
#import <MapKit/MapKit.h>
#import <OpenWeatherMapAPI/OWMWeatherAPI.h>
@import INTULocationManager;
static NSString *kNSDateHelperFormatSQLDateWithTime     = @"yyyy-MM-dd HH:mm:ss";
static NSString *kNSDateHelperFormatSQLDate             = @"yyyy-MM-dd";
static NSString *kNSDateHelperFormatSQLTime             = @"HH:mm:ss";
@interface CoreDataTest : XCTestCase
@property (assign, nonatomic) INTULocationRequestID locationRequestID;
@property(nonatomic,strong)CoreDataService * cd;
@end

@implementation CoreDataTest

- (void)setUp {
    [super setUp];
    self.cd = [[CoreDataService alloc]init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.cd= nil;
    [super tearDown];
}

-(void)testCreateCondtion{
    CoreDataService *cd  = [[CoreDataService alloc]init];
    NSString * key = @"ruleType";
    NSString *reminder = @"813F615D-1EC9-49EF-865B-77049D08EBC0";
    int i = 1;
    NSData * value  = [NSKeyedArchiver archivedDataWithRootObject:@(i)];
    [cd createCondition:reminder :key :value];
    cd = nil;
}

-(void)testCreateLocationFact{
    XCTestExpectation *expectation = [self expectationWithDescription:@"test get location workds"];
     __weak __typeof(self) weakSelf = self;
     INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    dispatch_async(dispatch_get_main_queue(),^{
        self.locationRequestID=[locMgr requestLocationWithDesiredAccuracy:
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
                                        
                                        [expectation fulfill];
                                        
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
    
    [self waitForExpectationsWithTimeout:30.0 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}

-(void)testCreateWeatherFact{
    XCTestExpectation *expectation = [self expectationWithDescription:@"test get weather works"];
    __weak __typeof(self) weakself = self;

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
                    for (id key in dic) {
                        if ([[key description] isEqualToString:@"main"]) {
                            str  = dic[key];
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
                [arrData addObject:dic];
            }
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@{@"weather":arrData}];
            [cd createFact:key : data:current];
            [expectation fulfill];
            //Rains Clouds Clear
        }
    }];

    [self waitForExpectationsWithTimeout:60.0 handler:^(NSError *error) {

        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }

    }];
}





-(void)testFetchFact{
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Fact"];
        NSArray * re = [self.cd fetchFacts:request];
    DDLogDebug(@"size: %lu",re.count);
    for (Fact * fact in re) {
        DDLogDebug(@"key: %@",fact.factKey);
        NSDictionary * data = [NSKeyedUnarchiver unarchiveObjectWithData:fact.factValue];
        LOOP_DICTIONARY(data);
    }
   
    }

-(void)testFetchAllCondition{
    DDLogDebug(@"start");

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Condition"];
    NSPredicate * predicate =  [NSPredicate predicateWithFormat:@"sattus = YES"];
   // [request setPredicate:predicate];
   
    NSArray *conditions = [self.cd fetchCondition:request];
    DDLogDebug(@"Conditions count: %lu",conditions.count);
    for(Condition * con  in conditions){
        DDLogDebug(@"###############");
        DDLogDebug(@"reminder id : %@",con.myReminderID);
        DDLogDebug(@"key: %@",con.myKey);
        DDLogDebug(@"stattus: %d",con.sattus.integerValue);
    }
    
   
   }



-(void)testFetchCondion{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Condition"];
    NSString * ID =@"56CB5865-B6F1-4E2F-8C50-566468970A27";
   NSPredicate * predicate =  [NSPredicate predicateWithFormat:@"myReminderID == %@",ID];
    [request setPredicate:predicate];
    CoreDataService *cd  = [[CoreDataService alloc]init];
   NSArray * re =  [cd fetchCondition:request];
    for (Condition * con in re) {
     //   NSString *value = [NSKeyedUnarchiver unarchiveObjectWithData:con.myValue];
        if ([con.myKey containsString:@"Day"]) {
            DDLogDebug(con.myKey);
            NSDictionary *value  =[NSKeyedUnarchiver unarchiveObjectWithData:con.myValue];
            if (OBJECT_IS_EMPTY(value)) {
                DDLogDebug(@"empty");
            }
    //        NSMutableArray *value  =[NSKeyedUnarchiver unarchiveObjectWithData:con.myValue];
            if([value respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]){

                for (NSObject * obj in value) {
                   // NSNumber * string  = obj;
                    DDLogDebug(@"%@, %@",[obj description],value[obj]);
                    if([value[obj] respondsToSelector:@selector(isEqualToValue:)]){
                        NSString * string = [NSString stringWithFormat:@"%@",value[obj]];
                        if ([string isEqualToString:@"1"]) {
                            DDLogDebug(@"equal 1");
                        }
                    }else{
                        DDLogDebug(@"not compe stirng");
                    }
                   // DDLogDebug(@"%@, %d",string,[string containsString:@"Day"]);
                }
            }else{
                DDLogDebug(@"not respond");
            }

//            for (NSString *key in value) {
//                NSLog(key);
//                // DDLogDebug(@"%@ %@,%@,%@",con.myReminderID,con.myKey,key,value[key]);
//            }
     //       LOOP_DICTIONARY(value);

        }

    }
}

-(void)testFetchLocationCondion{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Condition"];
    NSString * ID =@"56CB5865-B6F1-4E2F-8C50-566468970A27";
    NSPredicate * predicate =  [NSPredicate predicateWithFormat:@"myReminderID == %@",ID];
    [request setPredicate:predicate];
    CoreDataService *cd  = [[CoreDataService alloc]init];
    NSArray * re =  [cd fetchCondition:request];
    DDLogDebug(@"size : %ld",re.count);
    NSString * title ;
    for (Condition * con in re) {
        if([con.myKey isEqualToString:@"locationAddress"]){
            title = [NSString stringWithFormat:@"%@",con.myKey];
            MKMapItem * mapItem = [NSKeyedUnarchiver unarchiveObjectWithData:con.myValue];

            DDLogDebug(@"%@,%@",title,mapItem);
        }
        if([con.myKey isEqualToString:@"locationType"]){
            NSNumber * type  = [NSKeyedUnarchiver unarchiveObjectWithData:con.myValue];
            DDLogDebug(@"type: %d",type.integerValue);
        }

}

}


-(void)testDeleteCondition{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Condition"];
    NSString * ID =@"A778F024-AEA6-42C0-89FD-4FCA7A990804";
    NSString * key = @"endTime";
    NSPredicate * predicate =  [NSPredicate predicateWithFormat:@"myReminderID == %@ AND myKey == %@",ID,key];
    NSPredicate *deleteAll = [NSPredicate predicateWithFormat:@"myReminderID==%@",ID];
   // [request setPredicate:deleteAll];
    CoreDataService *cd  = [[CoreDataService alloc]init];
    [cd deleteCondition:request];
    cd = nil;
}

-(void)testDeleteFact{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Fact"];
   

    [self.cd deleteCondition:request];

    
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

-(void)testEvalueWeatherCondition{
    //pull the condition

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Condition"];
    NSString * ID =@"58BD9C72-661F-4E42-81DE-440AF5FD7F40";
    NSPredicate * predicate =  [NSPredicate predicateWithFormat:@"myReminderID == %@ AND myKey ==%@",ID,@"Weather"];
    [request setPredicate:predicate];

    NSArray * re =  [self.cd fetchCondition:request];
    DDLogDebug(@"size : %ld",re.count);
    Condition * condition =re.firstObject;
    NSData *myValue = condition.myValue;
    NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:myValue];
    NSString *forecastTime = dictionary[@"forecastTime"];
    NSString *forecastType = dictionary[@"forecastType"];
    DDLogDebug(@"time : %@  type :%@",forecastTime,forecastType);

    //pull the fact
    NSFetchRequest * request2 = [NSFetchRequest fetchRequestWithEntityName:@"Fact"];
    NSSortDescriptor *timesorter = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"factKey == %@",@"weather"];
    [request2 setSortDescriptors:@[timesorter]];
    [request2 setPredicate:predicate2];
    NSArray * re2 = [self.cd fetchFacts:request2];
    DDLogDebug(@"size: %d",re2.count);

    Fact * fact = re2.firstObject;
    NSDictionary *weatherDetails = [NSKeyedUnarchiver unarchiveObjectWithData:fact.factValue];
     LOOP_DICTIONARY(weatherDetails);
    NSMutableArray *mutableArray = weatherDetails[@"weather"];
    for(NSDictionary *dic in mutableArray){
        LOOP_DICTIONARY(dic);
    }



    //evaluea it
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



}

-(void)testBool
{
    BOOL a= YES;
    NSObject * v = @(1);
    NSNumber * o= (NSNumber *)v;
   a |=  [o boolValue];
    DDLogDebug(@"%d",a);
}


@end
