//
//  RGBATextureCache.m
//  CapturerAndRender
//
//  Created by Zhang Ji on 2019/9/23.
//  Copyright © 2019 ZhangJi. All rights reserved.
//

#import "RGBATextureCache.h"
#import "VideoFrame.h"
#import "VideoFrameBuffer.h"
#import "CustomCVPixelBuffer.h"

@implementation RGBATextureCache {
    CVOpenGLESTextureCacheRef _textureCache;
    CVOpenGLESTextureRef _rgbaTextureRef;
}

- (GLuint)rgbaTexture {
    return CVOpenGLESTextureGetName(_rgbaTextureRef);
}

- (instancetype)initWithContext:(EAGLContext *)context {
    if (self = [super init]) {
        CVReturn ret = CVOpenGLESTextureCacheCreate(
                                                    kCFAllocatorDefault, NULL,
#if COREVIDEO_USE_EAGLCONTEXT_CLASS_IN_API
                                                    context,
#else
                                                    (__bridge void *)context,
#endif
                                                    NULL, &_textureCache);
        if (ret != kCVReturnSuccess) {
            self = nil;
        }
    }
    return self;
}

- (BOOL)loadTexture:(CVOpenGLESTextureRef *)textureOut
        pixelBuffer:(CVPixelBufferRef)pixelBuffer
         planeIndex:(int)planeIndex
        pixelFormat:(GLenum)pixelFormat {
    const int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    const int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    
    if (*textureOut) {
        CFRelease(*textureOut);
        *textureOut = nil;
    }
    CVReturn ret = CVOpenGLESTextureCacheCreateTextureFromImage(
                                                                kCFAllocatorDefault, _textureCache, pixelBuffer, NULL, GL_TEXTURE_2D, pixelFormat, width,
                                                                height, pixelFormat, GL_UNSIGNED_BYTE, planeIndex, textureOut);
    
    if (ret != kCVReturnSuccess) {
        if (*textureOut) {
            CFRelease(*textureOut);
            *textureOut = nil;
        }
        return NO;
    }
    NSAssert(CVOpenGLESTextureGetTarget(*textureOut) == GL_TEXTURE_2D,
             @"Unexpected GLES texture target");
    glBindTexture(GL_TEXTURE_2D, CVOpenGLESTextureGetName(*textureOut));
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    return YES;
}

- (BOOL)uploadFrameToTextures:(VideoFrame *)frame {
    NSAssert([frame.buffer isKindOfClass:[CustomCVPixelBuffer class]],
             @"frame must be CVPixelBuffer backed");
    CustomCVPixelBuffer *rtcPixelBuffer = (CustomCVPixelBuffer *)frame.buffer;
    CVPixelBufferRef pixelBuffer = rtcPixelBuffer.pixelBuffer;
    return [self loadTexture:&_rgbaTextureRef
                 pixelBuffer:pixelBuffer
                  planeIndex:0
                 pixelFormat:GL_RGBA];
}

- (void)releaseTextures {
    if (_rgbaTextureRef) {
        CFRelease(_rgbaTextureRef);
        _rgbaTextureRef = nil;
    }
}

- (void)dealloc {
    [self releaseTextures];
    if (_textureCache) {
        CFRelease(_textureCache);
        _textureCache = nil;
    }
}

@end
