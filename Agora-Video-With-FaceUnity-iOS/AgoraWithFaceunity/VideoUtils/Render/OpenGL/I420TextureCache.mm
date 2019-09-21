//
//  I420TextureCache.m
//  TestProject
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import "I420TextureCache.h"
#import <OpenGLES/ES3/gl.h>

#import "I420Buffer.h"
#import "VideoFrameBuffer.h"

#include <vector>

// Two sets of 3 textures are used here, one for each of the Y, U and V planes. Having two sets
// alleviates CPU blockage in the event that the GPU is asked to render to a texture that is already
// in use.
static const GLsizei kNumTextureSets = 2;
static const GLsizei kNumTexturesPerSet = 3;
static const GLsizei kNumTextures = kNumTexturesPerSet * kNumTextureSets;

@implementation I420TextureCache {
    BOOL _hasUnpackRowLength;
    GLint _currentTextureSet;
    // Handles for OpenGL constructs.
    GLuint _textures[kNumTextures];
    // Used to create a non-padded plane for GPU upload when we receive padded frames.
    std::vector<uint8_t> _planeBuffer;
}

- (GLuint)yTexture {
    return _textures[_currentTextureSet * kNumTexturesPerSet];
}

- (GLuint)uTexture {
    return _textures[_currentTextureSet * kNumTexturesPerSet + 1];
}

- (GLuint)vTexture {
    return _textures[_currentTextureSet * kNumTexturesPerSet + 2];
}

- (instancetype)initWithContext:(EAGLContext *)context {
    if (self = [super init]) {
        _hasUnpackRowLength = (context.API == kEAGLRenderingAPIOpenGLES3);
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        
        [self setupTextures];
    }
    return self;
}

- (void)dealloc {
    glDeleteTextures(kNumTextures, _textures);
}

- (void)setupTextures {
    glGenTextures(kNumTextures, _textures);
    // Set parameters for each of the textures we created.
    for (GLsizei i = 0; i < kNumTextures; i++) {
        glBindTexture(GL_TEXTURE_2D, _textures[i]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }
}

- (void)uploadPlane:(const uint8_t *)plane
            texture:(GLuint)texture
              width:(size_t)width
             height:(size_t)height
             stride:(int32_t)stride {
    glBindTexture(GL_TEXTURE_2D, texture);
    
    const uint8_t *uploadPlane = plane;
    if ((size_t)stride != width) {
        if (_hasUnpackRowLength) {
            // GLES3 allows us to specify stride.
            glPixelStorei(GL_UNPACK_ROW_LENGTH, stride);
            glTexImage2D(GL_TEXTURE_2D,
                         0,
                         GL_LUMINANCE,
                         static_cast<GLsizei>(width),
                         static_cast<GLsizei>(height),
                         0,
                         GL_LUMINANCE,
                         GL_UNSIGNED_BYTE,
                         uploadPlane);
            glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
            return;
        } else {
            // Make an unpadded copy and upload that instead. Quick profiling showed
            // that this is faster than uploading row by row using glTexSubImage2D.
            uint8_t *unpaddedPlane = _planeBuffer.data();
            for (size_t y = 0; y < height; ++y) {
                memcpy(unpaddedPlane + y * width, plane + y * stride, width);
            }
            uploadPlane = unpaddedPlane;
        }
    }
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 GL_LUMINANCE,
                 static_cast<GLsizei>(width),
                 static_cast<GLsizei>(height),
                 0,
                 GL_LUMINANCE,
                 GL_UNSIGNED_BYTE,
                 uploadPlane);
}

- (void)uploadFrameToTextures:(VideoFrame *)frame {
    _currentTextureSet = (_currentTextureSet + 1) % kNumTextureSets;
    
    id<I420Buffer> buffer = [frame.buffer toI420];
    
    const int chromaWidth = buffer.chromaWidth;
    const int chromaHeight = buffer.chromaHeight;
    if (buffer.strideY != frame.width || buffer.strideU != chromaWidth ||
        buffer.strideV != chromaWidth) {
        _planeBuffer.resize(buffer.width * buffer.height);
    }
    
    [self uploadPlane:buffer.dataY
              texture:self.yTexture
                width:buffer.width
               height:buffer.height
               stride:buffer.strideY];
    
    [self uploadPlane:buffer.dataU
              texture:self.uTexture
                width:chromaWidth
               height:chromaHeight
               stride:buffer.strideU];
    
    [self uploadPlane:buffer.dataV
              texture:self.vTexture
                width:chromaWidth
               height:chromaHeight
               stride:buffer.strideV];
}
@end

