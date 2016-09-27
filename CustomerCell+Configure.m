//
//  CustomerCell+Configure.m
//  EventKitDemo
//
//  Created by YULIN CAI on 27/09/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "CustomerCell+Configure.h"
#import "Event.h"

@class Event;
@implementation CustomerCell (Configure)

-(void)configureCellWithModel:(id)model {
    self.myname.text= [(Event *) model  name];
    self.myindex.text= [NSString stringWithFormat:@"%ld", (long)[(Event *) model index]];
    

}
@end
