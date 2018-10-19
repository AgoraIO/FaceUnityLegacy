//
//  TPSPushOSDView.h
//  TPSLIVE
//
//  Created by tps on 2018/6/5.
//  Copyright © 2018年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPSLandscapeCommentView.h"

typedef void(^ZoomBlock)();
typedef void(^MuteBlock)(BOOL muteStatus);
typedef void(^BackBlock)();
typedef void(^SwitchBlock)(BOOL switchStatus);

@interface TPSPushOSDView : UIView <UITextViewDelegate>

@property (nonatomic, copy) SwitchBlock switchBlock;
@property (nonatomic, copy) ZoomBlock zoomBlock;
@property (nonatomic, copy) MuteBlock muteBlock;
@property (nonatomic, copy) BackBlock backBlock;

@property (nonatomic, strong) UIView *videoContentView;
@property (nonatomic, strong) UIButton *switchCameraBtn;
@property (nonatomic, strong) UIButton *backButton;//返回按钮
@property (nonatomic, strong) UIButton *muteBtn;    //静音按钮
@property (nonatomic, strong) UIButton *zoomButton;//全屏

//评论
@property (nonatomic, strong) UILabel *placeLabel;
@property (nonatomic, strong) UIView *customMaskView;
@property (nonatomic, strong) UITextView *commentTextView;
@property (nonatomic, strong) TPSLandscapeCommentView *commentView;

//音频样式
@property (nonatomic, strong) UIView *audioContentView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *showGifImageV;
@property (nonatomic, strong) UILabel *liveTimeLab;
@property (nonatomic, strong) NSTimer *liveTimer;
@property (nonatomic, assign) long liveTime;

@property (nonatomic, assign) BOOL isAudio;
- (void)shouldRefreshComment;
- (void)unRegistObserver;
- (void)startLiveTimer;
- (void)destroy;
@end
