//
//  AppDelegate.h
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "EventManager.h"
#import "EngineService.h"
#import "ViewController.h"
#import <OpenWeatherMapAPI/OWMWeatherAPI.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic)EventManager *eventManager;

@property (strong, nonatomic)EngineService *engineService;

@property(strong,nonatomic)ViewController * controller;

@property (strong, nonatomic) NSString *startTime;
@property (nonatomic, strong)CoreDataService *cd;

@property(nonatomic,assign)CGFloat autoSizeScaleX;
 @property(nonatomic,assign)CGFloat autoSizeScaleY;


-(void)generateFacts;
-(void)evaluationCondition;
@end
