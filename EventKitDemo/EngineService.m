//
//  EngineService.m
//  EventKitDemo
//
//  Created by YULIN CAI on 12/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "EngineService.h"
#import <CLIPSios/clips.h>
#import <NSDate_Escort/NSDate+Escort.h>
#import "Fact+CoreDataClass.h"
#import "Condition.h"
static NSString *kNSDateHelperFormatSQLDate             = @"yyyy-MM-dd";
static NSString *kNSDateHelperFormatSQLTime             = @"HH:mm:ss";
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

- (NSString *)handleResponse {
    DATA_OBJECT theDO;
    struct multifield *theMultifield;
    void *theFact;
    const char *theString;
    //get the fact list: the fact that name weather-result
    EnvEval(clipsEnv,"(find-fact ((?f temp-weather-result)) TRUE)",&theDO);
    if ((GetType(theDO) != MULTIFIELD) ||
            (GetDOLength(theDO) == 0))
    {
        DDLogDebug(@" facts not found in model");
        return nil;
    };
    if ((GetType(theDO) != MULTIFIELD) ||
            (GetDOLength(theDO) == 0)) return nil;

    theMultifield = GetValue(theDO);
    if (GetMFType(theMultifield,1) != FACT_ADDRESS) return nil;

    theFact = GetMFValue(theMultifield,1);
    EnvGetFactSlot(clipsEnv,theFact,"trigger",&theDO);
    if ((GetType(theDO) == SYMBOL) || (GetType(theDO) == STRING))
    { theString = DOToString(theDO); }
    else
    { theString = ""; }
    NSString *result = [NSString stringWithUTF8String:theString];
    DDLogDebug(@"result:%@", result);
    //compare the string value to determine the ekalrm
    return result;
}


-(int)setUpClipsEnvironment{
    clipsEnv = CreateEnvironment();
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"rules" ofType:@"clp"];
    char *Filepath = (char *) [filepath UTF8String];

    return   EnvLoad(clipsEnv,Filepath);
}



+ (NSString *)generateFacts:(NSArray *)facts {
    DDLogDebug(@"");
    NSString *filepath;
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
        //loop the contextual information collecion
        for(Fact *fact in facts){
            if([fact.factKey containsString:@"weather"]){
                NSDictionary * factValue = [NSKeyedUnarchiver unarchiveObjectWithData:fact.factValue];
                NSMutableArray *arr  = factValue[@"weather"];
                for(NSDictionary *dic in arr){
                    //replace the value accordingly
                    NSString *strFact = [string stringByReplacingOccurrencesOfString:@"@weather" withString:dic[@"main"]];
                    strFact = [strFact stringByReplacingOccurrencesOfString:@"@date" withString:dic[@"date"]];
                    strFact = [strFact stringByReplacingOccurrencesOfString:@"@time" withString:dic[@"time"]];
                    DDLogDebug(@"%@",strFact);
                    //write to file
                   stringToWrite= [stringToWrite stringByAppendingFormat:@"%@\n",strFact];
                }

            }
        }


      //  NSString *filepath = [[NSBundle mainBundle] pathForResource:@"facts" ofType:@"fct"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
       filepath = [documentsDirectory stringByAppendingPathComponent:@"facts.fct"];






        DDLogDebug(@"path : %@",filepath);

          //  DDLogDebug(@"string to write: %@",stringToWrite);

        @try {

            [stringToWrite writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:&error];
            NSError *attributesError;
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filepath error:&attributesError];

            NSNumber *fileSizeNumber = fileAttributes[NSFileSize];
            long long fileSize = [fileSizeNumber longLongValue];
            DDLogDebug(@"file size for fact: %lu",fileSize);
        }
        @catch (NSException *exception) {
            DDLogDebug(@"%@", exception.reason);
        }


    }
return filepath;
}
+(BOOL)validation:(NSDictionary *)factValue withtemplae:(NSString *)template{
    BOOL flag = NO;
   
    //get the wildcard element
  NSArray *arrElement =   [template componentsSeparatedByString:@"@"];
    //loop the collection
    //check the size
    if(factValue.count!=arrElement.count){
        return NO;
    }else{
        for(NSObject *key in factValue){
            //get the key
            NSString *strKey = [NSString stringWithFormat:@"%@", key.description];
            BOOL pair = NO;
            for(NSString *element in arrElement){
                //check if the key can pair any element
                if([element compare:strKey]){
                    pair = YES;
                    break;
                }
            }
            //if no pair then return false
            if(!pair){
                return NO;
            }
        }
        flag = YES;
    }

    
    return flag;
}


