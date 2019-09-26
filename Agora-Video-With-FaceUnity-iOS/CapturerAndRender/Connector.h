//
//  Connector.h
//  AgoraWithFaceunity
//
//  Created by Zhang Ji on 2019/9/25.
//  Copyright © 2019 ZhangJi. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
//#import "CameraVideoCapturer.h"
#import "VideoFrame.h"

#ifndef Connector_h
#define Connector_h

@protocol Connector <NSObject>
@optional

- (void)didOutputFrame: (VideoFrame*)frame;

//- (void)didOutputPixelBuffer: (CVPixelBufferRef)pixelBuffer withTimeStamp:(CMTime)timeStamp rotation:(VideoRotation) rotation;

@end


#endif /* Connector_h */
