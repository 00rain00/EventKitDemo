//
//  EditEventViewModel.h
//  EventKitDemo
//
//  Created by YULIN CAI on 30/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EditEventViewModel : NSObject

@property (nonatomic, strong)NSMutableArray *displayConditions;

-(void)reflashCondition;

-(void)changeConditionStatus;

@end