+ (void)generateRules:(NSArray *)rules {

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

+ (NSString *)generateWeatherRules:(NSDictionary *)myValue {

    DDLogDebug(@"start");
    NSString *filepath;
    GDataXMLDocument *xmlDocument = [self loadXml:NO];
    NSError *error;
    NSString *stringToWrite = @"";
    NSArray *ruleMembers =[xmlDocument nodesForXPath:@"//CLIPSRuleConfig/Script" error:&error];
   NSArray *templateMembers =[xmlDocument nodesForXPath:@"//CLIPSRuleConfig/Template" error:&error];
    if(OBJECT_IS_EMPTY(ruleMembers)){
        DDLogDebug(@"factMembers is empty");
    }
    if(OBJECT_IS_EMPTY(templateMembers)){
        DDLogDebug(@"templatesMembers is empty");
    }
    if(OBJECT_ISNOT_EMPTY(error)){
        FATAL_CORE_DATA_ERROR(error)
    }else{
        //read the template, the template need to load before the defrule
        GDataXMLElement *template = templateMembers[0];
        stringToWrite=   [stringToWrite stringByAppendingFormat:@"%@",template.stringValue];
        GDataXMLElement *template1 = templateMembers[3];
        stringToWrite = [stringToWrite stringByAppendingFormat:@"%@",template1.stringValue];

        NSString *string;
        GDataXMLElement *element = ruleMembers.firstObject;
        string = element.stringValue;



                NSString *forecastTime = myValue[@"forecastTime"];

                NSString *forecastType = myValue[@"forecastType"];
        NSString *compareType ;
        if([forecastType isEqualToString:@"Clear Sky"]){
            compareType = @"Clear";
        }else if([forecastType isEqualToString:@"Rainy"]){
            compareType = @"Rain";
        }else{
            compareType = @"Clouds";
        }
                NSString *rule = [string stringByReplacingOccurrencesOfString:@"@weather" withString:compareType];
                if([forecastTime isEqualToString:@"Tomorrow"]){
                    rule = [rule stringByReplacingOccurrencesOfString:@"@date" withString:[NSDate.dateTomorrow stringWithFormat:kNSDateHelperFormatSQLDate]];
                    rule = [rule stringByReplacingOccurrencesOfString:@"@time" withString:@"?"];
                }else{
                    rule = [rule stringByReplacingOccurrencesOfString:@"@date" withString:[[NSDate new] stringWithFormat:kNSDateHelperFormatSQLDate]];
                    NSDate *Threehourlater = [[NSDate new] dateByAddingHoursClearMinutesAndSeconds:3];
                    rule = [rule stringByReplacingOccurrencesOfString:@"@time" withString:[Threehourlater stringWithFormat:kNSDateHelperFormatSQLTime]];
                }
                DDLogDebug(@"rule : %@",rule);
               // NSString *filepath = [[NSBundle mainBundle] pathForResource:@"rules" ofType:@"clp"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
                stringToWrite = [stringToWrite stringByAppendingFormat:@"%@",rule];
        filepath = [documentsDirectory stringByAppendingPathComponent:@"rules.clp"];
                DDLogDebug(@"path : %@",filepath);
                DDLogDebug(@"string to write : %@",stringToWrite);
                [stringToWrite writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:&error];
NSError *attributesError;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filepath error:&attributesError];

        NSNumber *fileSizeNumber = fileAttributes[NSFileSize];
        long long fileSize = [fileSizeNumber longLongValue];
        DDLogDebug(@"file size for rule: %lu",fileSize);
    }
    return filepath;
}


- (void) processRules
{
    DDLogDebug(@"start");
    NSString *filePath;
    char *cFilePath;
    EnvReset(clipsEnv);
    filePath = [[NSBundle mainBundle] pathForResource: @"facts" ofType: @"fct"];
    cFilePath = (char *) [filePath UTF8String];
   int result = 0;
   result =  EnvLoadFacts(clipsEnv,cFilePath);
    DDLogDebug(@"envloadfacts: %d",result);
  result = (int) EnvRun(clipsEnv,-1);
    DDLogDebug(@"EnvRun: %d",result);
    DDLogDebug(@"ends");

}

- (NSString *)executeWeather:(NSString *)rulePath :(NSString *)factPath{
    clipsEnv = CreateEnvironment();

    char *rulepath = (char *) [rulePath UTF8String];

    EnvLoad(clipsEnv,rulepath);
    DDLogDebug(@"start");

    char *cFilePath;
    EnvReset(clipsEnv);

    cFilePath = (char *) [factPath UTF8String];
    int result = 0;
    result =  EnvLoadFacts(clipsEnv,cFilePath);
    DDLogDebug(@"envloadfacts: %d",result);
    result = (int) EnvRun(clipsEnv,-1);
    DDLogDebug(@"EnvRun: %d",result);
    DDLogDebug(@"ends");
    DATA_OBJECT theDO;
    struct multifield *theMultifield;
    void *theFact;
    const char *theString;
    //get the fact list: the fact that name weather-result
    EnvEval(clipsEnv,"(find-fact ((?f temp-weather-result)) TRUE)",&theDO);
    if ((GetType(theDO) != MULTIFIELD) ||
            (GetDOLength(theDO) == 0))
    {
        DDLogDebug(@" facts not found in model");
        return nil;
    };
    if ((GetType(theDO) != MULTIFIELD) ||
            (GetDOLength(theDO) == 0)) return nil;

    theMultifield = GetValue(theDO);
    if (GetMFType(theMultifield,1) != FACT_ADDRESS) return nil;

    theFact = GetMFValue(theMultifield,1);
    EnvGetFactSlot(clipsEnv,theFact,"trigger",&theDO);
    if ((GetType(theDO) == SYMBOL) || (GetType(theDO) == STRING))
    { theString = DOToString(theDO); }
    else
    { theString = ""; }
    NSString *result1 = [NSString stringWithUTF8String:theString];
    DDLogDebug(@"result1:%@", result1);
    //compare the string value to determine the ekalrm
    return result1;

}


@end
