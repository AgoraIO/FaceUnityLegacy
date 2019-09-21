//
//  VideoRender.h
//  RtmpStreamingKit
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#ifndef VideoRender_h
#define VideoRender_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class VideoFrame;

typedef NS_ENUM(NSInteger, RenderModel) {
    RenderModelFit = 0,
    RenderModelHidden = 1,
};

@protocol VideoRender <NSObject>

/** The size of the frame. */
- (void)setSize:(CGSize)size;

/** The frame to be displayed. */
- (void)renderFrame:(nullable VideoFrame *)frame;

- (void)setRenderModel:(RenderModel)model;

- (void)shouldMirror:(BOOL)mirrored;

@end

@protocol VideoViewDelegate

- (void)videoView:(id<VideoRender>_Nonnull)videoView didChangeVideoSize:(CGSize)size;

@end

#endif /* VideoRender_h */
