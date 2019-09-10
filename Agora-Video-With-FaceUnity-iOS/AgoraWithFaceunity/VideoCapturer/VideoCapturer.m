//
//  VideoCapturer.m
//  RtmpStreamingKit
//
//  Created by Zhang Ji on 2019/9/8.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import "VideoCapturer.h"
#import "Helper/LogCenter.h"

const Float64 kFramerateLimit = 30.0;

@implementation VideoCapturer {
    CameraVideoCapturer *_capturer;
    int _width;
    int _height;
    NSInteger _fps;
    BOOL _usingFrontCamera;
}

- (instancetype)initWithCapturer:(CameraVideoCapturer *)capturer
                           width:(int)width
                          height:(int)height
                             fps:(NSInteger)fps {
    if (self = [super init]) {
        _capturer = capturer;
        _width = width;
        _height = height;
        _fps = fps;
        _usingFrontCamera = YES;
    }
    
    return  self;
}

- (void)startCapture {
    AVCaptureDevicePosition position = _usingFrontCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    AVCaptureDevice *device = [self findDeviceForPosition:position];
    AVCaptureDeviceFormat *format = [self selectFormatForDevice:device];
    
    if (format == nil) {
        AgoraLogError(@"No valid formats for device %@", device);
        NSAssert(NO, @"");
        
        return;
    }
    
    NSInteger fps = [self selectFpsForFormat:format];
    
    [_capturer startCaptureWithDevice:device format:format fps:fps];
}

- (void)stopCapture {
    [_capturer stopCapture];
}

- (void)switchCamera {
    _usingFrontCamera = !_usingFrontCamera;
    [self startCapture];
}

#pragma mark - Private

- (AVCaptureDevice *)findDeviceForPosition:(AVCaptureDevicePosition)position {
    NSArray<AVCaptureDevice *> *captureDevices = [CameraVideoCapturer captureDevices];
    for (AVCaptureDevice *device in captureDevices) {
        if (device.position == position) {
            return device;
        }
    }
    return captureDevices[0];
}

- (AVCaptureDeviceFormat *)selectFormatForDevice:(AVCaptureDevice *)device {
    NSArray<AVCaptureDeviceFormat *> *formats =
    [CameraVideoCapturer supportedFormatsForDevice:device];
    int targetWidth = _width;
    int targetHeight = _height;
    AVCaptureDeviceFormat *selectedFormat = nil;
    int currentDiff = INT_MAX;
    
    for (AVCaptureDeviceFormat *format in formats) {
        CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        FourCharCode pixelFormat = CMFormatDescriptionGetMediaSubType(format.formatDescription);
        int diff = abs(targetWidth - dimension.width) + abs(targetHeight - dimension.height);
        if (diff < currentDiff) {
            selectedFormat = format;
            currentDiff = diff;
        } else if (diff == currentDiff && pixelFormat == [_capturer preferredOutputPixelFormat]) {
            selectedFormat = format;
        }
    }
    
    return selectedFormat;
}

- (NSInteger)selectFpsForFormat:(AVCaptureDeviceFormat *)format {
    Float64 maxSupportedFramerate = 0;
    for (AVFrameRateRange *fpsRange in format.videoSupportedFrameRateRanges) {
        maxSupportedFramerate = fmax(maxSupportedFramerate, fpsRange.maxFrameRate);
    }
    maxSupportedFramerate = fmin(maxSupportedFramerate, kFramerateLimit);
    return fmin(maxSupportedFramerate, _fps);
}

@end
