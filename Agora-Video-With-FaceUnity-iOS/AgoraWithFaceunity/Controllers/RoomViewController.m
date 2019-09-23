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
#import "FULiveCell.h"
#import "FULiveModel.h"
#import "FUItemsView.h"
#import "FUMusicPlayer.h"
#import "KeyCenter.h"
#import <FUAPIDemoBar/FUAPIDemoBar.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>

#import <CapturerAndRender/CapturerAndRender.h>

@interface RoomViewController ()<FUAPIDemoBarDelegate, FUCameraDelegate, FUItemsViewDelegate, AgoraRtcEngineDelegate, AgoraVideoSourceProtocol, VideoCapturerDelegate, UITableViewDataSource, UITableViewDelegate> {
    BOOL faceBeautyMode;
}

@property (nonatomic, strong) FUCamera *mCamera;   //Faceunity Camera

@property (nonatomic, strong) CaptureManager *myCapturer;

@property (weak, nonatomic) IBOutlet UIView *containView;

@property (weak, nonatomic) IBOutlet FUAPIDemoBar *demoBar;    //Tool Bar
@property (strong, nonatomic) IBOutlet FUItemsView *itemsView;

@property (weak, nonatomic) IBOutlet UILabel *noTrackLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet UILabel *buglyLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegment;

@property (weak, nonatomic) IBOutlet UIButton *performanceBtn;
@property (weak, nonatomic) IBOutlet UIButton *barBtn;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UIButton *cameraSwitchBtn;

@property (weak, nonatomic) IBOutlet UITableView *modelTableView;

@property (nonatomic, strong) FULiveModel *model;

@property (nonatomic, weak) FUOpenGLView *openView;

@property (nonatomic, weak) GLRenderView *renderView;

#pragma Agora
@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;    //Agora Engine

@property (nonatomic, strong) AgoraRtcVideoCanvas *remoteCanvas;

@property (nonatomic, weak)   UIView *remoteRenderView;

@property (nonatomic, strong) AgoraRtcVideoCanvas *localCanvas;

@property (nonatomic, weak)   UIView *localRenderView;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) BOOL isMuted;

@property (nonatomic, assign) BOOL useFUCamera;

@end

@implementation RoomViewController

