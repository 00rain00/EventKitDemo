//
//  EngineService.m
//  EventKitDemo
//
//  Created by YULIN CAI on 12/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "EngineService.h"
#import <CLIPSios/clips.h>
#import "Fact+CoreDataClass.h"
#import "Condition.h"
static NSString *kNSDateHelperFormatSQLDate             = @"yyyy-MM-dd";
@interface EngineService()
{
    void *clipsEnv;
}
@end
@implementation EngineService

DATA_OBJECT theResult;

-(instancetype)init{
    if((self = [super init])){


    }
    return self;
}

+ (NSString *)dataFilePath:(BOOL)forFact {
    if(forFact){
        return [[NSBundle mainBundle] pathForResource:@"fact" ofType:@"xml"];
    }else{
        return [[NSBundle mainBundle] pathForResource:@"rule" ofType:@"xml"];
    }

}

+ (GDataXMLDocument *)loadXml :(BOOL)forFact{
    DDLogDebug(@"");
    NSString *filePath = [self dataFilePath:forFact];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData error:&error];
    if(OBJECT_ISNOT_EMPTY(error)){
        FATAL_CORE_DATA_ERROR(error);
    }else{
         NSLog(@"%@", doc.rootElement);
    }
    RETURN_NIL_WHEN_OBJECT_IS_EMPTY(doc);


    return doc;

}

- (void)handleResponse {
        DATA_OBJECT theDO;
    struct multifield *theMultifield;
    void *theFact;
    const char *theString;
    //get the fact list: the fact that name weather-result
    EnvEval(clipsEnv,"(find-fact ((?f temp-weather-result)) TRUE)",&theDO);
    if ((GetType(theDO) != MULTIFIELD) ||
            (GetDOLength(theDO) == 0))
    {
        DDLogDebug(@"No facts found in model");
        return;
    };
    if ((GetType(theDO) != MULTIFIELD) ||
            (GetDOLength(theDO) == 0)) return;

    theMultifield = GetValue(theDO);
    if (GetMFType(theMultifield,1) != FACT_ADDRESS) return;

    theFact = GetMFValue(theMultifield,1);
    EnvGetFactSlot(clipsEnv,theFact,"trigger",&theDO);
    if ((GetType(theDO) == SYMBOL) || (GetType(theDO) == STRING))
    { theString = DOToString(theDO); }
    else
    { theString = ""; }
    NSString *result = [NSString stringWithUTF8String:theString];
    DDLogDebug(@"result:%@", result);
    //compare the string value to determine the ekalrm


}


-(int)setUpClipsEnvironment{
    clipsEnv = CreateEnvironment();
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"rules" ofType:@"clp"];
    char *Filepath = (char *) [filepath UTF8String];

    return   EnvLoad(clipsEnv,Filepath);
}



+ (void)generateFacts:(NSArray *)facts {
    DDLogDebug(@"");
    GDataXMLDocument *xmlDocument = [self loadXml:YES];
   NSError *error;

    NSArray *factMembers =[xmlDocument nodesForXPath:@"//CLIPSScriptConfig/Script[1]" error:&error];
    
    if(OBJECT_IS_EMPTY(factMembers)){
        DDLogDebug(@"factMembers is empty");
    }
    if(OBJECT_ISNOT_EMPTY(error)){
        FATAL_CORE_DATA_ERROR(error)
    }else{
        NSString *string;

            GDataXMLElement *element = factMembers.firstObject;
           string = element.stringValue;
            DDLogDebug(@"%@",string);

        NSString *stringToWrite = @"";
        for(Fact *fact in facts){
            if([fact.factKey containsString:@"weather"]){
                NSDictionary * factValue = [NSKeyedUnarchiver unarchiveObjectWithData:fact.factValue];
                NSMutableArray *arr  = factValue[@"weather"];
                for(NSDictionary *dic in arr){
                    NSString *strFact = [string stringByReplacingOccurrencesOfString:@"@weather" withString:dic[@"main"]];
                    strFact = [strFact stringByReplacingOccurrencesOfString:@"@date" withString:dic[@"date"]];
                    strFact = [strFact stringByReplacingOccurrencesOfString:@"@time" withString:dic[@"time"]];
                    DDLogDebug(@"%@",strFact);
                   stringToWrite= [stringToWrite stringByAppendingFormat:@"%@\n",strFact];
                }

            }
        }


        NSString *filepath = [[NSBundle mainBundle] pathForResource:@"facts" ofType:@"fct"];
        DDLogDebug(@"path : %@",filepath);

            DDLogDebug(@"string to write: %@",stringToWrite);
            [stringToWrite writeToFile:filepath atomically:NO encoding:NSUTF8StringEncoding error:&error];


    }

}

