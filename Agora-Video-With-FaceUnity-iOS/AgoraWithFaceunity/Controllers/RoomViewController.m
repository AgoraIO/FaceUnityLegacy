//
//  RoomViewController.m
//  AgoraWithFaceunity
//
//  Created by ZhangJi on 11/03/2018.
//  Copyright © 2018 ZhangJi. All rights reserved.
//

#import "RoomViewController.h"
#import "FUCamera.h"
#import "FUManager.h"
#import "FUOpenGLView.h"
#import "KeyCenter.h"
#import <FUAPIDemoBar/FUAPIDemoBar.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>

@interface RoomViewController ()<FUAPIDemoBarDelegate, FUCameraDelegate, AgoraRtcEngineDelegate, AgoraVideoSourceProtocol>

@property (nonatomic, strong) FUCamera *mCamera;   //Faceunity Camera

@property (weak, nonatomic) IBOutlet UIView *containView;

@property (weak, nonatomic) IBOutlet FUAPIDemoBar *demoBar;    //Tool Bar

@property (weak, nonatomic) IBOutlet UILabel *noTrackLabel;

@property (weak, nonatomic) IBOutlet UILabel *calibrateLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegment;

@property (weak, nonatomic) IBOutlet UIButton *barBtn;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIButton *muteBtn;

@property (weak, nonatomic) IBOutlet UIButton *cameraSwitchBtn;

@property (nonatomic, weak) FUOpenGLView *localRenderView;

#pragma Agora
@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;    //Agora Engine

@property (nonatomic, strong) AgoraRtcVideoCanvas *remoteCanvas;

@property (nonatomic, weak)   UIView *remoteRenderView;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) BOOL isMuted;

@end

@implementation RoomViewController

@synthesize consumer;

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObserver];
    
    [[FUManager shareManager] loadItems];

    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *hint = [[FUManager shareManager] hintForItem:[FUManager shareManager].selectedItem];
        self.tipLabel.hidden = hint == nil;
        self.tipLabel.text = hint;

        [RoomViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissTipLabel) object:nil];
        [self performSelector:@selector(dismissTipLabel) withObject:nil afterDelay:5];
    });
    
    [self loadAgoraKit];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.mCamera stopCapture];
    
    [super viewWillDisappear:animated];
}

- (void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - Agora Engine
/**
* load Agora Engine && Join Channel
*/
- (void)loadAgoraKit {
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:[KeyCenter AppId] delegate:self];
    [self.agoraKit setChannelProfile:AgoraChannelProfileLiveBroadcasting];
    [self.agoraKit setVideoProfile:AgoraVideoProfilePortrait360P swapWidthAndHeight:NO];
    
    [self.agoraKit setClientRole:AgoraClientRoleBroadcaster];
    [self.agoraKit enableVideo];
    [self.agoraKit setVideoSource:self];
    
    // workaround for the big head issue
    [self.agoraKit setParameters:@"{\"che.video.keep_prerotation\":false}"];
    [self.agoraKit setParameters:@"{\"che.video.local.camera_index\":1025}"];
    
    self.count = 0;
    self.isMuted = false;
    
    [self.agoraKit joinChannelByToken:nil channelId:self.channelName info:nil uid:0 joinSuccess:nil];

    FUOpenGLView *renderView = [[FUOpenGLView alloc] init];
    renderView.frame = self.view.frame;
    [self.containView addSubview:renderView];
    self.localRenderView = renderView;
}

#pragma mark - Agora Video Source Protocol

- (BOOL)shouldInitialize {
    return YES;
}

- (void)shouldStart {
    [self.mCamera startCapture];
}

- (void)shouldStop {
    [self.mCamera stopCapture];
}

- (void)shouldDispose {

}

- (AgoraVideoBufferType)bufferType {
    return AgoraVideoBufferTypePixelBuffer;
}

#pragma mark - Agora Engine Delegate

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString*)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed {
    NSLog(@"Join Channel Success");
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    if (self.count == 0) {
        self.count ++;
        UIView *renderView = [[UIView alloc] initWithFrame:self.view.frame];
        [self.containView insertSubview:renderView atIndex:0];
        if (self.remoteCanvas == nil) {
            self.remoteCanvas = [[AgoraRtcVideoCanvas alloc] init];
        }
        self.remoteCanvas.uid = uid;
        self.remoteCanvas.view = renderView;
        self.remoteCanvas.renderMode = AgoraVideoRenderModeHidden;
        [self.agoraKit setupRemoteVideo:self.remoteCanvas];
        
        self.remoteRenderView = renderView;
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect newFrame = CGRectMake(self.view.frame.size.width * 0.7 - 10, 20, self.view.frame.size.width * 0.3, self.view.frame.size.width * 0.3 * 16.0 / 9.0);
            self.localRenderView.frame = newFrame;
        }];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    if (self.count > 0) {
        self.count --;
        self.remoteCanvas.view = nil;
        [self.remoteRenderView removeFromSuperview];
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect newFrame = self.view.frame;
            self.localRenderView.frame = newFrame;
        }];
    }
}


