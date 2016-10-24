//
//  EngineServieTest.m
//  EventKitDemo
//
//  Created by YULIN CAI on 13/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EngineService.h"
#import "CoreDataService.h"

@interface EngineServieTest : XCTestCase

@end

@implementation EngineServieTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testSetUpEngine{
    EngineService * es = [EngineService new];
    
    int result = es.setUpClipsEnvironment;
    NSLog(@"%d",result);
    XCTAssertEqual(result, 1);
}
-(void)testTransformFacts{
    EngineService * es = [EngineService new];
    es.setUpClipsEnvironment;
    NSDictionary *facts = @{
            @"Time" :[NSDate new]};

    [es generateFacts:facts];
}

-(void)testTransformRules{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Condition"];
    NSString * ID =@"56CB5865-B6F1-4E2F-8C50-566468970A27";
    NSPredicate * predicate =  [NSPredicate predicateWithFormat:@"myReminderID == %@  AND sattus == YES",ID];
    [request setPredicate:predicate];
    CoreDataService *cd  = [[CoreDataService alloc]init];
    NSArray * re =  [cd fetchCondition:request];
    EngineService * es = [EngineService new];
    [es writeConditionToFile:re];
    DDLogDebug(@"size : %ld",re.count);







    cd = nil;
    es = nil;
}

@end
