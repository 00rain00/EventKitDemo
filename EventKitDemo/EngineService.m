//
//  EngineService.m
//  EventKitDemo
//
//  Created by YULIN CAI on 12/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "EngineService.h"
#import <CLIPSios/clips.h>

@implementation EngineService
void *clipsEnv;
DATA_OBJECT theResult;


-(int)setUpClipsEnvironment{
    clipsEnv = CreateEnvironment();
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"rules" ofType:@"clp"];
    char *Filepath = (char *) [filepath UTF8String];
    return   EnvLoad(clipsEnv,Filepath);

}

- (NSDictionary *)transformRules:(NSDictionary *)rules {
return nil;
}

- (BOOL)generateFacts:(NSDictionary *)facts {
    return NO;
}

- (BOOL)runEngine:(NSDictionary *)factsAndRules {
    return NO;
}


@end