- (void)willResignActive
{
    [self.mCamera stopCapture];
}

- (void)willEnterForeground
{
    [self.mCamera startCapture];
}

- (void)didBecomeActive
{
    [self.mCamera startCapture];
}

- (void)dismissTipLabel
{
    self.tipLabel.hidden = YES;
}

/**
 *  The default camera is front camera, and the default capture format is BGRA.
 *
 *  @return FUCamera
 */
- (FUCamera *)mCamera
{
    if (!_mCamera) {
        _mCamera = [[FUCamera alloc] init];
        _mCamera.delegate = self;
    }
    return _mCamera;
}

/**
 *  Faceunity Tool Bar
 *  Init FUAPIDemoBar，Set beauty parameters
 */
- (void)setDemoBar:(FUAPIDemoBar *)demoBar
{
    _demoBar = demoBar;
    _demoBar.delegate = self;
    
    _demoBar.itemsDataSource =  [FUManager shareManager].itemsDataSource;
    _demoBar.filtersDataSource = [FUManager shareManager].filtersDataSource;
    _demoBar.filtersCHName = [FUManager shareManager].filtersCHName;
    _demoBar.beautyFiltersDataSource = [FUManager shareManager].beautyFiltersDataSource;
    
    _demoBar.selectedItem = [FUManager shareManager].selectedItem;      // selected item
    _demoBar.selectedFilter = [FUManager shareManager].selectedFilter;  // selected filter
    _demoBar.whiteLevel = [FUManager shareManager].beautyLevel;         // beauty level (0~1)
    _demoBar.redLevel = [FUManager shareManager].redLevel;              // red level (0~1)
    _demoBar.selectedBlur = [FUManager shareManager].selectedBlur;      // blur (0、1、2、3、4、5、6)
    _demoBar.skinDetectEnable = [FUManager shareManager].skinDetectEnable;// skin detect enabled (YES/NO)
    _demoBar.faceShape = [FUManager shareManager].faceShape;            // face shape (0、1、2、3)
    _demoBar.faceShapeLevel = [FUManager shareManager].faceShapeLevel;  // face shape level (0~1)
    _demoBar.enlargingLevel = [FUManager shareManager].enlargingLevel;  // eye large level (0~1)*/
    _demoBar.thinningLevel = [FUManager shareManager].thinningLevel;    // face thining level (0~1)
}

/**
* Show the tool bar
*/
- (IBAction)filterBtnClick:(UIButton *)sender {
    self.barBtn.hidden = YES;
    self.cameraSwitchBtn.hidden = YES;
    self.muteBtn.hidden = YES;
    
    self.demoBar.alpha = 0.0 ;
    [UIView animateWithDuration:0.5 animations:^{
        self.demoBar.transform = CGAffineTransformMakeTranslation(0, -self.demoBar.frame.size.height);
        self.demoBar.alpha = 1.0 ;
    }];
}

