//
//  AVCaptureSession+DevicePosition.h
//  RtmpStreamingKit
//
//  Created by Zhang Ji on 2019/9/9.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVCaptureSession (DevicePosition)

// Check the image's EXIF for the camera the image came from.
+ (AVCaptureDevicePosition)devicePositionForSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

NS_ASSUME_NONNULL_END
