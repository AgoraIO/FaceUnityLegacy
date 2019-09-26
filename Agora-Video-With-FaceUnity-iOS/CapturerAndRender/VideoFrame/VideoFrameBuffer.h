//
//  VideoFrameBuffer.h
//  RtmpStreamingKit
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#ifndef VideoFrameBuffer_h
#define VideoFrameBuffer_h

@protocol I420Buffer;

@protocol VideoFrameBuffer <NSObject>

@property(nonatomic, readonly) int width;
@property(nonatomic, readonly) int height;

//- (id<I420Buffer>)toI420;

@end

#endif /* VideoFrameBuffer_h */
