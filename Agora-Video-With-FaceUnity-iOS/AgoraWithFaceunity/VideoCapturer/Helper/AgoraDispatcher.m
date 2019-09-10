//
//  AgoraDispatcher.m
//  RtmpStreamingKit
//
//  Created by Zhang Ji on 2019/9/8.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import "AgoraDispatcher.h"

static dispatch_queue_t kAudioSessionQueue = nil;
static dispatch_queue_t kCaptureSessionQueue = nil;

@implementation AgoraDispatcher

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kAudioSessionQueue = dispatch_queue_create(
                                                   "io.agora.AgoraDispatcherAudioSession",
                                                   DISPATCH_QUEUE_SERIAL);
        kCaptureSessionQueue = dispatch_queue_create(
                                                     "io.agora.AgoraDispatcherCaptureSession",
                                                     DISPATCH_QUEUE_SERIAL);
    });
}

+ (void)dispatchAsyncOnType:(AgoraDispatcherQueueType)dispatchType
                      block:(dispatch_block_t)block {
    dispatch_queue_t queue = [self dispatchQueueForType:dispatchType];
    dispatch_async(queue, block);
}

+ (BOOL)isOnQueueForType:(AgoraDispatcherQueueType)dispatchType {
    dispatch_queue_t targetQueue = [self dispatchQueueForType:dispatchType];
    const char* targetLabel = dispatch_queue_get_label(targetQueue);
    const char* currentLabel = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
    
    NSAssert(strlen(targetLabel) > 0, @"Label is required for the target queue.");
    NSAssert(strlen(currentLabel) > 0, @"Label is required for the current queue.");
    
    return strcmp(targetLabel, currentLabel) == 0;
}

#pragma mark - Private

+ (dispatch_queue_t)dispatchQueueForType:(AgoraDispatcherQueueType)dispatchType {
    switch (dispatchType) {
        case AgoraDispatcherTypeMain:
            return dispatch_get_main_queue();
        case AgoraDispatcherTypeCaptureSession:
            return kCaptureSessionQueue;
        case AgoraDispatcherTypeAudioSession:
            return kAudioSessionQueue;
    }
}

@end
