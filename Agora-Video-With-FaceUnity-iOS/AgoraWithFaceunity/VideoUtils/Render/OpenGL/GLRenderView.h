//
//  GLRenderView.h
//  TestProject
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "VideoViewShading.h"
#import "../VideoRender.h"

NS_ASSUME_NONNULL_BEGIN

@class GLRenderView;

@interface GLRenderView : UIView <VideoRender>

@property(nonatomic, weak) id<VideoViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame
                       shader:(id<VideoViewShading>)shader NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
                       shader:(id<VideoViewShading>)shader NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