+ (void)generateRules:(NSArray *)rules {
    //todo require condition preprocessing
    DDLogDebug(@"");
    GDataXMLDocument *xmlDocument = [self loadXml:NO];
    NSError *error;
    NSString *stringToWrite = @"";
    NSArray *ruleMembers =[xmlDocument nodesForXPath:@"//CLIPSRuleConfig/Script" error:&error];

    if(OBJECT_IS_EMPTY(ruleMembers)){
        DDLogDebug(@"factMembers is empty");
    }
    if(OBJECT_ISNOT_EMPTY(error)){
        FATAL_CORE_DATA_ERROR(error)
    }else{
        //read the template, the template need to load before the defrule
        GDataXMLElement *template = ruleMembers[2];
     stringToWrite=   [stringToWrite stringByAppendingFormat:@"%@\n",template.stringValue];
        GDataXMLElement *template1 = ruleMembers[1];
        stringToWrite = [stringToWrite stringByAppendingFormat:@"%@\n",template1.stringValue];

        NSString *string;
       GDataXMLElement *element = ruleMembers.firstObject;
        string = element.stringValue;
        for(Condition * condition  in rules){
            if([condition.myKey isEqualToString:@"Weather"]){
                NSDictionary *myValue = [NSKeyedUnarchiver unarchiveObjectWithData:condition.myValue];
                NSString *forecastTime = myValue[@"forecastTime"];

                NSString *forecastType = myValue[@"forecastType"];
                NSString *rule = [string stringByReplacingOccurrencesOfString:@"@weather" withString:@"Rain"];
                if([forecastTime isEqualToString:@"Tomorrow"]){
                    rule = [rule stringByReplacingOccurrencesOfString:@"@date" withString:[NSDate.dateTomorrow stringWithFormat:kNSDateHelperFormatSQLDate]];
                    rule = [rule stringByReplacingOccurrencesOfString:@"@time" withString:@"?"];
                }else{
                    rule = [rule stringByReplacingOccurrencesOfString:@"@date" withString:[[NSDate new] stringWithFormat:kNSDateHelperFormatSQLDate]];
                    rule = [rule stringByReplacingOccurrencesOfString:@"@time" withString:@"?"];
                }
          DDLogDebug(@"rule : %@",rule);
                NSString *filepath = [[NSBundle mainBundle] pathForResource:@"rules" ofType:@"clp"];
                stringToWrite = [stringToWrite stringByAppendingFormat:@"%@\n",rule];
                DDLogDebug(@"path : %@",filepath);
                DDLogDebug(@"string to write : %@",stringToWrite);
                [stringToWrite writeToFile:filepath atomically:NO encoding:NSUTF8StringEncoding error:&error];
            }
        }


    }


}

- (void) processRules
{
    NSString *filePath;
    char *cFilePath;
    EnvReset(clipsEnv);
    filePath = [[NSBundle mainBundle] pathForResource: @"facts" ofType: @"fct"];
    cFilePath = (char *) [filePath UTF8String];
    EnvLoadFacts(clipsEnv,cFilePath);
     EnvRun(clipsEnv,-1);
    [self handleResponse];
}


@end
