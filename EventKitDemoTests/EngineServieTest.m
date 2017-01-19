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
       [EngineService generateFacts:re];

}
    
-(void)testGenerateRules{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Condition"];
        NSString * ID =@"813F615D-1EC9-49EF-865B-77049D08EBC0";
        NSPredicate * predicate =  [NSPredicate predicateWithFormat:@"myReminderID == %@  AND sattus == YES AND myKey == %@",ID,@"Weather"];
        [request setPredicate:predicate];
        
        NSArray * re =  [self.cd fetchCondition:request];
        [EngineService generateRules:re];

    }




-(void)testRunEngine{
    [self testGenerateFact];
    
    [self testGenerateRules];
    [self.es setUpClipsEnvironment];
    [self.es processRules];
}


@end
