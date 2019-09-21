//
//  CustomCVPixelBuffer.h
//  TestProject
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoFrameBuffer.h"

NS_ASSUME_NONNULL_BEGIN

@interface CustomCVPixelBuffer : NSObject <VideoFrameBuffer>

@property(nonatomic, readonly) CVPixelBufferRef pixelBuffer;
@property(nonatomic, readonly) int cropX;
@property(nonatomic, readonly) int cropY;
@property(nonatomic, readonly) int cropWidth;
@property(nonatomic, readonly) int cropHeight;

+ (NSSet<NSNumber *> *)supportedPixelFormats;

- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer
                       adaptedWidth:(int)adaptedWidth
                      adaptedHeight:(int)adaptedHeight
                          cropWidth:(int)cropWidth
                         cropHeight:(int)cropHeight
                              cropX:(int)cropX
                              cropY:(int)cropY;

- (BOOL)requiresCropping;
- (BOOL)requiresScalingToWidth:(int)width height:(int)height;
- (int)bufferSizeForCroppingAndScalingToWidth:(int)width height:(int)height;

/** The minimum size of the |tmpBuffer| must be the number of bytes returned from the
 * bufferSizeForCroppingAndScalingToWidth:height: method.
 * If that size is 0, the |tmpBuffer| may be nil.
 */
- (BOOL)cropAndScaleTo:(CVPixelBufferRef)outputPixelBuffer
        withTempBuffer:(nullable uint8_t *)tmpBuffer;


@end

NS_ASSUME_NONNULL_END
