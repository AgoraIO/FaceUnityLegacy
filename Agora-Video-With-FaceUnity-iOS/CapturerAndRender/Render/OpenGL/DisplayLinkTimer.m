//
//  DisplayLinkTimer.m
//  TestProject
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import "DisplayLinkTimer.h"

#import <UIKit/UIKit.h>

@implementation DisplayLinkTimer {
    CADisplayLink *_displayLink;
    void (^_timerHandler)(void);
}

- (instancetype)initWithTimerHandler:(void (^)(void))timerHandler {
    NSParameterAssert(timerHandler);
    if (self = [super init]) {
        _timerHandler = timerHandler;
        _displayLink =
        [CADisplayLink displayLinkWithTarget:self
                                    selector:@selector(displayLinkDidFire:)];
        _displayLink.paused = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_10_0
        _displayLink.preferredFramesPerSecond = 30;
#else
        [_displayLink setFrameInterval:2];
#endif
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)dealloc {
    [self invalidate];
}

- (BOOL)isPaused {
    return _displayLink.paused;
}

- (void)setIsPaused:(BOOL)isPaused {
    _displayLink.paused = isPaused;
}

- (void)invalidate {
    [_displayLink invalidate];
}

- (void)displayLinkDidFire:(CADisplayLink *)displayLink {
    _timerHandler();
}

@end
