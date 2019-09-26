//
//  RenderManager.m
//  CapturerAndRender
//
//  Created by Zhang Ji on 2019/9/24.
//  Copyright © 2019 ZhangJi. All rights reserved.
//

#import "RenderManager.h"
#import "CapturerManager.h"
#import "Connector.h"

@interface RenderManager() <Connector>

@end

@implementation RenderManager

@synthesize view = _view;

- (instancetype)initWithConnector:(nullable id<Connector>)connector {
    if (self = [super init]) {
        self.connector = connector;
    }
    return self;
}

- (instancetype)initWithView:(GLRenderView*)view
                   connector:(nullable id<Connector>)connector {
    if (self = [super init]) {
        self.connector = connector;
        self.view = view;
    }
    return self;
}

- (void)setRenderModel:(RenderModel)renderModel {
    self.renderModel = renderModel;
    [self.view setRenderModel:renderModel];
}

- (void)setMirrorModel:(MirrorModel)mirrorModel {
    self.mirrorModel = mirrorModel;
    [self.view setMirrorModel:mirrorModel];
}

- (void)didOutputFrame:(VideoFrame *)frame {
    if (self.view) {
        [self.view renderFrame:frame];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.connector respondsToSelector:@selector(didOutputFrame:)]) {
            [self.connector didOutputFrame:frame];
        }
    });
}

//- (void)didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer withTimeStamp:(CMTime)timeStamp rotation:(VideoRotation)rotation {
//    if ([self.connector respondsToSelector:@selector(didOutputPixelBuffer:withTimeStamp:rotation:)]) {
//        [self.connector didOutputPixelBuffer:pixelBuffer withTimeStamp:timeStamp rotation:rotation];
//    }
//}
@end
