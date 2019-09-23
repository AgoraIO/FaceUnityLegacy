//
//  VideoFrame.m
//  TestProject
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import "VideoFrame.h"
//#import "VideoFrameBuffer.h"

const int64_t kNanosecondsPerSecond = 1000000000;

@implementation VideoFrame {
    VideoRotation _rotation;
    CMTime _timeStamp;
    BOOL _usingFrontCamera;
    int64_t _timeStampNs;
}

@synthesize buffer = _buffer;

- (int)width {
    return _buffer.width;
}

- (int)height {
    return _buffer.height;
}

- (id<VideoFrameBuffer>)buffer {
    return _buffer;
}

- (VideoRotation)rotation {
    return _rotation;
}

- (CMTime)timeStamp {
    return _timeStamp;
}

- (int64_t)timeStampNs {
    return _timeStampNs;
}

- (BOOL)usingFrontCamera {
    return _usingFrontCamera;
}

- (VideoFrame *)newI420VideoFrame {
    return [[VideoFrame alloc] initWithBuffer:[_buffer toI420]
                                        rotation:_rotation
                                       timeStamp:_timeStamp
                             usingFrontCamera:NO];
}


- (instancetype)initWithBuffer:(id<VideoFrameBuffer>)buffer
                      rotation:(VideoRotation)rotation
                     timeStamp:(CMTime)timeStamp
              usingFrontCamera:(BOOL)usingFrontCamera {
    if (self = [super init]) {
        _buffer = buffer;
        _rotation = rotation;
        _timeStamp = timeStamp;
        _usingFrontCamera = usingFrontCamera;
        _timeStampNs = CMTimeGetSeconds(_timeStamp) * kNanosecondsPerSecond;
    }
    
    return self;
}

@end
