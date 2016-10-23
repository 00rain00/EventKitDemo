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


@interface CoreDataTest : XCTestCase

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
//    NSString *startTime = @"0700";
//    NSString * endTime  = @"0800";
//    NSData * start = [NSKeyedArchiver archivedDataWithRootObject:startTime];
//    NSData * end = [NSKeyedArchiver archivedDataWithRootObject:endTime];
//    [cd createCondition:@"12345" :@"startTime" :start];
//    [cd createCondition:@"12345" :@"endTime" :end];

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
    NSString * ID =@"56CB5865-B6F1-4E2F-8C50-566468970A27";
    NSString * key = @"endTime";
    NSPredicate * predicate =  [NSPredicate predicateWithFormat:@"myReminderID == %@ AND myKey == %@",ID,key];
    NSPredicate *deleteAll = [NSPredicate predicateWithFormat:@"myReminderID==%@",ID];
    [request setPredicate:deleteAll];
    CoreDataService *cd  = [[CoreDataService alloc]init];
    [cd deleteCondition:request];
    cd = nil;
}

@end
