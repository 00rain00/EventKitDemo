//
//  LogFormatter.m
//  EventKitDemo
//
//  Created by YULIN CAI on 17/09/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "LogFormatter.h"

@implementation CustomerFormatter
-(NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *fileName=logMessage.fileName;
    NSString *function=logMessage.function;
    NSInteger line=logMessage.line;
    NSDate *timestam=logMessage.timestamp;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *dateString = [dateFormatter stringFromDate:timestam];
    return [NSString stringWithFormat:@"%@ %@ %@ %ld :%@",dateString, fileName,function, (long)line,logMessage->_message];
}
@end
