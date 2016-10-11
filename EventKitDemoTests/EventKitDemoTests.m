//
//  EventKitDemoTests.m
//  EventKitDemoTests
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EventManager.h"
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

@end
