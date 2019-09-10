//
//  VideoCapturer.m
//  RtmpStreamingKit
//
//  Created by Zhang Ji on 2019/9/6.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraVideoCapturer.h"
#import "AgoraDispatcher.h"

#import "AVCaptureSession+DevicePosition.h"
#import "Helper/LogCenter.h"

typedef NS_ENUM(NSInteger, AgoraVideoRotation) {
    AgoraVideoRotation_0 = 0,
    AgoraVideoRotation_90 = 90,
    AgoraVideoRotation_180 = 180,
    AgoraVideoRotation_270 = 270,
};

@interface CameraVideoCapturer ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property(nonatomic, readonly) dispatch_queue_t frameQueue;
@property(nonatomic, strong) AVCaptureDevice *currentDevice;
@property(nonatomic, assign) BOOL hasRetriedOnFatalError;
@property(nonatomic, assign) BOOL isRunning;
// Will the session be running once all asynchronous operations have been completed?
@property(nonatomic, assign) BOOL willBeRunning;
@end

@implementation CameraVideoCapturer {
    AVCaptureVideoDataOutput *_videoDataOutput;
    AVCaptureSession *_captureSession;
    FourCharCode _preferredOutputPixelFormat;
    FourCharCode _outputPixelFormat;
    AVCaptureConnection *_videoConnection;
    AgoraVideoRotation _rotation;
#if TARGET_OS_IPHONE
    UIDeviceOrientation _orientation;
#endif
}

@synthesize frameQueue = _frameQueue;
@synthesize captureSession = _captureSession;
@synthesize currentDevice = _currentDevice;
@synthesize hasRetriedOnFatalError = _hasRetriedOnFatalError;
@synthesize isRunning = _isRunning;
@synthesize willBeRunning = _willBeRunning;
@synthesize delegate = _delegate;

- (instancetype)init {
    return [self initWithDelegate:nil captureSession:[[AVCaptureSession alloc] init]];
}

- (instancetype)initWithDelegate:(__weak id<CameraVideoCapturerDelegate>)delegate {
    return [self initWithDelegate:delegate captureSession:[[AVCaptureSession alloc] init]];
}

// This initializer is used for testing.
- (instancetype)initWithDelegate:(__weak id<CameraVideoCapturerDelegate>)delegate
                  captureSession:(AVCaptureSession *)captureSession {
    if (self = [super init]) {
        _delegate = delegate;
        // Create the capture session and all relevant inputs and outputs. We need
        // to do this in init because the application may want the capture session
        // before we start the capturer for e.g. AVCapturePreviewLayer. All objects
        // created here are retained until dealloc and never recreated.
        if (![self setupCaptureSession:captureSession]) {
            return nil;
        }
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
#if TARGET_OS_IPHONE
        _orientation = UIDeviceOrientationPortrait;
        _rotation = AgoraVideoRotation_90;
        [center addObserver:self
                   selector:@selector(deviceOrientationDidChange:)
                       name:UIDeviceOrientationDidChangeNotification
                     object:nil];
        [center addObserver:self
                   selector:@selector(handleCaptureSessionInterruption:)
                       name:AVCaptureSessionWasInterruptedNotification
                     object:_captureSession];
        [center addObserver:self
                   selector:@selector(handleCaptureSessionInterruptionEnded:)
                       name:AVCaptureSessionInterruptionEndedNotification
                     object:_captureSession];
        [center addObserver:self
                   selector:@selector(handleApplicationDidBecomeActive:)
                       name:UIApplicationDidBecomeActiveNotification
                     object:[UIApplication sharedApplication]];
#endif
        [center addObserver:self
                   selector:@selector(handleCaptureSessionRuntimeError:)
                       name:AVCaptureSessionRuntimeErrorNotification
                     object:_captureSession];
        [center addObserver:self
                   selector:@selector(handleCaptureSessionDidStartRunning:)
                       name:AVCaptureSessionDidStartRunningNotification
                     object:_captureSession];
        [center addObserver:self
                   selector:@selector(handleCaptureSessionDidStopRunning:)
                       name:AVCaptureSessionDidStopRunningNotification
                     object:_captureSession];
    }
    return self;
}

