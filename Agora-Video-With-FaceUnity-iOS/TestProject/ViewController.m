//
//  ViewController.m
//  TestProject
//
//  Created by Zhang Ji on 2019/9/22.
//  Copyright © 2019 ZhangJi. All rights reserved.
//

#import "ViewController.h"

#import <Foundation/Foundation.h>
#import <CapturerAndRender/CapturerAndRender.h>

@interface ViewController ()<VideoCapturerDelegate>

@property (weak, nonatomic) IBOutlet GLRenderView *renderView;
@property (weak, nonatomic) IBOutlet GLRenderView *renderView2;

@property (nonatomic, strong) CaptureManager *myCapturer;

@property (nonatomic, assign) MirrorModel currentMirrorModel;
@property (nonatomic, assign) RenderModel currentRenderModel;

@end

@implementation ViewController

- (CaptureManager *)myCapturer {
    if (!_myCapturer) {
        CameraVideoCapturer *camera = [[CameraVideoCapturer alloc] initWithDelegate:self];
        _myCapturer = [[CaptureManager alloc] initWithCapturer:camera width:480 height:640 fps:15];
    }
    return _myCapturer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_renderView setRenderModel:RenderModelFit];
    _currentRenderModel = RenderModelFit;
    _currentMirrorModel = MirrorModelDefault;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.myCapturer startCapture];
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

-(void)capturer: (CameraVideoCapturer *)capturer didCaptureFrame: (VideoFrame*)frame {
    [_renderView renderFrame:frame];
    [_renderView2 renderFrame:frame];
}

@end
