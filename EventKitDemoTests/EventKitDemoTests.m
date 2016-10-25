
//  EventKitDemoTests.m
//  EventKitDemoTests
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EventManager.h"
#import "CoreDataService.h"
@interface EventKitDemoTests : XCTestCase

@end

@implementation EventKitDemoTests

- (void)setUp
{
    [super setUp];

    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];

}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

-(void)testGetEvent{
    EventManager *eventManager = [EventManager new];
    NSArray *arrEvent = [eventManager getEventsOfSelectedCalendar];

    for (EKCalendar *ekCalendar in arrEvent) {
        DDLogDebug(@"event title:%@",ekCalendar.title);
    }
    eventManager=nil;
}

-(void)testGetRemembers{
    EventManager *eventManager = [EventManager new];
    NSArray *arrCalenders = eventManager.getiCloudReminders;
    XCTestExpectation *expectation= [self expectationWithDescription:@"fetch all reminders"];

   
//    if(OBJECT_IS_EMPTY(arrEvent)){
//        XCTFail(@"arrEvent is empty");
//
//    }
//       for (EKReminder *ekCalendar in arrEvent) {
//        DDLogDebug(@"event title:%@",ekCalendar.title);
//    }
    eventManager=nil;
}

-(void)testCheckCondition{
     EventManager *eventManager = [EventManager new];

            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Condition"];

    NSString * ID =@"A778F024-AEA6-42C0-89FD-4FCA7A990804";
            NSPredicate * predicate =  [NSPredicate predicateWithFormat:@"myReminderID == %@ AND sattus = YES",ID];
            [request setPredicate:predicate];
            CoreDataService *cd  = [[CoreDataService alloc]init];
            NSArray * re =  [cd fetchCondition:request];
            DDLogDebug(@"size : %ld",re.count);
            BOOL check = [eventManager checkCondition:re];
            DDLogDebug(@"check: %d",check);

    
    
    
    
    eventManager = nil;
}

-(void)testCompareDate{
    NSDate * current  = [NSDate new];
   NSDate * oneDayAfterCorrent =  [current dateByAddingDays:1];
    oneDayAfterCorrent= [oneDayAfterCorrent dateBySubtractingHours:1];
    BOOL re = [current isEarlierThanOrEqualDateIgnoringDate:oneDayAfterCorrent];
    DDLogDebug(@"%d",re);
}



@end
