//
//  LogCenter.m
//  RtmpStreamingKit
//
//  Created by Zhang Ji on 2019/9/9.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import "LogCenter.h"

void AgoraLogEx(AgoraLoggingSeverity severity, NSString* log_string) {
    NSString *logSeverity = [NSString alloc];
    switch (severity) {
        case AgoraLoggingSeverityInfo:
            logSeverity = @"Info";
            break;
        case AgoraLoggingSeverityVerbose:
            logSeverity = @"Verbose";
            break;
        case AgoraLoggingSeverityWarning:
            logSeverity = @"Warning";
            break;
        case AgoraLoggingSeverityError:;
            logSeverity = @"Error";
            break;
        case AgoraLoggingSeverityNone:
            logSeverity = @"None";
            break;
        default:
            break;
    }
    NSString *log = [NSString stringWithFormat:@"%@: %@", logSeverity, log_string];
    NSLog(@"%@", log);
}