- (void)dealloc {
    NSAssert(
             !_willBeRunning,
             @"Session was still running in RTCCameraVideoCapturer dealloc. Forgot to call stopCapture?");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (NSArray<AVCaptureDevice *> *)captureDevices {
#if defined(__IPHONE_10_0) && \
__IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_10_0
    AVCaptureDeviceDiscoverySession *session = [AVCaptureDeviceDiscoverySession
                                                discoverySessionWithDeviceTypes:@[ AVCaptureDeviceTypeBuiltInWideAngleCamera ]
                                                mediaType:AVMediaTypeVideo
                                                position:AVCaptureDevicePositionUnspecified];
    return session.devices;
#else
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
#endif
}

+ (NSArray<AVCaptureDeviceFormat *> *)supportedFormatsForDevice:(AVCaptureDevice *)device {
    // Support opening the device in any format. We make sure it's converted to a format we
    // can handle, if needed, in the method `-setupVideoDataOutput`.
    return device.formats;
}

- (FourCharCode)preferredOutputPixelFormat {
    return _preferredOutputPixelFormat;
}

- (void)startCaptureWithDevice:(AVCaptureDevice *)device
                        format:(AVCaptureDeviceFormat *)format
                           fps:(NSInteger)fps {
    [self startCaptureWithDevice:device format:format fps:fps completionHandler:nil];
}

- (void)stopCapture {
    [self stopCaptureWithCompletionHandler:nil];
}

- (void)startCaptureWithDevice:(AVCaptureDevice *)device
                        format:(AVCaptureDeviceFormat *)format
                           fps:(NSInteger)fps
             completionHandler:(nullable void (^)(NSError *))completionHandler {
    _willBeRunning = YES;
    
    [AgoraDispatcher
     dispatchAsyncOnType:AgoraDispatcherTypeCaptureSession
     block:^{
         AgoraLogInfo("startCaptureWithDevice %@ @ %ld fps", format, (long)fps);
         [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

         self.currentDevice = device;
         
         NSError *error = nil;
         if (![self.currentDevice lockForConfiguration:&error]) {
             AgoraLogError(@"Failed to lock device %@. Error: %@",
                         self.currentDevice,
                         error.userInfo);
             if (completionHandler) {
                 completionHandler(error);
             }
             self.willBeRunning = NO;
             return;
         }
         [self reconfigureCaptureSessionInput];
         [self setupVideoConnection];
         [self updateOrientation];
         [self updateDeviceCaptureFormat:format fps:fps];
         [self updateVideoDataOutputPixelFormat:format];
         [self.captureSession startRunning];
         [self.currentDevice unlockForConfiguration];
         self.isRunning = YES;
         if (completionHandler) {
             completionHandler(nil);
         }
     }];
}

- (void)stopCaptureWithCompletionHandler:(nullable void (^)(void))completionHandler {
    _willBeRunning = NO;
    [AgoraDispatcher
     dispatchAsyncOnType:AgoraDispatcherTypeCaptureSession
     block:^{
//         RTCLogInfo("Stop");
         self.currentDevice = nil;
         for (AVCaptureDeviceInput *oldInput in [self.captureSession.inputs copy]) {
             [self.captureSession removeInput:oldInput];
         }
         [self.captureSession stopRunning];
         
#if TARGET_OS_IPHONE
         [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
#endif
         self.isRunning = NO;
         if (completionHandler) {
             completionHandler();
         }
     }];
}

#pragma mark iOS notifications

#if TARGET_OS_IPHONE
- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [AgoraDispatcher dispatchAsyncOnType:AgoraDispatcherTypeCaptureSession
                                 block:^{
                                     [self updateOrientation];
                                 }];
}
#endif

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    NSParameterAssert(captureOutput == _videoDataOutput);
    
    if (CMSampleBufferGetNumSamples(sampleBuffer) != 1 || !CMSampleBufferIsValid(sampleBuffer) ||
        !CMSampleBufferDataIsReady(sampleBuffer)) {
        return;
    }
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer == nil) {
        return;
    }
    
#if TARGET_OS_IPHONE
    // Default to portrait orientation on iPhone.
    BOOL usingFrontCamera = NO;
    // Check the image's EXIF for the camera the image came from as the image could have been
    // delayed as we set alwaysDiscardsLateVideoFrames to NO.
//    AVCaptureDevicePosition cameraPosition = [AVCaptureSession ]
    AVCaptureDevicePosition cameraPosition =
    [AVCaptureSession devicePositionForSampleBuffer:sampleBuffer];
    if (cameraPosition != AVCaptureDevicePositionUnspecified) {
        usingFrontCamera = AVCaptureDevicePositionFront == cameraPosition;
    } else {
        AVCaptureDeviceInput *deviceInput =
        (AVCaptureDeviceInput *)((AVCaptureInputPort *)connection.inputPorts.firstObject).input;
        usingFrontCamera = AVCaptureDevicePositionFront == deviceInput.device.position;
    }
    switch (_orientation) {
        case UIDeviceOrientationPortrait:
            _rotation = AgoraVideoRotation_90;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            _rotation = AgoraVideoRotation_270;
            break;
        case UIDeviceOrientationLandscapeLeft:
            _rotation = usingFrontCamera ? AgoraVideoRotation_180 : AgoraVideoRotation_0;
            break;
        case UIDeviceOrientationLandscapeRight:
            _rotation = usingFrontCamera ? AgoraVideoRotation_0 : AgoraVideoRotation_180;
            break;
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
            // Ignore.
            break;
    }
#else
    // No rotation on Mac.
    _rotation = RTCVideoRotation_0;
#endif
    
//    RTCCVPixelBuffer *rtcPixelBuffer = [[RTCCVPixelBuffer alloc] initWithPixelBuffer:pixelBuffer];
//    int64_t timeStampNs = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)) *
//    kNanosecondsPerSecond;
//    RTCVideoFrame *videoFrame = [[RTCVideoFrame alloc] initWithBuffer:rtcPixelBuffer
//                                                             rotation:_rotation
//                                                          timeStampNs:timeStampNs];
    [self.delegate capturer:self didCaptureVideoFrame:sampleBuffer];
//    [self.delegate capturer:self didCaptureVideoFrame:videoFrame];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
  didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
#if TARGET_OS_IPHONE
    CFStringRef droppedReason =
    CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_DroppedFrameReason, nil);
