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
@property(nonatomic,strong)EngineService * es;
@property(nonatomic,strong)CoreDataService * cd;
@end

@implementation EngineServieTest

- (void)setUp {
    [super setUp];
    self.es = [EngineService new];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testSetUpEngine{
   
    
    int result = self.es.setUpClipsEnvironment;
    NSLog(@"%d",result);
    XCTAssertEqual(result, 1);
}
-(void)testTransformFacts{
   
    [self.es setUpClipsEnvironment];
    NSDictionary *facts = @{
            @"Time" :[NSDate new]};

    //[self.es generateFacts:facts];
}

-(void)testTransformRules{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Condition"];
    NSString * ID =@"56CB5865-B6F1-4E2F-8C50-566468970A27";
    NSPredicate * predicate =  [NSPredicate predicateWithFormat:@"myReminderID == %@  AND sattus == YES",ID];
    [request setPredicate:predicate];
   
    NSArray * re =  [self.cd fetchCondition:request];
      [self.es writeConditionToFile:re];
    DDLogDebug(@"size : %ld",re.count);

   
}
-(void)testReadXml{
  //NSString * result =   [EngineService loadXml];
    //DDLogDebug(@"%@",result);
}



@end