@synthesize consumer;

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObserver];
    
    _useFUCamera = false;
    
    CGRect frame = self.itemsView.frame ;
    frame.origin = CGPointMake(0, self.view.frame.size.height) ;
    frame.size = CGSizeMake(self.view.frame.size.width, frame.size.height) ;
    self.itemsView.frame = frame;
    self.itemsView.delegate = self ;
    [self.view addSubview:self.itemsView];
    
    [self loadAgoraKit];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            [self.mCamera setCaptureVideoOrientation:AVCaptureVideoOrientationPortrait];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [self.mCamera setCaptureVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [self.mCamera setCaptureVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [self.mCamera setCaptureVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
            break;

        default:
            break;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (faceBeautyMode) {
        CGRect tipFrame = self.tipLabel.frame ;
        tipFrame.origin = CGPointMake(tipFrame.origin.x, [UIScreen mainScreen].bounds.size.height - 164 - tipFrame.size.height - 10) ;
        self.tipLabel.frame = tipFrame ;
        self.tipLabel.textColor = [UIColor whiteColor];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.model.type == FULiveModelTypeAnimoji) {
        [[FUManager shareManager] setCalibrating];
        [[FUManager shareManager] loadAnimojiFaxxBundle];
    }
    
    if (self.model.type == FULiveModelTypeMusicFilter && ![[FUManager shareManager].selectedItem isEqualToString:@"noitem"]) {
        [[FUMusicPlayer sharePlayer] playMusic:@"douyin.mp3"];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.model.type == FULiveModelTypeMusicFilter) {
        [[FUMusicPlayer sharePlayer] stop];
    }else if (self.model.type == FULiveModelTypeAnimoji) {
        
        [[FUManager shareManager] destoryAnimojiFaxxBundle];
    }
}

- (void)updateToolBarWith:(FULiveModel *)model {
    faceBeautyMode = self.model.type == FULiveModelTypeBeautifyFace ;

    if (faceBeautyMode) {
        [self hiddenModelTableView:YES];
        [self hiddenButtonsWith:YES];
        [self hiddenItemsView:YES];
        
        [[FUManager shareManager] loadFilter];
        
        [self hiddenToolBarWith:NO];
        
    } else {
        [self hiddenModelTableView:YES];
        [self hiddenButtonsWith:YES];
        [self hiddenToolBarWith:YES];
        
        self.itemsView.itemsArray = self.model.items;
        
        NSString *selectItem = self.model.items.count > 0 ? self.model.items[0] : @"noitem" ;
        
        self.itemsView.selectedItem = selectItem ;
        
        [[FUManager shareManager] loadItem: selectItem];
        [[FUManager shareManager] loadFilter];
        
        if (self.model.type == FULiveModelTypePortraitDrive) {
            
            [[FUManager shareManager] set3DFlipH];
        }else if (self.model.type == FULiveModelTypeGestureRecognition) {
            
            [[FUManager shareManager] setLoc_xy_flip];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *alertString = [[FUManager shareManager] alertForItem:selectItem];
            self.alertLabel.hidden = alertString == nil ;
            self.alertLabel.text = NSLocalizedString(alertString, nil);
            
            [RoomViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissAlertLabel) object:nil];
            [self performSelector:@selector(dismissAlertLabel) withObject:nil afterDelay:3];
            
            NSString *hint = [[FUManager shareManager] hintForItem:selectItem];
            self.tipLabel.hidden = hint == nil;
            self.tipLabel.text = NSLocalizedString(hint, nil);
            
            [RoomViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissTipLabel) object:nil];
            [self performSelector:@selector(dismissTipLabel) withObject:nil afterDelay:5 ];
        });
        
        [self hiddenItemsView:NO];
    }
}

- (void)setModel:(FULiveModel *)model {
    _model = model;
    [self updateToolBarWith:model];
}

- (void)dealloc {
    NSLog(@"dealloc");
}

#pragma mark - Agora Engine
/**
* load Agora Engine && Join Channel
*/
- (void)loadAgoraKit {
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:[KeyCenter AppId] delegate:self];
    [self.agoraKit setChannelProfile:AgoraChannelProfileLiveBroadcasting];
    [self.agoraKit setVideoEncoderConfiguration:[[AgoraVideoEncoderConfiguration alloc]initWithSize:AgoraVideoDimension1280x720
                                                                                          frameRate:AgoraVideoFrameRateFps15
                                                                                            bitrate:AgoraVideoBitrateStandard
                                                                                    orientationMode:AgoraVideoOutputOrientationModeAdaptative]];

    [self.agoraKit setClientRole:AgoraClientRoleBroadcaster];
    [self.agoraKit enableVideo];
    [self.agoraKit setVideoSource:self];
    
    [self.agoraKit enableWebSdkInteroperability:YES];

    [self setupLocalView];
    [self.agoraKit startPreview];
    
    self.count = 0;
    self.isMuted = false;
    
    [self.agoraKit joinChannelByToken:nil channelId:self.channelName info:nil uid:0 joinSuccess:nil];
}

- (void) setupLocalView {
//    UIView *renderView = [[UIView alloc] initWithFrame:self.view.frame];
    GLRenderView *renderView = [[GLRenderView alloc] initWithFrame:self.view.frame];
    [self.containView insertSubview:renderView atIndex:0];
//    if (self.localCanvas == nil) {
//        self.localCanvas = [[AgoraRtcVideoCanvas alloc] init];
//    }
//    self.localCanvas.view = renderView;
//    self.localCanvas.renderMode = AgoraVideoRenderModeHidden;
//    [self.agoraKit setupLocalVideo:self.localCanvas];
//    self.localRenderView = renderView;
    
    self.renderView = renderView;
}

#pragma mark - Agora Video Source Protocol

