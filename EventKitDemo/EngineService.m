//
//  EngineService.m
//  EventKitDemo
//
//  Created by YULIN CAI on 12/10/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "EngineService.h"
#import <CLIPSios/clips.h>
const NSString * factPath;
@implementation EngineService
void *clipsEnv;
DATA_OBJECT theResult;

+ (NSString *)dataFilePath:(BOOL)forSave {
    return [[NSBundle mainBundle] pathForResource:@"Party" ofType:@"xml"];
}

+ (GDataXMLDocument *)loadXml {
DDLogDebug(@"");
    NSString *filePath = [self dataFilePath:FALSE];
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


-(int)setUpClipsEnvironment{
    clipsEnv = CreateEnvironment();
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"rules" ofType:@"clp"];
    char *Filepath = (char *) [filepath UTF8String];
    factPath = filepath;
    return   EnvLoad(clipsEnv,Filepath);
}

- (NSDictionary *)transformRules:(NSDictionary *)rules {

return nil;
}

+ (BOOL)generateFacts:(NSDictionary *)facts {
    DDLogDebug(@"");
    GDataXMLDocument *xmlDocument = [self loadXml];
   NSError *error;
   // NSArray *factMembers =[xmlDocument nodesForXPath:@"//CLIPSScriptConfig/Script[name = \"Fact_01\"]" error:&error];
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

            NSString *fact = [string stringByReplacingOccurrencesOfString:@"@weather" withString:facts[@"main"]];
            fact = [fact stringByReplacingOccurrencesOfString:@"@date" withString:facts[@"date"]];
            fact = [fact stringByReplacingOccurrencesOfString:@"@time" withString:facts[@"time"]];
            DDLogDebug(@"%@",fact);
        NSString *filepath = [[NSBundle mainBundle] pathForResource:@"rules" ofType:@"clp"];
        DDLogDebug(@"path : %@",filepath);
 [fact writeToFile:filepath atomically:NO encoding:NSUTF8StringEncoding error:&error];
    }

    






//    EnvReset(clipsEnv);
//    NSMutableArray *marrFacts = [NSMutableArray new];
//    for(id key in facts){
//      NSString *  theString = [NSString stringWithFormat: @"(%@ %@)",
//                                                key,
//                                                facts[key]];
//        [marrFacts addObject:theString];
//    }
//   NSString * filePath = [[NSBundle mainBundle] pathForResource: @"system_en" ofType: @"fct"];
// char*  cFilePath = (char *) [filePath UTF8String];
//    EnvLoadFacts(clipsEnv,cFilePath);
//
//    for(NSString * fact in marrFacts){
//     NSString *   assertCommand = [NSString stringWithFormat: @"(assert %@)",fact];
//    //  int r =  [self evalString:assertCommand];
////        DDLogDebug(@"eval string : %@, result :%d",assertCommand,r);
//    }

    return NO;
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
//    NSString *filePath;
//    char *cFilePath;
//    long long rulesFired;
//    NSString *factString, *assertCommand;
//
//    /*==============*/
//    /* Reset CLIPS. */
//    /*==============*/
//
//    EnvReset(clipsEnv);
//
//    /*========================*/
//    /* Load the animal facts. */
//    /*========================*/
//
//    filePath = [[NSBundle mainBundle] pathForResource: @"facts" ofType: @"fct"];
//    cFilePath = (char *) [filePath UTF8String];
//    EnvLoadFacts(clipsEnv,cFilePath);
//
//    for (factString in variableAsserts)
//    {
//        assertCommand = [NSString stringWithFormat: @"(assert %@)",factString];
//        [self evalString: assertCommand];
//    }
//
//    rulesFired = EnvRun(clipsEnv,-1);
//
//    [self handleResponse];
}
-(void)writeToFact
{

}

@end
