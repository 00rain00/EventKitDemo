//
//  APPdelegateTest.m
//  EventKitDemo
//
//  Created by YULIN CAI on 26/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AppDelegate.h"
#import <OpenWeatherMapAPI/OWMWeatherAPI.h>
@interface APPdelegateTest : XCTestCase

@end

@implementation APPdelegateTest

-(void)testGenerateFact{
    
     AppDelegate * app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [app generateFacts];
    
    sleep(60);
    
    
}

-(void)testEvaluationCondition{
    AppDelegate * app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [app evaluationCondition];
}

-(void)testGetWeather{
     XCTestExpectation *expectation = [self expectationWithDescription:@"test get weather woks"];
    NSString *apiKey = @"87d25c0b5f8ce6cbfb3f53beb86fa29d";
    OWMWeatherAPI *weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:apiKey];
    [weatherAPI setTemperatureFormat:kOWMTempCelcius];
    [weatherAPI forecastWeatherByCityId:@"1733046" withCallback:^(NSError *error, NSDictionary *result) {
        
        DDLogDebug(@"start get weather");
        if (OBJECT_ISNOT_EMPTY(error)) {
            FATAL_CORE_DATA_ERROR(error);
        } else {
//            CoreDataService *cd = [[CoreDataService alloc] init];
//            NSString *key = @"weather";
//            NSDate *current = [NSDate new];
//            NSDictionary *weatherData = @{
//                                          @"weather": result
//                                          };
            LOOP_DICTIONARY(result);
//            NSData *value = [NSKeyedArchiver archivedDataWithRootObject:weatherData];
//            [cd createFact:key :value :current];
//            cd = nil;
            
            //Rains Clouds Clear
            
            [expectation fulfill];

        }
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];

}

@end
