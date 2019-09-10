//
//  VideoCapturer.h
//  RtmpStreamingKit
//
//  Created by Zhang Ji on 2019/9/8.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraVideoCapturer.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoCapturer : NSObject

- (instancetype)initWithCapturer:(CameraVideoCapturer *)capturer
                           width:(int)width
                          height:(int)height
                             fps:(NSInteger)fps;

- (void)startCapture;
- (void)stopCapture;
- (void)switchCamera;

@end

NS_ASSUME_NONNULL_END
