
#import "EventManager.h"

@implementation EventManager

-(instancetype)init{
    if((self=[super init])){
        self.ekEventStore=[EKEventStore new];
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        if(OBJECT_ISNOT_EMPTY([userDefaults valueForKey:@"eventkit_events_access_granted"])){
            self.eventsAccessGranted= [[userDefaults valueForKey:@"eventkit_events_access_granted"] intValue];
        }
        else{
            self.eventsAccessGranted=NO;
        }
    }
    return self;
}

@end