- (BOOL)shouldInitialize {
    return YES;
}

- (void)shouldStart {
    if (_useFUCamera) {
        [self.mCamera startCapture];
    } else {
        [self.myCapturer startCapture];
    }
}

- (void)shouldStop {
    if (_useFUCamera) {
        [self.mCamera stopCapture];
    } else {
        [self.myCapturer stopCapture];
    }
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

- (void)dismissTipLabel {
    self.tipLabel.hidden = YES;
}

- (void)dismissAlertLabel {
    self.alertLabel.hidden = YES ;
}

/**
 *  The default camera is front camera, and the default capture format is BGRA.
 *
 *  @return FUCamera
 */
- (FUCamera *)mCamera {
    if (!_mCamera) {
        _mCamera = [[FUCamera alloc] init];
        _mCamera.delegate = self;
    }
    return _mCamera;
}

- (CaptureManager *)myCapturer {
    if (!_myCapturer) {
        CameraVideoCapturer *camera = [[CameraVideoCapturer alloc] initWithDelegate:self];
        _myCapturer = [[CaptureManager alloc] initWithCapturer:camera width:720 height:1080 fps:15];
    }
    return _myCapturer;
}

/**
 *  Faceunity Tool Bar
 *  Init FUAPIDemoBar，Set beauty parameters
 */
-(void)setDemoBar:(FUAPIDemoBar *)demoBar {
    
    _demoBar = demoBar;
    
    _demoBar.performance = [FUManager shareManager].performance;
    
    [self demoBarSetBeautyDefultParams];
}

- (void)demoBarSetBeautyDefultParams {
    _demoBar.delegate = nil ;
    _demoBar.skinDetect = [FUManager shareManager].skinDetectEnable;
    _demoBar.heavyBlur = [FUManager shareManager].blurShape ;
    _demoBar.blurLevel = [FUManager shareManager].blurLevel ;
    _demoBar.colorLevel = [FUManager shareManager].whiteLevel ;
    _demoBar.redLevel = [FUManager shareManager].redLevel;
    _demoBar.eyeBrightLevel = [FUManager shareManager].eyelightingLevel ;
    _demoBar.toothWhitenLevel = [FUManager shareManager].beautyToothLevel ;
    _demoBar.faceShape = [FUManager shareManager].faceShape ;
    _demoBar.enlargingLevel = [FUManager shareManager].enlargingLevel ;
    _demoBar.thinningLevel = [FUManager shareManager].thinningLevel ;
    _demoBar.enlargingLevel_new = [FUManager shareManager].enlargingLevel_new ;
    _demoBar.thinningLevel_new = [FUManager shareManager].thinningLevel_new ;
    _demoBar.chinLevel = [FUManager shareManager].jewLevel ;
    _demoBar.foreheadLevel = [FUManager shareManager].foreheadLevel ;
    _demoBar.noseLevel = [FUManager shareManager].noseLevel ;
    _demoBar.mouthLevel = [FUManager shareManager].mouthLevel ;
    
    _demoBar.filtersDataSource = [FUManager shareManager].filtersDataSource ;
    _demoBar.beautyFiltersDataSource = [FUManager shareManager].beautyFiltersDataSource ;
    _demoBar.filtersCHName = [FUManager shareManager].filtersCHName ;
    _demoBar.selectedFilter = [FUManager shareManager].selectedFilter ;
    _demoBar.selectedFilterLevel = [FUManager shareManager].selectedFilterLevel;
    
    _demoBar.delegate = self;
}

/**
* UI amiate
*/
- (void)hiddenButtonsWith:(BOOL)hidden {
    self.barBtn.hidden = hidden;
    self.cameraSwitchBtn.hidden = hidden;
    self.muteBtn.hidden = hidden;
}

- (void)hiddenToolBarWith:(BOOL)hidden {
    self.demoBar.alpha = hidden ? 1.0 : 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        self.performanceBtn.hidden = hidden;
        self.demoBar.transform = hidden ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, -self.demoBar.frame.size.height);
        self.demoBar.alpha = hidden ? 0.0 : 1.0;
    }];
}

