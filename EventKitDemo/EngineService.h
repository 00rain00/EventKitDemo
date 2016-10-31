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

//get the dictionaary of user's setting and transform to clips rules with reminder identifier
-(NSDictionary *)transformRules:(NSDictionary *)rules;
//transform devides information to clips fasts
+(BOOL)generateFacts:(NSDictionary *)facts;
-(BOOL)runEngine:(NSDictionary *)factsAndRules;
-(void)writeConditionToFile:(NSArray *)condition;
+ (NSString *)dataFilePath:(BOOL)forSave;
+ (NSString *)loadXml;

@end
