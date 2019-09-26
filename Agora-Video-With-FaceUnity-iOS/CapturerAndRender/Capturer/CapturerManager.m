//
//  CaptureManager.m
//  TestProject
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import "CapturerManager.h"
#import "CustomCVPixelBuffer.h"
#import "CameraVideoCapturer.h"
#import "LogCenter.h"
#import "Connector.h"

const Float64 kFramerateLimit = 30.0;

@interface CapturerManager() <VideoCapturerDelegate>

@end

@implementation CapturerManager {
    CameraVideoCapturer *_capturer;
    int _width;
    int _height;
    int _fps;
    BOOL _usingFrontCamera;
}

- (instancetype)initWithWidth:(int)width
                       height:(int)height
                          fps:(int)fps
                    connector:(nullable id<Connector>)connector; {
    if (self = [super init]) {
        _capturer = [[CameraVideoCapturer alloc] initWithDelegate:self];
        _width = width >= height ? width : height;
        _height = height >= width ? width : height;
        _fps = fps;
        _usingFrontCamera = YES;
        _connector = connector;
    }
    
    return  self;
}

//- (instancetype)initWithCapturer:(CameraVideoCapturer *)capturer
//                           width:(int)width
//                          height:(int)height
//                             fps:(int)fps {
//    if (self = [super init]) {
//        _capturer = capturer;
//        _width = width >= height ?K width : height;
//        _height = height >= width ? width : height;
//        _fps = fps;
//        _usingFrontCamera = YES;
//    }
//
//    return  self;
//}

- (void)startCapture {
    AVCaptureDevicePosition position = _usingFrontCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    AVCaptureDevice *device = [self findDeviceForPosition:position];
    AVCaptureDeviceFormat *format = [self selectFormatForDevice:device];
    
    if (format == nil) {
        NSAssert(NO, @"No valid formats for device %@", device);
        return;
    }
    
    int fps = [self selectFpsForFormat:format];
    
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

- (int)selectFpsForFormat:(AVCaptureDeviceFormat *)format {
    Float64 maxSupportedFramerate = 0;
    for (AVFrameRateRange *fpsRange in format.videoSupportedFrameRateRanges) {
        maxSupportedFramerate = fmax(maxSupportedFramerate, fpsRange.maxFrameRate);
    }
    maxSupportedFramerate = fmin(maxSupportedFramerate, kFramerateLimit);
    return fmin(maxSupportedFramerate, _fps);
}

- (void)capturer:(VideoCapturer *)capturer didCaptureFrame:(VideoFrame *)frame {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.connector respondsToSelector:@selector(didOutputFrame:)]) {
            [self.connector didOutputFrame:frame];
        }
        
//        if ([self.connector respondsToSelector:@selector(didOutputPixelBuffer:withTimeStamp:rotation:)]) {
//            if ([frame.buffer isKindOfClass:[CustomCVPixelBuffer class]]) {
//                CustomCVPixelBuffer* buffer = frame.buffer;
//                [self.connector didOutputPixelBuffer:buffer.pixelBuffer withTimeStamp:frame.timeStamp rotation:frame.rotation];
//            }
//        }
    });
}

@end
