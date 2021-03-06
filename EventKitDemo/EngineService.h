//
//  EngineService.h
//  EventKitDemo
//
//  Created by YULIN CAI on 12/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GDataXML_HTML/GDataXMLNode.h>
typedef NS_ENUM(NSInteger,ClipsEngStateReturn){
    OpenFileWithLoadError=-1,
    FileNotOpen,
    FileOpenSuccess
    
};

@interface EngineService : NSObject

-(int)setUpClipsEnvironment;


+(NSString *)generateFacts:(NSArray *)facts;
+(NSString *)generateTimeFacts;
+(void)generateRules:(NSArray *)rules;
+(NSString *)generateWeatherRules:(NSDictionary *)rules;
+(NSString *)generateTimeRules:(NSDictionary *)rules :(BOOL)haveWeekDay:(BOOL)haveMonthDay;
+ (NSString *)dataFilePath:(BOOL)forFact;
+ (GDataXMLDocument *)loadXml:(BOOL)forFact;
-(NSString *)handleResponse;
- (void) processRules;
-(NSString *)executeWeather:(NSString *)rulePath:(NSString *)factPath;
-(NSString *)executeTime:(NSString *)rulePath:(NSString *)factPath;

@end
