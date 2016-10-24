//
//  AppDelegate.m
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//


#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

NSString * const ManagedObjectContextSaveDidFailNotification = @"ManagedObjectContextSaveDidFailNotification";



@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //init DDlog
    [DDTTYLogger sharedInstance].logFormatter=[CustomerFormatter new];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console



    self.eventManager= [EventManager new];
    self.engineService= [EngineService new];
    DDLogDebug(@"application start");
    
    
//    //stay in background
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    [session setActive:YES error:nil];
//    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
//    //让 app 支持接受远程控制事件
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//    
//    //播放背景音乐
//    NSString *musicPath=[[NSBundle mainBundle] pathForResource:@"0db" ofType:@"mp3"];
//    NSURL *url=[[NSURL alloc]initFileURLWithPath:musicPath];
//    
//    //创建播放器
//    AVAudioPlayer *audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
//    
//    [audioPlayer prepareToPlay];
//    
//    //无限循环播放
//    audioPlayer.numberOfLoops=-1;
//    [audioPlayer play];
//    
//    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(printCurrentTime:) userInfo:nil repeats:YES];
    
    return YES;
    
    }

-(void)printCurrentTime:(id)sender{
    NSLog(@"当前的时间是---%@---",[self getCurrentTime]);
}
-(NSString *)getCurrentTime{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-DD HH:mm:ss"];
    NSString *dateTime=[dateFormatter stringFromDate:[NSDate date]];
    self.startTime=dateTime;
    return self.startTime;
}
							

@end
