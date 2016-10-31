//
//  AddWeatherViewController.h
//  EventKitDemo
//
//  Created by YULIN CAI on 15/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XLForm/XLForm.h>
#import "CoreDataService.h"
@class AddWeatherViewController;
@class EKAlarm;

@protocol AddWeatherViewControllerDelegate<NSObject>
-(void)addWeatherViewController:(AddWeatherViewController *)controller:(EKAlarm *)item;
@end
@interface AddWeatherViewController : XLFormViewController
@property (nonatomic, weak)id <AddWeatherViewControllerDelegate> delegate;
-(IBAction)save:(id)sender;
@end