- (void)hiddenModelTableView:(BOOL)hidden {
    self.modelTableView.alpha = hidden ? 1.0 : 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        self.modelTableView.transform = hidden ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(-90, 0);
        self.modelTableView.alpha = hidden ? 0.0 : 1.0;
    }];
}

- (void)hiddenItemsView:(BOOL)hidden {
    self.itemsView.alpha = hidden ? 1.0 : 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.itemsView.frame ;
        frame.origin = hidden ? CGPointMake(0, self.view.frame.size.height) : CGPointMake(0, self.view.frame.size.height - ([[[FUManager shareManager] getPlatformtype] isEqualToString:@"iPhone X"] ? 108 : 74));
        
        self.itemsView.frame = frame;
        self.itemsView.alpha = hidden ? 0.0 : 1.0;
    }];
}

/**
* Show the tool bar
*/
- (IBAction)filterBtnClick:(UIButton *)sender {
    [self hiddenButtonsWith:YES];
    [self hiddenToolBarWith:YES];
    [self hiddenItemsView:YES];
    [self hiddenModelTableView:NO];
}

/**
 * Hide the tool bar
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches allObjects].firstObject;
    if (touch.view == self.demoBar || touch.view == self.modelTableView || touch.view == self.itemsView || !self.barBtn.hidden) {
        return;
    }
    [self hiddenButtonsWith:NO];
    [self hiddenToolBarWith:YES];
    [self hiddenModelTableView:YES];
    [self hiddenItemsView:YES];
}

- (IBAction)leaveBtnClick:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [self.mCamera stopCapture];
    [self.myCapturer stopCapture];
    dispatch_async(self.mCamera.videoCaptureQueue, ^{
        [[FUManager shareManager] destoryItems];
    });
    [self.agoraKit leaveChannel:nil];
    [self.agoraKit stopPreview];
    [self.agoraKit setVideoSource:nil];
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
    if (_useFUCamera) {
        [_mCamera changeCameraInputDeviceisFront:!_mCamera.isFrontCamera];
    } else {
        [self.myCapturer switchCamera];
    }

    //Change camera need to call below function
    [self.agoraKit switchCamera];
    [[FUManager shareManager] onCameraChange];
}

- (IBAction)muteBtnClick:(UIButton *)sender {
    self.isMuted = !self.isMuted;
    [self.agoraKit muteLocalAudioStream:self.isMuted];
    [self.muteBtn setImage:[UIImage imageNamed: self.isMuted ? @"microphone-mute" : @"microphone"] forState:UIControlStateNormal];
}

- (IBAction)buglyBtnClick:(UIButton *)sender {
    self.buglyLabel.hidden = !self.buglyLabel.hidden;
}

#pragma mark --- FUItemsViewDelegate
- (void)itemsViewDidSelectedItem:(NSString *)item {
    [[FUManager shareManager] loadItem:item];
    
    [self.itemsView stopAnimation];
    
    
    if (self.model.type == FULiveModelTypeAnimoji) {
        if ([item isEqualToString:@"noitem"]) {
            
            [[FUManager shareManager] removeCalibrating];
        }else {
            
            [[FUManager shareManager] setCalibrating];
        }
    }
    
    if (self.model.type == FULiveModelTypeMusicFilter) {
        [[FUMusicPlayer sharePlayer] stop];
        if (![item isEqualToString:@"noitem"]) {
            [[FUMusicPlayer sharePlayer] playMusic:@"douyin.mp3"];
        }
    }
    
    
    if (self.model.type == FULiveModelTypeGestureRecognition) {
        
        [[FUManager shareManager] setLoc_xy_flip];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *alertString = [[FUManager shareManager] alertForItem:item];
        self.alertLabel.hidden = alertString == nil ;
        self.alertLabel.text = NSLocalizedString(alertString, nil) ;
        
        [RoomViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissAlertLabel) object:nil];
        [self performSelector:@selector(dismissAlertLabel) withObject:nil afterDelay:3];
        
        NSString *hint = [[FUManager shareManager] hintForItem:item];
        self.tipLabel.hidden = hint == nil;
        self.tipLabel.text = NSLocalizedString(hint, nil);
        
        [RoomViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissTipLabel) object:nil];
        [self performSelector:@selector(dismissTipLabel) withObject:nil afterDelay:5 ];
        
    });
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
- (void)demoBarBeautyParamChanged {
    [self syncBeautyParams];
}

- (void)syncBeautyParams {
    [FUManager shareManager].skinDetectEnable = _demoBar.skinDetect;
    [FUManager shareManager].blurShape = _demoBar.heavyBlur;
    [FUManager shareManager].blurLevel = _demoBar.blurLevel ;
    [FUManager shareManager].whiteLevel = _demoBar.colorLevel;
    [FUManager shareManager].redLevel = _demoBar.redLevel;
    [FUManager shareManager].eyelightingLevel = _demoBar.eyeBrightLevel;
    [FUManager shareManager].beautyToothLevel = _demoBar.toothWhitenLevel;
    [FUManager shareManager].faceShape = _demoBar.faceShape;
    [FUManager shareManager].enlargingLevel = _demoBar.enlargingLevel;
    [FUManager shareManager].thinningLevel = _demoBar.thinningLevel;
    [FUManager shareManager].enlargingLevel_new = _demoBar.enlargingLevel_new;
    [FUManager shareManager].thinningLevel_new = _demoBar.thinningLevel_new;
    [FUManager shareManager].jewLevel = _demoBar.chinLevel;
    [FUManager shareManager].foreheadLevel = _demoBar.foreheadLevel;
    [FUManager shareManager].noseLevel = _demoBar.noseLevel;
    [FUManager shareManager].mouthLevel = _demoBar.mouthLevel;
    
    [FUManager shareManager].selectedFilter = _demoBar.selectedFilter ;
    [FUManager shareManager].selectedFilterLevel = _demoBar.selectedFilterLevel;
}

- (IBAction)performanceBtnClicked:(UIButton *)sender {
    sender.selected = !sender.selected ;
    
    self.demoBar.performance = sender.selected ;
    
    [FUManager shareManager].performance = sender.selected;
    
    [[FUManager shareManager] setBeautyDefaultParameters];
    
    [FUManager shareManager].blurShape = sender.selected ? 1 : 0 ;
    [FUManager shareManager].faceShape = sender.selected ? 3 : 4;;
    
    [self demoBarSetBeautyDefultParams];
}

#pragma mark - FUCameraDelegate
- (void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer) ;
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    CFAbsoluteTime startRenderTime = CFAbsoluteTimeGetCurrent();
    
    //render the items to pixelbuffer
    [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
    
    CFAbsoluteTime renderTime = (CFAbsoluteTimeGetCurrent() - startRenderTime);
    
    if (self.model.type == FULiveModelTypeMusicFilter) {
        [[FUManager shareManager] musicFilterSetMusicTime];
    }
    
    CFAbsoluteTime frameTime = (CFAbsoluteTimeGetCurrent() - startTime);
    
    int frameWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    
    CGSize frameSize;
    if (CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA) {
        frameSize = CGSizeMake(CVPixelBufferGetBytesPerRow(pixelBuffer) / 4, CVPixelBufferGetHeight(pixelBuffer));
    }else{
        frameSize = CGSizeMake(CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer));
    }
    
    NSString *ratioStr = [NSString stringWithFormat:@"%dX%d", frameWidth, frameHeight];
    dispatch_async(dispatch_get_main_queue(), ^{
        /**判断是否检测到人脸*/
        self.noTrackLabel.hidden = [[FUManager shareManager] isTracking];
        
        CGFloat fps = 1.0 / frameTime ;
        if (fps > 30) {
            fps = 30 ;
        }
        self.buglyLabel.text = [NSString stringWithFormat:@"resolution:\n %@\nfps: %.0f \nrender time:\n %.0fms", ratioStr, fps, renderTime * 1000.0];
        
        // 根据人脸中心点实时调节摄像头曝光参数及聚焦参数
        CGPoint center = [[FUManager shareManager] getFaceCenterInFrameSize:frameSize];;
        self.mCamera.exposurePoint = CGPointMake(center.y,self.mCamera.isFrontCamera ? center.x:1-center.x);
    });
    
    // push video frame to agora
    [self.consumer consumePixelBuffer:pixelBuffer withTimestamp:CMSampleBufferGetPresentationTimeStamp(sampleBuffer) rotation:AgoraVideoRotationNone];
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

