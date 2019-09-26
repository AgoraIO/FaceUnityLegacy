//
//  ViewController.m
//  TestProject
//
//  Created by Zhang Ji on 2019/9/22.
//  Copyright © 2019 ZhangJi. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>

#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import <CapturerAndRender/CapturerAndRender.h>

@interface ViewController ()<VideoCapturerDelegate, AgoraVideoSourceProtocol, Connector>

@property (weak, nonatomic) IBOutlet GLRenderView *renderView;
@property (weak, nonatomic) IBOutlet UIView *renderView2;
@property (weak, nonatomic) IBOutlet UIView *localView;

@property (nonatomic, strong) CapturerManager *myCapturer;

@property (nonatomic, strong) RenderManager *localRender;


@property (nonatomic, assign) MirrorModel currentMirrorModel;
@property (nonatomic, assign) RenderModel currentRenderModel;

@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;    //Agora Engine

@property (nonatomic, strong) AgoraRtcVideoCanvas *localCanvas;

@property (nonatomic, strong) GLRenderView *viewTest;

@end

@implementation ViewController

@synthesize consumer;

- (RenderManager*)localRender {
    if (!_localRender) {
        _localRender = [[RenderManager alloc] initWithConnector:self];
        _localRender.view = _renderView;
    }
    return _localRender;
}

- (CapturerManager *)myCapturer {
    if (!_myCapturer) {
//        CameraVideoCapturer *camera = [[CameraVideoCapturer alloc] initWithDelegate:self];
//        _renderManager = [Render]
        
        _myCapturer = [[CapturerManager alloc] initWithWidth:480 height:640 fps:15 orientationMode:VideoOutputOrientationModeAdaptative connector:[self localRender]];
//        _myCapturer = [[CapturerManager alloc] initWithCapturer:camera width:480 height:640 fps:15 orientationMode:VideoOutputOrientationModeFixedPortrait];
    }
    return _myCapturer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadAgoraKit];
    [_renderView setRenderModel:RenderModelFit];
    _currentRenderModel = RenderModelFit;
    _currentMirrorModel = MirrorModelDefault;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.myCapturer startCapture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    GLRenderView *view = [[GLRenderView alloc]initWithFrame:self.renderView2.frame];
    
    self.viewTest = view;
    self.viewTest.frame = CGRectMake(0, 0, self.renderView2.frame.size.width, self.renderView2.frame.size.height);
    [_renderView2 addSubview:_viewTest];
}

- (void)viewDidLayoutSubviews {
    self.viewTest.frame = CGRectMake(0, 0, self.renderView2.frame.size.width, self.renderView2.frame.size.height);
}

- (IBAction)doSwitchPressed:(UIButton *)sender {
    [self.myCapturer switchCamera];
}
- (IBAction)doButtonPressed:(UIButton *)sender {
    if (_currentRenderModel == RenderModelHidden) {
        [_renderView setRenderModel:RenderModelFit];
        _currentRenderModel = RenderModelFit;
    } else {
        [_renderView setRenderModel:RenderModelHidden];
        _currentRenderModel = RenderModelHidden;
    }
}

- (IBAction)doButton2Pressed:(UIButton *)sender {
    switch (self.currentMirrorModel) {
        case MirrorModelDefault:
            self.currentMirrorModel = MirrorModelNO;
            break;
        case MirrorModelNO:
            self.currentMirrorModel = MirrorModelYES;
            break;
        case MirrorModelYES:
            self.currentMirrorModel = MirrorModelDefault;
            break;
        default:
            break;
    }
    [_renderView setMirrorModel:_currentMirrorModel];
}

