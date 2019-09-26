//
//  RenderManager.h
//  CapturerAndRender
//
//  Created by Zhang Ji on 2019/9/24.
//  Copyright © 2019 ZhangJi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLRenderView.h"
#import "VideoFrame.h"

NS_ASSUME_NONNULL_BEGIN

@class RenderManager;

@protocol Connector;

//@protocol RenderManagerConnector <NSObject>
//@optional
//
//- (void)renderManager:(RenderManager*)manager outputFrame: (VideoFrame*)frame;
//
//- (void)renderManager:(RenderManager*)manager outputPixelBuffer:(CVPixelBufferRef)pixelBuffer withTimeStamp:(CMTime)timeStamp rotation:(VideoRotation)rotation;
//
//@end

@interface RenderManager : NSObject

@property(nonatomic, strong) GLRenderView* view;

@property(nonatomic, assign) RenderModel renderModel;

@property(nonatomic, assign) MirrorModel mirrorModel;

@property(nonatomic, weak) id<Connector> connector;

- (instancetype)initWithView:(GLRenderView*)view
                   connector:(nullable id<Connector>)connector;

- (instancetype)initWithConnector:(nullable id<Connector>)connector;

@end

NS_ASSUME_NONNULL_END
