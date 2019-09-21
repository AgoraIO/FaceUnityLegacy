//
//  VideoCapturer.m
//  TestProject
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import "VideoCapturer.h"

@implementation VideoCapturer

@synthesize delegate = _delegate;

- (instancetype)initWithDelegate:(id<VideoCapturerDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

@end