- (void)loadAgoraKit {
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:@"0279f083791444fc835764dfedd614ce" delegate:self];
    [self.agoraKit setChannelProfile:AgoraChannelProfileLiveBroadcasting];
    [self.agoraKit setVideoEncoderConfiguration:[[AgoraVideoEncoderConfiguration alloc]initWithSize:AgoraVideoDimension640x480
                                                                                          frameRate:AgoraVideoFrameRateFps15
                                                                                            bitrate:AgoraVideoBitrateStandard
                                                                                    orientationMode:AgoraVideoOutputOrientationModeAdaptative]];
    
    [self.agoraKit setClientRole:AgoraClientRoleBroadcaster];
    [self.agoraKit enableVideo];
    [self.agoraKit setVideoSource:self];
    
    [self.agoraKit enableWebSdkInteroperability:YES];
    
    [self setupLocalView];
    [self.agoraKit startPreview];
    
//    self.count = 0;
//    self.isMuted = false;
    
    [self.agoraKit joinChannelByToken:nil channelId:@"ttt" info:nil uid:0 joinSuccess:nil];
}

- (void) setupLocalView {
//    UIView *renderView = [[UIView alloc] initWithFrame:self.view.frame];
    //    GLRenderView *renderView = [[GLRenderView alloc] initWithFrame:self.view.frame];
//    [self.view addSubview:renderView];
//    [self.view insertSubview:renderView atIndex:0];
    if (self.localCanvas == nil) {
        self.localCanvas = [[AgoraRtcVideoCanvas alloc] init];
    }
    self.localCanvas.view = self.localView;
    self.localCanvas.renderMode = AgoraVideoRenderModeFit;
    [self.agoraKit setupLocalVideo:self.localCanvas];
    
    
//    self.localRenderView = renderView;
    //    [renderView setMirrorModel:MirrorModelNO];
    //
    //    self.renderView = renderView;
}

- (BOOL)shouldInitialize {
    return YES;
}

- (void)shouldStart {
    [self.myCapturer startCapture];
}

- (void)shouldStop {
    [self.myCapturer stopCapture];
}

- (void)shouldDispose {
    
}

- (AgoraVideoBufferType)bufferType {
    return AgoraVideoBufferTypePixelBuffer;
}

-(void)capturer: (CameraVideoCapturer *)capturer didCaptureFrame: (VideoFrame*)frame {
    [_renderView renderFrame:frame];
//    [_renderView2 renderFrame:frame];
}

-(void)capturerManager:(CapturerManager *)manager didCaptureFrame:(VideoFrame *)frame {
    if (![frame.buffer isKindOfClass:[CustomCVPixelBuffer class]]) {
        return;
    }
    
    CustomCVPixelBuffer* buffer = frame.buffer;
    CVPixelBufferRef pixelBuffer = buffer.pixelBuffer;
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    AgoraVideoRotation agoraRotation = AgoraVideoRotationNone;
    switch (frame.rotation) {
        case VideoRotation90:
            agoraRotation = AgoraVideoRotation90;
            break;
        case VideoRotation180:
            agoraRotation = AgoraVideoRotation180;
            break;
        case VideoRotation270:
            agoraRotation = AgoraVideoRotation270;
            break;
        default:
            break;
    }
    [self.consumer consumePixelBuffer:pixelBuffer withTimestamp:frame.timeStamp rotation:agoraRotation];
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    [_renderView renderFrame:frame];
    [_viewTest renderFrame:frame];
//    GLRenderView *view = (GLRenderView*)_renderView2;
//    [view renderFrame:frame];
}

- (void)didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer withTimeStamp:(CMTime)timeStamp rotation:(VideoRotation)rotation {
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    AgoraVideoRotation agoraRotation = AgoraVideoRotationNone;
    switch (rotation) {
        case VideoRotation90:
            agoraRotation = AgoraVideoRotation90;
            break;
        case VideoRotation180:
            agoraRotation = AgoraVideoRotation180;
            break;
        case VideoRotation270:
            agoraRotation = AgoraVideoRotation270;
            break;
        default:
            break;
    }
    [self.consumer consumePixelBuffer:pixelBuffer withTimestamp:timeStamp rotation:agoraRotation];
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

@end
