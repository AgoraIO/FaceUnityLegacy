//
//  VideoFrame.h
//  TestProject
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol VideoFrameBuffer;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VideoRotation) {
    VideoRotationNone = 0,
    VideoRotation90   = 90,
    VideoRotation180  = 180,
    VideoRotation270  = 270,
};

@interface VideoFrame : NSObject

/** Width without rotation applied. */
@property(nonatomic, readonly) int width;

/** Height without rotation applied. */
@property(nonatomic, readonly) int height;
@property(nonatomic, readonly) VideoRotation rotation;

@property(nonatomic, readonly) CMTime timeStamp;

/** Timestamp in nanoseconds. */
@property(nonatomic, readonly) int64_t timeStampNs;

/** Timestamp 90 kHz. */
//@property(nonatomic, assign) int32_t timeStamp;

@property(nonatomic, readonly) id<VideoFrameBuffer> buffer;
@property(nonatomic, readonly) BOOL usingFrontCamera;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype) new NS_UNAVAILABLE;

- (instancetype)initWithBuffer:(id<VideoFrameBuffer>)buffer
                      rotation:(VideoRotation)rotation
                     timeStamp:(CMTime)timeStamp
              usingFrontCamera:(BOOL)usingFrontCamera;

/** Return a frame that is guaranteed to be I420, i.e. it is possible to access
 *  the YUV data on it.
 */
- (VideoFrame *)newI420VideoFrame;

@end

NS_ASSUME_NONNULL_END