- (void)capturer:(VideoCapturer *)capturer didCaptureFrame:(VideoFrame *)frame {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

    CVPixelBufferRef pixelBuffer = frame.buffer.pixelBuffer;//buffer.pixelBuffer;
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    CFAbsoluteTime startRenderTime = CFAbsoluteTimeGetCurrent();
    
    //render the items to pixelbuffer
    [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
    
    CFAbsoluteTime renderTime = (CFAbsoluteTimeGetCurrent() - startRenderTime);
    
    if (self.model.type == FULiveModelTypeMusicFilter) {
        [[FUManager shareManager] musicFilterSetMusicTime];
    }
    
    CFAbsoluteTime frameTime = (CFAbsoluteTimeGetCurrent() - startTime);
    
    int frameWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    
    CGSize frameSize;
    if (CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA) {
        frameSize = CGSizeMake(CVPixelBufferGetBytesPerRow(pixelBuffer) / 4, CVPixelBufferGetHeight(pixelBuffer));
    }else{
        frameSize = CGSizeMake(CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer));
    }
    
    NSString *ratioStr = [NSString stringWithFormat:@"%dX%d", frameWidth, frameHeight];
    dispatch_async(dispatch_get_main_queue(), ^{
        /**判断是否检测到人脸*/
        self.noTrackLabel.hidden = [[FUManager shareManager] isTracking];
        
        CGFloat fps = 1.0 / frameTime ;
        if (fps > 30) {
            fps = 30 ;
        }
        self.buglyLabel.text = [NSString stringWithFormat:@"resolution:\n %@\nfps: %.0f \nrender time:\n %.0fms", ratioStr, fps, renderTime * 1000.0];
        
        // 根据人脸中心点实时调节摄像头曝光参数及聚焦参数
        CGPoint center = [[FUManager shareManager] getFaceCenterInFrameSize:frameSize];;
        self.mCamera.exposurePoint = CGPointMake(center.y,self.mCamera.isFrontCamera ? center.x:1-center.x);
    });
    
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
//    [self.consumer consumePixelBuffer:pixelBuffer withTimestamp:frame.timeStamp rotation:agoraRotation];
    [self.renderView renderFrame:frame];
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FULiveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FULiveCell" forIndexPath:indexPath];
    cell.model = (FULiveModel *)[[FUManager shareManager].dataSource objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [FUManager shareManager].dataSource.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FULiveModel *model = (FULiveModel *)[[FUManager shareManager].dataSource objectAtIndex:indexPath.row];
    if (model.enble) {
        self.model = model;
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark --- Observer

- (void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)willResignActive {
    if (self.model.type == FULiveModelTypeMusicFilter) {
        [[FUMusicPlayer sharePlayer] pause] ;
    }
}

- (void)willEnterForeground {
    if (self.model.type == FULiveModelTypeMusicFilter && ![[FUManager shareManager].selectedItem isEqualToString:@"noitem"]) {
        [[FUMusicPlayer sharePlayer] playMusic:@"douyin.mp3"] ;
    }
}

- (void)didBecomeActive {
    if (self.model.type == FULiveModelTypeMusicFilter && ![[FUManager shareManager].selectedItem isEqualToString:@"noitem"]) {
        [[FUMusicPlayer sharePlayer] playMusic:@"douyin.mp3"] ;
    }
}

@end
