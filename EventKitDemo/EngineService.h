//
//  EngineService.h
//  EventKitDemo
//
//  Created by YULIN CAI on 12/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EngineService : NSObject


//get the dictionaary of user's setting and transform to clips rules with reminder identifier
-(NSDictionary *)transformRules:(NSDictionary *)rules;
//transform devides information to clips fasts
-(BOOL)generateFacts:(NSDictionary *)facts;
-(BOOL)runEngine:(NSDictionary *)factsAndRules;


@end
