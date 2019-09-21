//
//  LogCenter.h
//  RtmpStreamingKit
//
//  Created by Zhang Ji on 2019/9/9.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AgoraLoggingSeverity) {
    AgoraLoggingSeverityVerbose,
    AgoraLoggingSeverityInfo,
    AgoraLoggingSeverityWarning,
    AgoraLoggingSeverityError,
    AgoraLoggingSeverityNone,
};

void AgoraLogEx(AgoraLoggingSeverity severity, NSString* log_string);

// Returns the filename with the path prefix removed.
NSString* RTCFileName(const char* filePath);

#define AgoraLogString(format, ...)                                           \
[NSString stringWithFormat:@"(:%d %s): " format, \
__LINE__, __FUNCTION__, ##__VA_ARGS__]

#define AgoraLogFormat(severity, format, ...)                     \
NSString* log_string = AgoraLogString(format, ##__VA_ARGS__);\
AgoraLogEx(severity, log_string);     \

#define AgoraLogVerbose(format, ...) \
AgoraLogFormat(AgoraLoggingSeverityVerbose, format, ##__VA_ARGS__)

#define AgoraLogInfo(format, ...) \
AgoraLogFormat(AgoraLoggingSeverityInfo, format, ##__VA_ARGS__)

#define AgoraLogWarning(format, ...) \
AgoraLogFormat(AgoraLoggingSeverityWarning, format, ##__VA_ARGS__)

#define AgoraLogError(format, ...) \
AgoraLogFormat(AgoraLoggingSeverityError, format, ##__VA_ARGS__)

#if !defined(NDEBUG)
#define AgoraLogDebug(format, ...) AgoraLogInfo(format, ##__VA_ARGS__)
#else
#define AgoraLogDebug(format, ...) \
do {                           \
} while (false)
#endif

#define AgoraLog(format, ...) AgoraLogInfo(format, ##__VA_ARGS__)
