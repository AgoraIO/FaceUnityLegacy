//
//  TPSPushOSDView.m
//  TPSLIVE
//
//  Created by tps on 2018/6/5.
//  Copyright © 2018年 HS. All rights reserved.
//

#import "TPSPushOSDView.h"

@implementation TPSPushOSDView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self init_TPSPushOSDView];
    }
    return self;
}

- (void)init_TPSPushOSDView {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    [self addGestureRecognizer:tap];
    
    _videoContentView = [[UIView alloc] init];
    _videoContentView.backgroundColor = [UIColor clearColor];
    [self addSubview:_videoContentView];
    
    _backButton = [UIButton new];
    [_backButton setImage:[UIImage imageNamed:@"full_screen_back"] forState:UIControlStateNormal];
    [_backButton setImage:[UIImage imageNamed:@"full_screen_back"] forState:UIControlStateHighlighted];
    [_backButton addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    [_videoContentView addSubview:_backButton];
    
    _switchCameraBtn = [UIButton new];
    [_switchCameraBtn setImage:[UIImage imageNamed:@"full_screen_camera"] forState:UIControlStateNormal];
    [_switchCameraBtn setImage:[UIImage imageNamed:@"full_screen_camera"] forState:UIControlStateHighlighted | UIControlStateSelected];
    [_switchCameraBtn addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventTouchUpInside];
    [_videoContentView addSubview:_switchCameraBtn];
    
    _muteBtn = [UIButton new];
    [_muteBtn setImage:[UIImage imageNamed:@"mute_nomal_icon"] forState:UIControlStateNormal];
    [_muteBtn setImage:[UIImage imageNamed:@"mute_selected_icon"] forState:UIControlStateSelected];
    [_muteBtn addTarget:self action:@selector(muteClick:) forControlEvents:UIControlEventTouchUpInside];
    [_videoContentView addSubview:_muteBtn];
    
    _zoomButton = [UIButton new];
    [_zoomButton setImage:[UIImage imageNamed:@"full_screen_open"] forState:UIControlStateNormal];
    [_zoomButton setImage:[UIImage imageNamed:@"full_screen_close"] forState:UIControlStateHighlighted | UIControlStateSelected];
    [_zoomButton addTarget:self action:@selector(zoomClick:) forControlEvents:UIControlEventTouchUpInside];
    [_videoContentView addSubview:_zoomButton];
 
    [self setupConstraints];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    [_videoContentView addGestureRecognizer:tap1];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(controlViewHidden) object:nil];
    [self performSelector:@selector(controlViewHidden) withObject:nil afterDelay:5];
}

- (void)setupConstraints {
   
    [_videoContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(AUTO_HEIGHT(24));
        make.left.mas_equalTo(AUTO_WIDTH(15));
        make.width.height.mas_equalTo(AUTO_WIDTH(35));
    }];

    [self.muteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(AUTO_HEIGHT(24));
        make.right.mas_equalTo(-AUTO_WIDTH(15));
        make.width.height.mas_equalTo(AUTO_WIDTH(35));
    }];
    
    [self.switchCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(AUTO_HEIGHT(24));
        make.right.equalTo(self.muteBtn.mas_left).offset(-AUTO_WIDTH(15));
        make.width.height.mas_equalTo(AUTO_WIDTH(35));
    }];
    
    [self.zoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(AUTO_WIDTH(-24));
        make.right.mas_equalTo(AUTO_WIDTH(-15));
        make.width.height.mas_equalTo(AUTO_HEIGHT(35));
    }];
}

- (void)setIsAudio:(BOOL)isAudio {
    _isAudio = isAudio;
    if (isAudio) {
        [self.audioContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.showGifImageV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"playingAudio@2x" ofType:@"gif"];
        [self.showGifImageV showGifImageWithData:[NSData dataWithContentsOfFile:path]];
        
        [self.liveTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.bottom.mas_equalTo(-55);
            make.height.mas_equalTo(15);
        }];
        
        self.zoomButton.hidden = YES;
        self.switchCameraBtn.hidden = YES;
        [self bringSubviewToFront:_videoContentView];
    } else {
        WEAKSELF
        self.commentView = [[TPSLandscapeCommentView alloc] init];
        self.commentView.isAnchor = YES;
        self.commentView.commentBlock = ^{
            STRONGSELF
            [strongSelf.commentTextView becomeFirstResponder];
        };
        self.commentView.alpha = 0;
        [self addSubview:self.commentView];
        
        self.commentTextView = [[UITextView alloc] init];
        self.commentTextView.alpha = 0;
        [self.commentTextView setFont:TPSAjustFontSize(14)];
        [self.commentTextView setReturnKeyType:UIReturnKeySend];
        [self.commentTextView.layer setMasksToBounds:YES];
        [self.commentTextView.layer setCornerRadius:4.0f];
        self.commentTextView.backgroundColor = RGBColor(239, 239, 239);
        [self.commentTextView setScrollsToTop:NO];
        [KeyboardToolBar unregisterKeyboardToolBarWithTextView:self.commentTextView];
        self.commentTextView.delegate = self;
        [self addSubview:self.commentTextView];
        
        self.placeLabel = [[UILabel alloc] init];
        self.placeLabel.font = TPSAjustFontSize(14);
        self.placeLabel.textColor = RGBColor(211, 211, 211);
        self.placeLabel.text = @"请输入评论";
        self.placeLabel.enabled = NO;//lable必须设置为不可用
        self.placeLabel.backgroundColor = [UIColor clearColor];
        [self.commentTextView addSubview:self.placeLabel];
        
        [self.commentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.bottom.mas_equalTo(-20);
            make.size.mas_equalTo(CGSizeMake(350, 150));
        }];
        
        [self.placeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(AUTO_WIDTH(5));
            make.centerY.mas_equalTo(self.commentTextView.mas_centerY);
        }];
        
        [self.commentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-AUTO_HEIGHT(10));
            make.centerX.mas_equalTo(self.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(448, 35));
        }];
    }
}