#else
    // DroppedFrameReason unavailable on macOS.
    CFStringRef droppedReason = nil;
#endif
//    RTCLogError(@"Dropped sample buffer. Reason: %@", (__bridge NSString *)droppedReason);
}

#pragma mark - AVCaptureSession notifications

- (void)handleCaptureSessionInterruption:(NSNotification *)notification {
    NSString *reasonString = nil;
#if TARGET_OS_IPHONE
    NSNumber *reason = notification.userInfo[AVCaptureSessionInterruptionReasonKey];
    if (reason) {
        switch (reason.intValue) {
            case AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableInBackground:
                reasonString = @"VideoDeviceNotAvailableInBackground";
                break;
            case AVCaptureSessionInterruptionReasonAudioDeviceInUseByAnotherClient:
                reasonString = @"AudioDeviceInUseByAnotherClient";
                break;
            case AVCaptureSessionInterruptionReasonVideoDeviceInUseByAnotherClient:
                reasonString = @"VideoDeviceInUseByAnotherClient";
                break;
            case AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableWithMultipleForegroundApps:
                reasonString = @"VideoDeviceNotAvailableWithMultipleForegroundApps";
                break;
        }
    }
#endif
//    RTCLog(@"Capture session interrupted: %@", reasonString);
}

- (void)handleCaptureSessionInterruptionEnded:(NSNotification *)notification {
//    RTCLog(@"Capture session interruption ended.");
}

