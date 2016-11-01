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


+(void)generateFacts:(NSArray *)facts;
+(void)generateRules:(NSArray *)rules;

+ (NSString *)dataFilePath:(BOOL)forFact;
+ (GDataXMLDocument *)loadXml:(BOOL)forFact;
-(void)handleResponse;
- (void) processRules;

@end
