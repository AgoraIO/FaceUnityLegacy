//
//  VideoViewShading.h
//  RtmpStreamingKit
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#ifndef VideoViewShading_h
#define VideoViewShading_h

#import "../../VideoFrame/VideoFrame.h"
#import "../VideoRender.h"

@protocol VideoViewShading <NSObject>

/** Callback for I420 frames. Each plane is given as a texture. */
- (void)applyShadingForFrameWithWidth:(int)width
                               height:(int)height
                             rotation:(VideoRotation)rotation
                               yPlane:(GLuint)yPlane
                               uPlane:(GLuint)uPlane
                               vPlane:(GLuint)vPlane;

/** Callback for NV12 frames. Each plane is given as a texture. */
- (void)applyShadingForFrameWithWidth:(int)width
                               height:(int)height
                             rotation:(VideoRotation)rotation
                               yPlane:(GLuint)yPlane
                              uvPlane:(GLuint)uvPlane;

/** Callback for NV12 frames. Each plane is given as a texture. */
- (void)applyShadingForFrameWithWidth:(int)width
                               height:(int)height
                            viewWidth:(int)viewWidth
                           viewHeight:(int)viewHeight
                             rotation:(VideoRotation)rotation
                          renderModel:(RenderModel)renderModel
                             morrired:(BOOL)morrired
                               yPlane:(GLuint)yPlane
                              uvPlane:(GLuint)uvPlane;

@end

#endif /* VideoViewShading_h */
