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

@import INTULocationManager;


@interface CoreDataTest : XCTestCase
@property (assign, nonatomic) INTULocationRequestID locationRequestID;
@end

@implementation CoreDataTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testCreateCondtion{
    CoreDataService *cd  = [[CoreDataService alloc]init];
    NSString *startTime = @"0700";
    NSString * endTime  = @"0800";
    NSData * start = [NSKeyedArchiver archivedDataWithRootObject:startTime];
    NSData * end = [NSKeyedArchiver archivedDataWithRootObject:endTime];
    [cd createCondition:@"12345" :@"startTime" :start];
    [cd createCondition:@"12345" :@"endTime" :end];

    cd = nil;
}

-(void)testCreateFact{
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
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}

-(void)testFetchFact{
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Fact"];
    CoreDataService *cd = [[CoreDataService alloc]init];
    NSArray * re = [cd fetchFacts:request];
    DDLogDebug(@"size: %d",re.count);
    cd = nil;
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
    [request setPredicate:deleteAll];
    CoreDataService *cd  = [[CoreDataService alloc]init];
    [cd deleteCondition:request];
    cd = nil;
}

-(void)testDeleteFact{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Fact"];
   
    CoreDataService *cd  = [[CoreDataService alloc]init];
    [cd deleteCondition:request];
    cd = nil;

    
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
