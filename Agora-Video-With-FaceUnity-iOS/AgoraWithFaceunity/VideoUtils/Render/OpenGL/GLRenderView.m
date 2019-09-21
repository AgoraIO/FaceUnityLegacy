//
//  GLRenderView.m
//  TestProject
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import "GLRenderView.h"
#import <GLKit/GLKit.h>

#import "DefaultShader.h"
#import "DisplayLinkTimer.h"
#import "I420TextureCache.h"
#import "NV12TextureCache.h"
#import "LogCenter.h"
#import "VideoFrame.h"
#import "VideoFrameBuffer.h"
#import "CustomCVPixelBuffer.h"

@interface GLRenderView () <GLKViewDelegate>

@property(atomic, strong) VideoFrame *videoFrame;
@property(nonatomic, readonly) GLKView *glkView;
@property(nonatomic, assign) BOOL mirrored;
@property(nonatomic, assign) BOOL isMirrorSetted;
@property(nonatomic, assign) RenderModel model;
@property(nonatomic, assign) BOOL isModelSetted;

@end

@implementation GLRenderView {
    DisplayLinkTimer *_timer;
    EAGLContext *_glContext;
    // This flag should only be set and read on the main thread (e.g. by setNeedsDisplay)
    BOOL _isDirty;
    id<VideoViewShading> _shader;
    NV12TextureCache *_nv12TextureCache;
    I420TextureCache *_i420TextureCache;
    // As timestamps should be unique between frames, will store last
    // drawn frame timestamp instead of the whole frame to reduce memory usage.
    int64_t _lastDrawnFrameTimeStampNs;
}

@synthesize delegate = _delegate;
@synthesize videoFrame = _videoFrame;
@synthesize glkView = _glkView;

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame shader:[[DefaultShader alloc] init]];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithCoder:aDecoder shader:[[DefaultShader alloc] init]];
}

