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
    self.cd = [[CoreDataService alloc] init];
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
  
}

-(void)testGenerateFact{
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Fact"];
    NSPredicate *predicate =   [NSPredicate predicateWithFormat:@"factKey == %@",@"weather"];
    [request setPredicate:predicate];
    NSArray * re = [self.cd fetchFacts:request];
    DDLogDebug(@"size: %lu",re.count);
//    for (Fact * fact in re) {
//       // DDLogDebug(@"key: %@",fact.factKey);
//        NSDictionary * data = [NSKeyedUnarchiver unarchiveObjectWithData:fact.factValue];
//        LOOP_DICTIONARY(data);
//    }
    Fact * fact1 = re.firstObject;
    NSDictionary * data = [NSKeyedUnarchiver unarchiveObjectWithData:fact1.factValue];

//    LOOP_DICTIONARY(fact1);
    NSMutableArray * arrFact = data[@"weather"];
    [EngineService generateFacts:arrFact.firstObject];

}



@end
