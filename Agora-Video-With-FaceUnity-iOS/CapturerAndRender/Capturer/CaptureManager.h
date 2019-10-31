//
//  CaptureManager.h
//  TestProject
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraVideoCapturer.h"

NS_ASSUME_NONNULL_BEGIN

@interface CaptureManager : NSObject


- (instancetype)initWithWidth:(int)width
                       height:(int)height
                          fps:(int)fps;

- (instancetype)initWithCapturer:(CameraVideoCapturer *)capturer
                           width:(int)width
                          height:(int)height
                             fps:(int)fps;

- (void)startCapture;
- (void)stopCapture;
- (void)switchCamera;

@end

NS_ASSUME_NONNULL_END
