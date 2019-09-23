//
//  AgoraDispatcher.h
//  RtmpStreamingKit
//
//  Created by Zhang Ji on 2019/9/8.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AgoraDispatcherQueueType) {
    // Main dispatcher queue.
    AgoraDispatcherTypeMain,
    // Used for starting/stopping AVCaptureSession, and assigning
    // capture session to AVCaptureVideoPreviewLayer.
    AgoraDispatcherTypeCaptureSession,
    // Used for operations on AVAudioSession.
    AgoraDispatcherTypeAudioSession,
};

NS_ASSUME_NONNULL_BEGIN

@interface AgoraDispatcher : NSObject

- (instancetype)init NS_UNAVAILABLE;

/** Dispatch the block asynchronously on the queue for dispatchType.
 *  @param dispatchType The queue type to dispatch on.
 *  @param block The block to dispatch asynchronously.
 */
+ (void)dispatchAsyncOnType:(AgoraDispatcherQueueType)dispatchType block:(dispatch_block_t)block;

/** Returns YES if run on queue for the dispatchType otherwise NO.
 *  Useful for asserting that a method is run on a correct queue.
 */
+ (BOOL)isOnQueueForType:(AgoraDispatcherQueueType)dispatchType;


@end

NS_ASSUME_NONNULL_END