/**
 * Hide the tool bar
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches allObjects].firstObject;
    if (touch.view == self.demoBar || !self.barBtn.hidden) {
        return;
    }
    self.demoBar.alpha = 1.0 ;
    [UIView animateWithDuration:0.5 animations:^{
        self.demoBar.transform = CGAffineTransformIdentity;
        self.demoBar.alpha = 0.0 ;
    } completion:^(BOOL finished) {
        self.barBtn.hidden = NO;
        self.cameraSwitchBtn.hidden = NO;
        self.muteBtn.hidden = NO;
    }];
}

- (IBAction)leaveBtnClick:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.mCamera stopCapture];
    [[FUManager shareManager] destoryItems];
    [self.agoraKit setVideoSource:nil];
    [self.agoraKit leaveChannel:nil];
    [self.localRenderView removeFromSuperview];
    if (self.count > 0) {
        [self.remoteRenderView removeFromSuperview];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeCaptureFormat:(UISegmentedControl *)sender {
    _mCamera.captureFormat = _mCamera.captureFormat == kCVPixelFormatType_32BGRA ? kCVPixelFormatType_420YpCbCr8BiPlanarFullRange : kCVPixelFormatType_32BGRA;
}

- (IBAction)switchCameraBtnClick:(UIButton *)sender {
    [_mCamera changeCameraInputDeviceisFront:!_mCamera.isFrontCamera];
    
    //Change camera need to call below function
    [[FUManager shareManager] onCameraChange];
}

- (IBAction)muteBtnClick:(UIButton *)sender {
    self.isMuted = !self.isMuted;
    [self.agoraKit muteLocalAudioStream:self.isMuted];
    [self.muteBtn setImage:[UIImage imageNamed: self.isMuted ? @"microphone-mute" : @"microphone"] forState:UIControlStateNormal];
}

#pragma mark - FUAPIDemoBar Delegate
- (void)demoBarDidSelectedItem:(NSString *)item
{
    //Load selection item
    [[FUManager shareManager] loadItem:item];
    
    //display hint
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *hint = [[FUManager shareManager] hintForItem:item];
        self.tipLabel.hidden = hint == nil;
        self.tipLabel.text = hint;
        
        [RoomViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissTipLabel) object:nil];
        [self performSelector:@selector(dismissTipLabel) withObject:nil afterDelay:5 ];
    });
}

/**
 * Reset beauty parameters when the parameters changed
 */
- (void)demoBarBeautyParamChanged
{
    [self syncBeautyParams];
}

- (void)syncBeautyParams
{
    [FUManager shareManager].selectedFilter = _demoBar.selectedFilter;
    [FUManager shareManager].selectedFilterLevel = _demoBar.selectedFilterLevel;
    [FUManager shareManager].selectedBlur = _demoBar.selectedBlur;
    [FUManager shareManager].skinDetectEnable = _demoBar.skinDetectEnable;
    [FUManager shareManager].beautyLevel = _demoBar.whiteLevel;
    [FUManager shareManager].redLevel = _demoBar.redLevel;
    [FUManager shareManager].faceShape = _demoBar.faceShape;
    [FUManager shareManager].faceShapeLevel = _demoBar.faceShapeLevel;
    [FUManager shareManager].thinningLevel = _demoBar.thinningLevel;
    [FUManager shareManager].enlargingLevel = _demoBar.enlargingLevel;
}

#pragma mark - FUCameraDelegate

- (void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer { 
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    //render the items to pixelbuffer
    [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
    
    //render the pixelbuffer to screen
    [self.localRenderView displayPixelBuffer:pixelBuffer];
    
    CGSize frameSize;
    if (CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA) {
        frameSize = CGSizeMake(CVPixelBufferGetBytesPerRow(pixelBuffer) / 4, CVPixelBufferGetHeight(pixelBuffer));
    }else{
        frameSize = CGSizeMake(CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer));
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //determine if faces are detected
        self.noTrackLabel.hidden = [[FUManager shareManager] isTracking];
        
        //display the error info
        self.errorLabel.text = [[FUManager shareManager] getError];
        
        //adjust the camera exposure parameters and focus parameters in real time according to the center of the face
        CGPoint center = [[FUManager shareManager] getFaceCenterInFrameSize:frameSize];;
        self.mCamera.exposurePoint = CGPointMake(center.y,self.mCamera.isFrontCamera ? center.x:1-center.x);
        
        //expression calibration tips
        BOOL isCalibrating = [[FUManager shareManager] isCalibrating];
        if (isCalibrating) {
            
            if (self.calibrateLabel.hidden) {
                pointCount = -1;
                self.calibrateLabel.alpha = 0.5;
                [UIView animateWithDuration:0.5 animations:^{
                    self.calibrateLabel.hidden = NO;
                    self.calibrateLabel.alpha = 1.0;
                }];
                [self calibratingLabelAnimation];
            }
        }else{
            pointCount = -1;
            self.calibrateLabel.hidden = YES;
        }
    });
    
    // push video frame to agora
    [self.consumer consumePixelBuffer:pixelBuffer withTimestamp:CMSampleBufferGetPresentationTimeStamp(sampleBuffer) rotation:AgoraVideoRotationNone];
}

static int pointCount = 0;
- (void)calibratingLabelAnimation{
    if (self.calibrateLabel.hidden == NO) {
        pointCount += 1;
        pointCount = pointCount % 6;
        
        NSString *text = @"Calibrating";
        for (int i = 0; i<= pointCount; i++) {
            text = [text stringByAppendingString:@"."];
        }
        self.calibrateLabel.text = text;
        
        [self performSelector:@selector(calibratingLabelAnimation) withObject:nil afterDelay:0.5];
    }else{
        pointCount = 0;
    }
}

@end