- (instancetype)initWithFrame:(CGRect)frame shader:(id<VideoViewShading>)shader {
    if (self = [super initWithFrame:frame]) {
        _shader = shader;
        if (![self configure]) {
            return nil;
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder shader:(id<VideoViewShading>)shader {
    if (self = [super initWithCoder:aDecoder]) {
        _shader = shader;
        if (![self configure]) {
            return nil;
        }
    }
    return self;
}

- (BOOL)configure {
    EAGLContext *glContext =
    [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!glContext) {
        glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    if (!glContext) {
//        AgoraLogError(@"Failed to create EAGLContext");
        return NO;
    }
    _glContext = glContext;
    
    // GLKView manages a framebuffer for us.
    _glkView = [[GLKView alloc] initWithFrame:CGRectZero
                                      context:_glContext];
    _glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    _glkView.drawableDepthFormat = GLKViewDrawableDepthFormatNone;
    _glkView.drawableStencilFormat = GLKViewDrawableStencilFormatNone;
    _glkView.drawableMultisample = GLKViewDrawableMultisampleNone;
    _glkView.delegate = self;
    _glkView.layer.masksToBounds = YES;
    _glkView.enableSetNeedsDisplay = NO;
    [self addSubview:_glkView];
    
    // Listen to application state in order to clean up OpenGL before app goes
    // away.
    NSNotificationCenter *notificationCenter =
    [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(willResignActive)
                               name:UIApplicationWillResignActiveNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(didBecomeActive)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    
    // Frames are received on a separate thread, so we poll for current frame
    // using a refresh rate proportional to screen refresh frequency. This
    // occurs on the main thread.
    __weak GLRenderView *weakSelf = self;
    _timer = [[DisplayLinkTimer alloc] initWithTimerHandler:^{
        GLRenderView *strongSelf = weakSelf;
        [strongSelf displayLinkTimerDidFire];
    }];
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [self setupGL];
    }
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    UIApplicationState appState =
    [UIApplication sharedApplication].applicationState;
    if (appState == UIApplicationStateActive) {
        [self teardownGL];
    }
    [_timer invalidate];
    [self ensureGLContext];
    _shader = nil;
    if (_glContext && [EAGLContext currentContext] == _glContext) {
        [EAGLContext setCurrentContext:nil];
    }
}

#pragma mark - UIView

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    _isDirty = YES;
}

- (void)setNeedsDisplayInRect:(CGRect)rect {
    [super setNeedsDisplayInRect:rect];
    _isDirty = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _glkView.frame = self.bounds;
}

#pragma mark - GLKViewDelegate

// This method is called when the GLKView's content is dirty and needs to be
// redrawn. This occurs on main thread.
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // The renderer will draw the frame to the framebuffer corresponding to the
    // one used by |view|.
    VideoFrame *frame = self.videoFrame;
    if (!frame || frame.timeStampNs == _lastDrawnFrameTimeStampNs) {
        return;
    }
    [self ensureGLContext];
    glClear(GL_COLOR_BUFFER_BIT);
    if ([frame.buffer isKindOfClass:[CustomCVPixelBuffer class]]) {
        if (!_nv12TextureCache) {
            _nv12TextureCache = [[NV12TextureCache alloc] initWithContext:_glContext];
        }
        if (_nv12TextureCache) {
            [_nv12TextureCache uploadFrameToTextures:frame];
            
            RenderModel currentModel = RenderModelHidden;
            if (self.isModelSetted) {
                currentModel = self.model;
            }
            BOOL currentMorrired = frame.usingFrontCamera ? YES : NO;
            if (self.isMirrorSetted) {
                currentMorrired = self.mirrored;
            }
            
            [_shader applyShadingForFrameWithWidth:frame.width
                                            height:frame.height
                                         viewWidth:self.bounds.size.width
                                        viewHeight:self.bounds.size.height
                                          rotation:frame.rotation
                                       renderModel:currentModel
                                          morrired:currentMorrired
                                            yPlane:_nv12TextureCache.yTexture
                                           uvPlane:_nv12TextureCache.uvTexture];
            [_nv12TextureCache releaseTextures];
            
            _lastDrawnFrameTimeStampNs = self.videoFrame.timeStampNs;
        }
    } else {
        if (!_i420TextureCache) {
            _i420TextureCache = [[I420TextureCache alloc] initWithContext:_glContext];
        }
        [_i420TextureCache uploadFrameToTextures:frame];
        [_shader applyShadingForFrameWithWidth:frame.width
                                        height:frame.height
                                      rotation:frame.rotation
                                        yPlane:_i420TextureCache.yTexture
                                        uPlane:_i420TextureCache.uTexture
                                        vPlane:_i420TextureCache.vTexture];
        
        _lastDrawnFrameTimeStampNs = self.videoFrame.timeStampNs;
    }
}

#pragma mark - VideoRenderer

// These methods may be called on non-main thread.
- (void)setSize:(CGSize)size {
    __weak GLRenderView *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        GLRenderView *strongSelf = weakSelf;
        [strongSelf.delegate videoView:strongSelf didChangeVideoSize:size];
    });
}

- (void)renderFrame:(VideoFrame *)frame {
    self.videoFrame = frame;
}

- (void)setRenderModel:(RenderModel)model {
    self.isModelSetted = YES;
    self.model = model;
}

- (void)shouldMirror:(BOOL)mirrored {
    self.isMirrorSetted = YES;
    self.mirrored = mirrored;
}

#pragma mark - Private

- (void)displayLinkTimerDidFire {
    // Don't render unless video frame have changed or the view content
    // has explicitly been marked dirty.
    if (!_isDirty && _lastDrawnFrameTimeStampNs == self.videoFrame.timeStampNs) {
        return;
    }
    
    // Always reset isDirty at this point, even if -[GLKView display]
    // won't be called in the case the drawable size is empty.
    _isDirty = NO;
    
    // Only call -[GLKView display] if the drawable size is
    // non-empty. Calling display will make the GLKView setup its
    // render buffer if necessary, but that will fail with error
    // GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT if size is empty.
    if (self.bounds.size.width > 0 && self.bounds.size.height > 0) {
        [_glkView display];
    }
}

- (void)setupGL {
    [self ensureGLContext];
    glDisable(GL_DITHER);
    _timer.isPaused = NO;
}

- (void)teardownGL {
    self.videoFrame = nil;
    _timer.isPaused = YES;
    [_glkView deleteDrawable];
    [self ensureGLContext];
    _nv12TextureCache = nil;
    _i420TextureCache = nil;
}

- (void)didBecomeActive {
    [self setupGL];
}

- (void)willResignActive {
    [self teardownGL];
}

- (void)ensureGLContext {
    NSAssert(_glContext, @"context shouldn't be nil");
    if ([EAGLContext currentContext] != _glContext) {
        [EAGLContext setCurrentContext:_glContext];
    }
}
@end
