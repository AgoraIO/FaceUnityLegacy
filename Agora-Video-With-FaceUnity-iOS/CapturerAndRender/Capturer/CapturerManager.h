//
//  CaptureManager.h
//  TestProject
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
//#import "CameraVideoCapturer.h"
#import "VideoFrame.h"

NS_ASSUME_NONNULL_BEGIN

@class CapturerManager;

@protocol Connector;

@interface CapturerManager : NSObject

@property(nonatomic, weak) id<Connector> connector;

- (instancetype)initWithWidth:(int)width
                       height:(int)height
                          fps:(int)fps
                    connector:(nullable id<Connector>)connector;

- (void)startCapture;
- (void)stopCapture;
- (void)switchCamera;

@end

NS_ASSUME_NONNULL_END
