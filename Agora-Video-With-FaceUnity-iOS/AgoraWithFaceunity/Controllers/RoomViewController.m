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
#import "FUMakeUpView.h"
#import "FUMakeupSupModel.h"
#import <MJExtension/MJExtension.h>
#import "FUHairView.h"

@interface RoomViewController ()<FUAPIDemoBarDelegate, FUCameraDelegate, FUItemsViewDelegate, AgoraRtcEngineDelegate, AgoraVideoSourceProtocol, UITableViewDataSource, UITableViewDelegate, FUMakeUpViewDelegate, FUHairViewDelegate> {
    BOOL faceBeautyMode;
}

@property (nonatomic, strong) FUCamera *mCamera;   //Faceunity Camera

@property (weak, nonatomic) IBOutlet UIView *containView;

@property (weak, nonatomic) IBOutlet FUAPIDemoBar *demoBar;    //Tool Bar
@property (strong, nonatomic) IBOutlet FUItemsView *itemsView;

@property (weak, nonatomic) IBOutlet UILabel *noTrackLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet UILabel *buglyLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegment;

@property (weak, nonatomic) IBOutlet UIButton *barBtn;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UIButton *cameraSwitchBtn;

@property (weak, nonatomic) IBOutlet UITableView *modelTableView;
@property (strong, nonatomic) FUMakeUpView *makeUpView;
@property (strong, nonatomic) FUHairView *hairView;

@property (nonatomic, strong) FULiveModel *model;

#pragma Agora
@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;    //Agora Engine

@property (nonatomic, strong) AgoraRtcVideoCanvas *remoteCanvas;

@property (nonatomic, weak)   UIView *remoteRenderView;

@property (nonatomic, strong) AgoraRtcVideoCanvas *localCanvas;

@property (nonatomic, weak)   UIView *localRenderView;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) BOOL isMuted;

@end

@implementation RoomViewController

@synthesize consumer;

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addObserver];

    CGRect frame = self.itemsView.frame ;
    frame.origin = CGPointMake(0, self.view.frame.size.height) ;
    frame.size = CGSizeMake(self.view.frame.size.width, frame.size.height) ;
    self.itemsView.frame = frame;
    self.itemsView.delegate = self ;
    [self.view addSubview:self.itemsView];

    [self setMakeUpView];
    [self setHairView];

    [self loadAgoraKit];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

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
    if (self.model.type == FULiveModelTypeMusicFilter && ![[FUManager shareManager].selectedItem isEqualToString:@"noitem"]) {
        [[FUMusicPlayer sharePlayer] playMusic:@"douyin.mp3"];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.model.type == FULiveModelTypeMusicFilter) {
        [[FUMusicPlayer sharePlayer] stop];
    }else if (self.model.type == FULiveModelTypeAnimoji) {

        //        [[FUManager shareManager] destoryAnimojiFaxxBundle];
    }
}

- (void)setMakeUpView {
    NSString *wholePath=[[NSBundle mainBundle] pathForResource:@"makeup_whole" ofType:@"json"];
    NSData *wholeData=[[NSData alloc] initWithContentsOfFile:wholePath];
    NSDictionary *wholeDic=[NSJSONSerialization JSONObjectWithData:wholeData options:NSJSONReadingMutableContainers error:nil];
    NSArray *supArray = [FUMakeupSupModel mj_objectArrayWithKeyValuesArray:wholeDic[@"data"]];

    self.makeUpView = [[FUMakeUpView alloc] init];
    self.makeUpView.delegate = self;
    [self.makeUpView setWholeArray:supArray];
    self.makeUpView.backgroundColor = [UIColor clearColor];
    self.makeUpView.topView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.makeUpView.bottomCollection.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    [self.view addSubview: self.makeUpView];

    _makeUpView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 182);
}

