//
//  RGBATextureCache.h
//  CapturerAndRender
//
//  Created by Zhang Ji on 2019/9/23.
//  Copyright © 2019 ZhangJi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class VideoFrame;

NS_ASSUME_NONNULL_BEGIN

@interface RGBATextureCache : NSObject

@property(nonatomic, readonly) GLuint rgbaTexture;

- (instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithContext:(EAGLContext *)context NS_DESIGNATED_INITIALIZER;

- (BOOL)uploadFrameToTextures:(VideoFrame *)frame;

- (void)releaseTextures;

@end

NS_ASSUME_NONNULL_END
