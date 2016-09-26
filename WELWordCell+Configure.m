//
//  WELWordCell+Configure.m
//  EventKitDemo
//
//  Created by YULIN CAI on 27/09/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "WELWordCell+Configure.h"

@implementation WELWordCell (Configure)

-(void)configureCellWithModel:(id)model {
    self.calenderTitle.text = model;
}

@end
