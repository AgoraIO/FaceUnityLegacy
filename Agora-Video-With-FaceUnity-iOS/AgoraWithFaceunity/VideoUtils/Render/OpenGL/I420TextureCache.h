//
//  I420TextureCache.h
//  TestProject
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../../VideoFrame/VideoFrame.h"

NS_ASSUME_NONNULL_BEGIN

@interface I420TextureCache : NSObject

@property(nonatomic, readonly) GLuint yTexture;
@property(nonatomic, readonly) GLuint uTexture;
@property(nonatomic, readonly) GLuint vTexture;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithContext:(EAGLContext *)context NS_DESIGNATED_INITIALIZER;

- (void)uploadFrameToTextures:(VideoFrame *)frame;

@end

NS_ASSUME_NONNULL_END
