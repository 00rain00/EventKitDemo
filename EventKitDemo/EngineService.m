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

- (BOOL)generateFacts:(NSDictionary *)facts {
    EnvReset(clipsEnv);
    NSMutableArray *marrFacts = [NSMutableArray new];
    for(id key in facts){
      NSString *  theString = [NSString stringWithFormat: @"(%@ %@)",
                                                key,
                                                facts[key]];
        [marrFacts addObject:theString];
    }
   NSString * filePath = [[NSBundle mainBundle] pathForResource: @"system_en" ofType: @"fct"];
 char*  cFilePath = (char *) [filePath UTF8String];
    EnvLoadFacts(clipsEnv,cFilePath);

    for(NSString * fact in marrFacts){
     NSString *   assertCommand = [NSString stringWithFormat: @"(assert %@)",fact];
      int r =  [self evalString:assertCommand];
        DDLogDebug(@"eval string : %@, result :%d",assertCommand,r);
    }

    return NO;
}

- (BOOL)runEngine:(NSDictionary *)factsAndRules {
    EnvReset(clipsEnv);
    return NO;
}

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