- (void)handleCaptureSessionRuntimeError:(NSNotification *)notification {
    NSError *error = [notification.userInfo objectForKey:AVCaptureSessionErrorKey];
//    RTCLogError(@"Capture session runtime error: %@", error);
    
    [AgoraDispatcher dispatchAsyncOnType:AgoraDispatcherTypeCaptureSession
                                 block:^{
#if TARGET_OS_IPHONE
                                     if (error.code == AVErrorMediaServicesWereReset) {
                                         [self handleNonFatalError];
                                     } else {
                                         [self handleFatalError];
                                     }
#else
                                     [self handleFatalError];
#endif
                                 }];
}

- (void)handleCaptureSessionDidStartRunning:(NSNotification *)notification {
//    RTCLog(@"Capture session started.");
    
    [AgoraDispatcher dispatchAsyncOnType:AgoraDispatcherTypeCaptureSession
                                 block:^{
                                     // If we successfully restarted after an unknown error,
                                     // allow future retries on fatal errors.
                                     self.hasRetriedOnFatalError = NO;
                                 }];
}

- (void)handleCaptureSessionDidStopRunning:(NSNotification *)notification {
//    RTCLog(@"Capture session stopped.");
}

- (void)handleFatalError {
    [AgoraDispatcher
     dispatchAsyncOnType:AgoraDispatcherTypeCaptureSession
     block:^{
         if (!self.hasRetriedOnFatalError) {
//             RTCLogWarning(@"Attempting to recover from fatal capture error.");
             [self handleNonFatalError];
             self.hasRetriedOnFatalError = YES;
         } else {
//             RTCLogError(@"Previous fatal error recovery failed.");
         }
     }];
}

- (void)handleNonFatalError {
    [AgoraDispatcher dispatchAsyncOnType:AgoraDispatcherTypeCaptureSession
                                 block:^{
//                                     RTCLog(@"Restarting capture session after error.");
                                     if (self.isRunning) {
                                         [self.captureSession startRunning];
                                     }
                                 }];
}

#if TARGET_OS_IPHONE

#pragma mark - UIApplication notifications

- (void)handleApplicationDidBecomeActive:(NSNotification *)notification {
    [AgoraDispatcher dispatchAsyncOnType:AgoraDispatcherTypeCaptureSession
                                 block:^{
                                     if (self.isRunning && !self.captureSession.isRunning) {
//                                         RTCLog(@"Restarting capture session on active.");
                                         [self.captureSession startRunning];
                                     }
                                 }];
}

#endif  // TARGET_OS_IPHONE

#pragma mark - Private

- (dispatch_queue_t)frameQueue {
    if (!_frameQueue) {
        _frameQueue =
        dispatch_queue_create("io.agora.cameravideocapturer.video", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_frameQueue,
                                  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    }
    return _frameQueue;
}

- (BOOL)setupCaptureSession:(AVCaptureSession *)captureSession {
    NSAssert(_captureSession == nil, @"Setup capture session called twice.");
    _captureSession = captureSession;
    _captureSession.sessionPreset = AVCaptureSessionPresetInputPriority;
    _captureSession.usesApplicationAudioSession = NO;
    
    [self setupVideoDataOutput];
    
    // Add the output.
    if (![_captureSession canAddOutput:_videoDataOutput]) {
//        RTCLogError(@"Video data output unsupported.");
        return NO;
    }
    [_captureSession addOutput:_videoDataOutput];
    
    return YES;
}

- (void)setupVideoDataOutput {
    NSAssert(_videoDataOutput == nil, @"Setup video data output called twice.");
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    // `videoDataOutput.availableVideoCVPixelFormatTypes` returns the pixel formats supported by the
    // device with the most efficient output format first. Find the first format that we support.
    NSMutableOrderedSet *availablePixelFormats =
    [NSMutableOrderedSet orderedSetWithArray:videoDataOutput.availableVideoCVPixelFormatTypes];
    [availablePixelFormats intersectSet:[self supportedPixelFormats]];
    NSNumber *pixelFormat = availablePixelFormats.firstObject;
    NSAssert(pixelFormat, @"Output device has no supported formats.");
    
    _preferredOutputPixelFormat = [pixelFormat unsignedIntValue];
    _outputPixelFormat = _preferredOutputPixelFormat;
    videoDataOutput.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey : pixelFormat};
    videoDataOutput.alwaysDiscardsLateVideoFrames = NO;
    [videoDataOutput setSampleBufferDelegate:self queue:self.frameQueue];
    _videoDataOutput = videoDataOutput;
}

