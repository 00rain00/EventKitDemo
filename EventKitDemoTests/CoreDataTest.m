//
//  CoreDataTest.m
//  EventKitDemo
//
//  Created by YULIN CAI on 19/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoreDataService.h"

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
    NSString *startTime = @"0700";
    NSString * endTime  = @"0800";
    NSData * start = [NSKeyedArchiver archivedDataWithRootObject:startTime];
    NSData * end = [NSKeyedArchiver archivedDataWithRootObject:endTime];
    [cd createCondition:@"12345" :@"startTime" :start];
    [cd createCondition:@"12345" :@"endTime" :end];
    cd = nil;
}
-(void)testFetchCondion{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Condition"];
    NSString * ID =@"12345";
   NSPredicate * predicate =  [NSPredicate predicateWithFormat:@"myReminderID == %@",ID];
    [request setPredicate:predicate];
    CoreDataService *cd  = [[CoreDataService alloc]init];
   NSArray * re =  [cd fetchCondition:request];
    for (Condition * con in re) {
        NSString *value = [NSKeyedUnarchiver unarchiveObjectWithData:con.myValue];
        DDLogDebug(@"%@ %@,%@",con.myReminderID,con.myKey,value);
    }
}

-(void)testDeleteCondition{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Condition"];
    NSString * ID =@"12345";
    NSString * key = @"endTime";
    NSPredicate * predicate =  [NSPredicate predicateWithFormat:@"myReminderID == %@ AND myKey == %@",ID,key];
    [request setPredicate:predicate];
    CoreDataService *cd  = [[CoreDataService alloc]init];
    [cd deleteCondition:request];
    cd = nil;
}

@end
