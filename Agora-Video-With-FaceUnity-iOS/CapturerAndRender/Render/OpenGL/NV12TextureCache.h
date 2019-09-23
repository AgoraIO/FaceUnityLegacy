//
//  NV12TextureCache.h
//  TestProject
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class VideoFrame;

NS_ASSUME_NONNULL_BEGIN

@interface NV12TextureCache : NSObject

@property(nonatomic, readonly) GLuint yTexture;
@property(nonatomic, readonly) GLuint uvTexture;

- (instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithContext:(EAGLContext *)context NS_DESIGNATED_INITIALIZER;

- (BOOL)uploadFrameToTextures:(VideoFrame *)frame;

- (void)releaseTextures;

@end

NS_ASSUME_NONNULL_END
