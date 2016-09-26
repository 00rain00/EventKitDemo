//
//  WELTableDelegate.h
//  EventKitDemo
//
//  Created by YULIN CAI on 27/09/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WELTableDelegate : NSObject <UITableViewDelegate>

@property (nonatomic, weak) IBOutlet id <UITableViewDelegate>viewController;

@end
