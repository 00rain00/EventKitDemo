//
//  CreateAlarmFormViewController.h
//  EventKitDemo
//
//  Created by YULIN CAI on 30/09/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <XLForm/XLForm.h>

@class EKAlarm;

@interface CreateAlarmFormViewController : XLFormViewController
@property (nonatomic) NSTimeInterval offset;

@property (nonatomic, strong)EKAlarm *ekAlarm;
@property (nonatomic, strong)NSDictionary *dictionary;
@end