- (void)setHairView {
    self.hairView = [[FUHairView alloc] init];
    self.hairView.delegate = self;
    [self.view addSubview:self.hairView];
    self.hairView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 134);

}
- (void)updateToolBarWith:(FULiveModel *)model {
    faceBeautyMode = self.model.type == FULiveModelTypeBeautifyFace ;

    if (faceBeautyMode) {
        [self hiddenModelTableView:YES];
        [self hiddenButtonsWith:YES];
        [self hiddenItemsView:YES];

        [[FUManager shareManager] loadFilter];

        [self hiddenToolBarWith:NO];

    }else if (self.model.type == FULiveModelTypeMakeUp) {

        [[FUManager shareManager] destoryItemAboutType:FUNamaHandleTypeFxaa];
        [self hiddenModelTableView:YES];
        [self hiddenButtonsWith:YES];
        [self hiddenItemsView:YES];

        [[FUManager shareManager] loadFilter];
        /* 初始状态 */
        [[FUManager shareManager] loadMakeupType:@"new_face_tracker"];
        [[FUManager shareManager] loadMakeupBundleWithName:@"face_makeup"];

        NSString *wholePath=[[NSBundle mainBundle] pathForResource:@"makeup_whole" ofType:@"json"];
        NSData *wholeData=[[NSData alloc] initWithContentsOfFile:wholePath];
        NSDictionary *wholeDic=[NSJSONSerialization JSONObjectWithData:wholeData options:NSJSONReadingMutableContainers error:nil];
        NSArray *supArray = [FUMakeupSupModel mj_objectArrayWithKeyValuesArray:wholeDic[@"data"]];
        [_makeUpView setWholeArray:supArray];
        _makeUpView.topView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _makeUpView.bottomCollection.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        /* 美妆道具 */
        [_makeUpView setSelSupItem:1];
        [self hiddenMakeUpView:NO];
        [self hiddenToolBarWith:YES];

    }else if (self.model.type == FULiveModelTypeHair) {
        [self hiddenModelTableView:YES];
        [self hiddenButtonsWith:YES];
        [self hiddenItemsView:YES];
        [self hiddenHairView:NO];
        /* 初始状态 */
         [[FUManager shareManager] loadFilter];
        [[FUManager shareManager] loadItem:@"hair_gradient"];
        [[FUManager shareManager] setHairColor:0];
        [[FUManager shareManager] setHairStrength:0.5];

        self.hairView.itemsArray = self.model.items;
    } else {

        [[FUManager shareManager] destoryItems];

        [self hiddenModelTableView:YES];
        [self hiddenButtonsWith:YES];
        [self hiddenToolBarWith:YES];

        self.itemsView.itemsArray = self.model.items;

        NSString *selectItem = self.model.items.count > 0 ? self.model.items[0] : @"noitem" ;

        self.itemsView.selectedItem = selectItem ;
        [[FUManager shareManager] loadFilter];
        [[FUManager shareManager] loadItem: selectItem];


        if (self.model.type == FULiveModelTypePortraitDrive) {

            [[FUManager shareManager] set3DFlipH];
        }else if (self.model.type == FULiveModelTypeGestureRecognition) {

        }
        
        if (self.model.type == FULiveModelTypeAnimoji) {

            [[FUManager shareManager] destoryItemAboutType:FUNamaHandleTypeFxaa];
            [[FUManager shareManager] loadAnimojiFaxxBundle];
            [[FUManager shareManager] set3DFlipH];
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            NSString *alertString = [[FUManager shareManager] hintForItem:selectItem];
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
    [self.agoraKit setVideoEncoderConfiguration:[[AgoraVideoEncoderConfiguration alloc]initWithSize:AgoraVideoDimension640x360
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
    UIView *renderView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.containView insertSubview:renderView atIndex:0];
    if (self.localCanvas == nil) {
        self.localCanvas = [[AgoraRtcVideoCanvas alloc] init];
    }
    self.localCanvas.view = renderView;
    self.localCanvas.renderMode = AgoraVideoRenderModeHidden;
    [self.agoraKit setupLocalVideo:self.localCanvas];
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

/**
 *  Faceunity Tool Bar
 *  Init FUAPIDemoBar，Set beauty parameters
 */
-(void)setDemoBar:(FUAPIDemoBar *)demoBar {

    _demoBar = demoBar;

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
    _demoBar.enlargingLevel_new = [FUManager shareManager].enlargingLevel ;
    _demoBar.thinningLevel_new = [FUManager shareManager].thinningLevel ;
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

- (void)hiddenMakeUpView:(BOOL)hidden {
    self.makeUpView.alpha = hidden ? 1.0 : 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        self.makeUpView.transform =  hidden ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, -self.makeUpView.frame.size.height);
        self.makeUpView.alpha = hidden ? 0.0 : 1.0;
    }];
}

- (void)hiddenHairView:(BOOL)hidden {
    self.hairView.alpha = hidden ? 1.0 : 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        self.hairView.transform =  hidden ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, -self.hairView.frame.size.height);
        self.hairView.alpha = hidden ? 0.0 : 1.0;
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
    [self hiddenMakeUpView:YES];
    [self hiddenHairView:YES];
}

/**
 * Hide the tool bar
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches allObjects].firstObject;
    if (touch.view == self.demoBar || touch.view == self.modelTableView || touch.view == self.itemsView || !self.barBtn.hidden) {
        return;
    }
    [self hiddenButtonsWith:NO];
    [self hiddenToolBarWith:YES];
    [self hiddenModelTableView:YES];
    [self hiddenItemsView:YES];
    [self hiddenMakeUpView:YES];
    [self hiddenHairView:YES];
}

- (IBAction)leaveBtnClick:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.mCamera stopCapture];
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
    [_mCamera changeCameraInputDeviceisFront:!_mCamera.isFrontCamera];

    //Change camera need to call below function
    [self.agoraKit switchCamera];
    [[FUManager shareManager] onCameraChange];
    [self setCaptureVideoOrientation];
}

- (IBAction)muteBtnClick:(UIButton *)sender {
    self.isMuted = !self.isMuted;
    [self.agoraKit muteLocalAudioStream:self.isMuted];
    [self.muteBtn setImage:[UIImage imageNamed: self.isMuted ? @"microphone-mute" : @"microphone"] forState:UIControlStateNormal];
}

- (IBAction)buglyBtnClick:(UIButton *)sender {
    self.buglyLabel.hidden = !self.buglyLabel.hidden;
}

- (void)setCaptureVideoOrientation {
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

#pragma mark --- FUItemsViewDelegate
- (void)itemsViewDidSelectedItem:(NSString *)item {
    [[FUManager shareManager] loadItem:item];

    [self.itemsView stopAnimation];

    if (self.model.type == FULiveModelTypeHair) {

    }

    if (self.model.type == FULiveModelTypeAnimoji) {

    }

    if (self.model.type == FULiveModelTypeMusicFilter) {
        [[FUMusicPlayer sharePlayer] stop];
        if (![item isEqualToString:@"noitem"]) {
            [[FUMusicPlayer sharePlayer] playMusic:@"douyin.mp3"];
        }
    }


    if (self.model.type == FULiveModelTypeGestureRecognition) {

        //        [[FUManager shareManager] setLoc_xy_flip];
    }

    dispatch_async(dispatch_get_main_queue(), ^{

        NSString *alertString = [[FUManager shareManager] hintForItem:item];
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

#pragma mark - FUMakeUpView  Delegate
/* 美妆样式图 */
- (void)makeupViewDidSelectedNamaStr:(NSString *)namaStr imageName:(NSString *)imageName
{
     [[FUManager shareManager] setMakeupItemParamImage:[UIImage imageNamed:imageName]  param:namaStr];
}
/* 妆容颜色 */
- (void)makeupViewDidSelectedNamaStr:(NSString *)namaStr valueArr:(NSArray *)valueArr
{
    [[FUManager shareManager] setMakeupItemStr:namaStr valueArr:valueArr];
}
// 滑动事件
- (void)makeupViewDidChangeValue:(float)value namaValueStr:(NSString *)namaStr
{
    [[FUManager shareManager] setMakeupItemIntensity:value param:namaStr];
}
/* 当前样式的所有可选颜色 */
- (void)makeupViewSelectiveColorArray:(NSArray <NSArray *> *)colors selColorIndex:(int)index
{
//    [_colourView setDataColors:colors];
//    [_colourView setSelCell:index];
}
/* 切换的妆容t类型标题 */
- (void)makeupViewDidSelTitle:(NSString *)nama
{

}

/* 组合妆想要的滤镜 */
- (void)makeupFilter:(NSString *)filterStr value:(float)filterValue
{
    if (!filterStr) {
        return;
    }
    [FUManager shareManager].selectedFilter = filterStr ;
    [FUManager shareManager].selectedFilterLevel = filterValue;

}
// 自定义选择
- (void)makeupCustomShow:(BOOL)isShow
{

}

- (void)makeupSelColorStata:(BOOL)stata
{

}

#pragma mark - FUHairViewDelegate
-(void)hairViewDidSelectedhairIndex:(NSInteger)index {
    if (index == -1) {
        [[FUManager shareManager] setHairColor:0];
        [[FUManager shareManager] setHairStrength:0.0];
    }else{
        if(index < 5) {//渐变色
            [[FUManager shareManager] setHairColor:(int)index];
            [[FUManager shareManager] setHairStrength:self.hairView.slider.value];
        }else{

            [[FUManager shareManager] setHairColor:(int)index - 5];
            [[FUManager shareManager] setHairStrength:self.hairView.slider.value];
        }
    }
}

-(void)hairViewChanageStrength:(float)strength{
    [[FUManager shareManager] setHairStrength:strength];
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
    [FUManager shareManager].enlargingLevel = _demoBar.enlargingLevel_new;
    [FUManager shareManager].thinningLevel = _demoBar.thinningLevel_new;
    [FUManager shareManager].jewLevel = _demoBar.chinLevel;
    [FUManager shareManager].foreheadLevel = _demoBar.foreheadLevel;
    [FUManager shareManager].noseLevel = _demoBar.noseLevel;
    [FUManager shareManager].mouthLevel = _demoBar.mouthLevel;

    [FUManager shareManager].selectedFilter = _demoBar.selectedFilter ;
    [FUManager shareManager].selectedFilterLevel = _demoBar.selectedFilterLevel;
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