- (void) setupVideoConnection {
    if (_videoDataOutput) {
        _videoConnection = [_videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
//         = videoConnection;
    }
}

- (void)updateVideoDataOutputPixelFormat:(AVCaptureDeviceFormat *)format {
    FourCharCode mediaSubType = CMFormatDescriptionGetMediaSubType(format.formatDescription);
    if (![[self supportedPixelFormats] containsObject:@(mediaSubType)]) {
        mediaSubType = _preferredOutputPixelFormat;
    }
    
    if (mediaSubType != _outputPixelFormat) {
        _outputPixelFormat = mediaSubType;
        _videoDataOutput.videoSettings =
        @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(mediaSubType) };
    }
}

- (void)updateCaptureVideoOrientation {
    if (_videoConnection) {
        switch (_orientation) {
            case UIInterfaceOrientationPortrait:
                [_videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                [_videoConnection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
                break;
            case UIInterfaceOrientationLandscapeLeft:
                [_videoConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
                break;
            case UIInterfaceOrientationLandscapeRight:
                [_videoConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
                break;
                
            default:
                break;
        }
    }
}


#pragma mark - Private, called inside capture queue

- (void)updateDeviceCaptureFormat:(AVCaptureDeviceFormat *)format fps:(NSInteger)fps {
    NSAssert([AgoraDispatcher isOnQueueForType:AgoraDispatcherTypeCaptureSession],
             @"updateDeviceCaptureFormat must be called on the capture queue.");
    @try {
        _currentDevice.activeFormat = format;
        _currentDevice.activeVideoMinFrameDuration = CMTimeMake(1, fps);
    } @catch (NSException *exception) {
        AgoraLogError(@"Failed to set active format!\n User info:%@", exception.userInfo);
        return;
    }
}

- (void)reconfigureCaptureSessionInput {
    NSAssert([AgoraDispatcher isOnQueueForType:AgoraDispatcherTypeCaptureSession],
             @"reconfigureCaptureSessionInput must be called on the capture queue.");
    NSError *error = nil;
    AVCaptureDeviceInput *input =
    [AVCaptureDeviceInput deviceInputWithDevice:_currentDevice error:&error];
    if (!input) {
//        RTCLogError(@"Failed to create front camera input: %@", error.localizedDescription);
        return;
    }
    [_captureSession beginConfiguration];
    for (AVCaptureDeviceInput *oldInput in [_captureSession.inputs copy]) {
        [_captureSession removeInput:oldInput];
    }
    if ([_captureSession canAddInput:input]) {
        [_captureSession addInput:input];
    } else {
//        RTCLogError(@"Cannot add camera as an input to the session.");
    }
    [_captureSession commitConfiguration];
}

- (void)updateOrientation {
    NSAssert([AgoraDispatcher isOnQueueForType:AgoraDispatcherTypeCaptureSession],
             @"updateOrientation must be called on the capture queue.");
    _orientation = [UIDevice currentDevice].orientation;
    [self updateCaptureVideoOrientation];
}

- (NSSet<NSNumber *> *)supportedPixelFormats {
    return [NSSet setWithObjects:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange),
            @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange),
            @(kCVPixelFormatType_32BGRA),
            @(kCVPixelFormatType_32ARGB),
            nil];
}

@end
