//
//  VideoCapturer.h
//  TestProject
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoFrame.h"

NS_ASSUME_NONNULL_BEGIN

@class VideoCapturer;

@protocol VideoCapturerDelegate <NSObject>

-(void)capturer: (VideoCapturer *)capturer didCaptureFrame: (VideoFrame*)frame;

@end

@interface VideoCapturer : NSObject

@property(nonatomic, weak) id<VideoCapturerDelegate> delegate;

- (instancetype)initWithDelegate:(id<VideoCapturerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
