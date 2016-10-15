//
//  AddWeatherViewController.m
//  EventKitDemo
//
//  Created by YULIN CAI on 15/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <EventKit/EventKit.h>
#import <OpenWeatherMapAPI/OWMWeatherAPI.h>
#import "AddWeatherViewController.h"
const  NSString *apiKey = @"157808e844100fd4a78f54ce6f2b73bc";
@interface AddWeatherViewController ()

@end

@implementation AddWeatherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    OWMWeatherAPI *weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:apiKey];
    [weatherAPI setTemperatureFormat:kOWMTempCelcius];
    [weatherAPI forecastWeatherByCityName:@"Beijing" withCallback:^(NSError *error, NSDictionary *result){
        if(OBJECT_ISNOT_EMPTY(error)){
            FATAL_CORE_DATA_ERROR(error);
        }else{
            LOOP_DICTIONARY(result);
            //Rains Clouds Clear
        }
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
