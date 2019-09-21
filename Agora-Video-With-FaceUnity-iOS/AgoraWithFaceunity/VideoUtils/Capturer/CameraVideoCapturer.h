//
//  VideoCapturer.h
//  RtmpStreamingKit
//
//  Created by Zhang Ji on 2019/9/6.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoCapturer.h"
#import "../VideoFrame/VideoFrame.h"

NS_ASSUME_NONNULL_BEGIN

@interface CameraVideoCapturer : VideoCapturer

// Capture session that is used for capturing. Valid from initialization to dealloc.
@property(readonly, nonatomic) AVCaptureSession *captureSession;

// Returns list of available capture devices that support video capture.
+ (NSArray<AVCaptureDevice *> *)captureDevices;
// Returns list of formats that are supported by this class for this device.
+ (NSArray<AVCaptureDeviceFormat *> *)supportedFormatsForDevice:(AVCaptureDevice *)device;

// Returns the most efficient supported output pixel format for this capturer.
- (FourCharCode)preferredOutputPixelFormat;

// Starts the capture session asynchronously and notifies callback on completion.
// The device will capture video in the format given in the `format` parameter. If the pixel format
// in `format` is supported by the WebRTC pipeline, the same pixel format will be used for the
// output. Otherwise, the format returned by `preferredOutputPixelFormat` will be used.
- (void)startCaptureWithDevice:(AVCaptureDevice *)device
                        format:(AVCaptureDeviceFormat *)format
                           fps:(int)fps
             completionHandler:(nullable void (^)(NSError *))completionHandler;
// Stops the capture session asynchronously and notifies callback on completion.
- (void)stopCaptureWithCompletionHandler:(nullable void (^)(void))completionHandler;

// Starts the capture session asynchronously.
- (void)startCaptureWithDevice:(AVCaptureDevice *)device
                        format:(AVCaptureDeviceFormat *)format
                           fps:(int)fps;
// Stops the capture session asynchronously.
- (void)stopCapture;

@end

NS_ASSUME_NONNULL_END