#pragma mark - 通知相关
- (void)unRegistObserver {
    [self.commentView.tableView clean];
    _commentTextView.delegate = nil;
    [MyNotiCenter removeObserver:self];
}

- (void)registObserver {
    [MyNotiCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [MyNotiCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [MyNotiCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [MyNotiCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyBoardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    WEAKSELF
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        STRONGSELF
        strongSelf.commentTextView.alpha = 1;
        [strongSelf.commentTextView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-CGRectGetHeight(keyBoardRect) - AUTO_HEIGHT(10));
        }];
    } completion:^(BOOL finished) {
        STRONGSELF
        strongSelf.customMaskView.hidden = NO;
    }];
    [self layoutIfNeeded];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.customMaskView.hidden = YES;
    WEAKSELF
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        STRONGSELF
        strongSelf.commentTextView.alpha = 0;
        [strongSelf.commentTextView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-AUTO_HEIGHT(10));
        }];
    }];
    [self layoutIfNeeded];
}

- (void)shouldRefreshComment {
    [self.commentView.tableView shouldRefreshToTop:YES animated:YES];
}

#pragma mark - Actions
- (void)backClick:(UIButton *)sender {
    if (self.backBlock) {
        self.backBlock();
    }
}

- (void)switchClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.switchBlock) {
        self.switchBlock(sender.selected);
    }
}

- (void)muteClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.muteBlock) {
        self.muteBlock(sender.selected);
    }
}

- (void)zoomClick:(UIButton *)sender {
    if (self.zoomBlock) {
        self.zoomBlock();
    }
}

#pragma mark - getter
- (UIView *)audioContentView {
    if (_audioContentView == nil) {
        _audioContentView = [[UIView alloc] init];
        _audioContentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_audioContentView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [_audioContentView addGestureRecognizer:tap];
    }
    return _audioContentView;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = kLOADIMAGE(@"playingAudio_bg");
        _imageView.userInteractionEnabled = YES;
        [_audioContentView addSubview:_imageView];
    }
    return _imageView;
}


- (UIImageView *)showGifImageV{
    if (!_showGifImageV) {
        _showGifImageV = [[UIImageView alloc] init];
        [_audioContentView addSubview:_showGifImageV];
    }
    return _showGifImageV;
}

- (UILabel *)liveTimeLab{
    if (!_liveTimeLab) {
        _liveTimeLab = [[UILabel alloc] init];
        _liveTimeLab.textAlignment = NSTextAlignmentCenter;
        _liveTimeLab.textColor = WhiteColor;
        _liveTimeLab.font = TPSFontSize(AUTO_WIDTH(14));
        [_audioContentView addSubview:_liveTimeLab];
    }
    return _liveTimeLab;
}

#pragma mark - delegate
- (void)startLiveTimer {
    if (!self.liveTimer) {
        self.liveTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshLiveTime) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.liveTimer forMode:NSDefaultRunLoopMode];
    }
}

- (void)refreshLiveTime {
    _liveTime ++;
    NSInteger curHours = floor(_liveTime / 3600);
    NSInteger curMinutes = floor(_liveTime % 3600 / 60);
    NSInteger curSeconds = floor(_liveTime % 3600 % 60);
    NSString *currentString = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",curHours, curMinutes, curSeconds];
    self.liveTimeLab.text = currentString;
}

- (void)destroy {
    [self.liveTimer invalidate];
    self.liveTimer = nil;
}

/**点击隐藏动画*/
- (void)tapGesture:(UITapGestureRecognizer *)sender{
    if (_backButton.alpha == 0) {
        [self controlViewOutHidden];
    } else {
        [self controlViewHidden];
    }
}

/**控制条隐藏*/
-(void)controlViewHidden{
    [UIView animateWithDuration:0.25 animations:^{
        _backButton.alpha = 0;
        _videoContentView.alpha = 0;
    }];
}
/**控制条显示*/
-(void)controlViewOutHidden{
    
    [UIView animateWithDuration:0.25 animations:^{
        _backButton.alpha = 1;
        _videoContentView.alpha = 1;
    }];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(controlViewHidden) object:nil];
    [self performSelector:@selector(controlViewHidden) withObject:nil afterDelay:5];
}

@end
