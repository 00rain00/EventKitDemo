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
@interface EngineService()
{
    void *clipsEnv;
}
@end
@implementation EngineService

DATA_OBJECT theResult;

-(instancetype)init{
    if((self = [super init])){
        [self setUpClipsEnvironment];

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
    EnvEval(clipsEnv,"(find-fact ((?f weather-result)) TRUE)",&theDO);
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

- (NSDictionary *)transformRules:(NSDictionary *)rules {

return nil;
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

    NSArray *factMembers =[xmlDocument nodesForXPath:@"//CLIPSScriptConfig/Script[1]" error:&error];

    if(OBJECT_IS_EMPTY(factMembers)){
        DDLogDebug(@"factMembers is empty");
    }
    if(OBJECT_ISNOT_EMPTY(error)){
        FATAL_CORE_DATA_ERROR(error)
    }else{
        NSString *string;
        for(GDataXMLElement *element in factMembers){
            string = element.stringValue;
            DDLogDebug(@"%@",string);
        }

        NSString *rule = [string stringByReplacingOccurrencesOfString:@"@weather" withString:rules[@"main"]];
        rule = [rule stringByReplacingOccurrencesOfString:@"@date" withString:rules[@"date"]];
        rule = [rule stringByReplacingOccurrencesOfString:@"@time" withString:rules[@"time"]];
        DDLogDebug(@"%@",rule);
        NSString *filepath = [[NSBundle mainBundle] pathForResource:@"rules" ofType:@"clp"];
        DDLogDebug(@"path : %@",filepath);
        [rule writeToFile:filepath atomically:NO encoding:NSUTF8StringEncoding error:&error];
    }


}




//- (BOOL)runEngine:(NSDictionary *)factsAndRules {
//    EnvReset(clipsEnv);
//    return NO;
//}

- (void)writeConditionToFile:(NSArray *)condition {
    DDLogDebug(@"");
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"rules" ofType:@"clp"];
    DDLogDebug(@"%@",filepath);
    NSError *error ;
   // NSMutableData *data;

    NSString *str = @"hello";
  //  char *cha  ="heello";
  //  data = [NSMutableData dataWithBytes:cha length:strlen(cha)];
   // NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:filepath];
    // [file writeData:data];
    //[file closeFile];

      [str writeToFile:filepath atomically:NO encoding:NSUTF8StringEncoding error:&error];

    if(OBJECT_ISNOT_EMPTY(error)){
        FATAL_CORE_DATA_ERROR(error);
    }
}

- (int)evalString: (NSString *) evalString
{
    char *cEvalString;
    DATA_OBJECT theRV;

    cEvalString = (char *) [evalString UTF8String];
   return EnvEval(clipsEnv,cEvalString,&theRV);
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
-(void)writeToFact
{

}

@end
