//
//  YUVPlanarBuffer.h
//  RtmpStreamingKit
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "VideoFrameBuffer.h"

#ifndef YUVPlanarBuffer_h
#define YUVPlanarBuffer_h

@protocol YUVPlanarBuffer <VideoFrameBuffer>

@property(nonatomic, readonly) int chromaWidth;
@property(nonatomic, readonly) int chromaHeight;
@property(nonatomic, readonly) const uint8_t *dataY;
@property(nonatomic, readonly) const uint8_t *dataU;
@property(nonatomic, readonly) const uint8_t *dataV;
@property(nonatomic, readonly) int strideY;
@property(nonatomic, readonly) int strideU;
@property(nonatomic, readonly) int strideV;

- (instancetype)initWithWidth:(int)width
                       height:(int)height
                        dataY:(const uint8_t *)dataY
                        dataU:(const uint8_t *)dataU
                        dataV:(const uint8_t *)dataV;
- (instancetype)initWithWidth:(int)width height:(int)height;
- (instancetype)initWithWidth:(int)width
                       height:(int)height
                      strideY:(int)strideY
                      strideU:(int)strideU
                      strideV:(int)strideV;

@end

#endif /* YUVPlanarBuffer_h */
