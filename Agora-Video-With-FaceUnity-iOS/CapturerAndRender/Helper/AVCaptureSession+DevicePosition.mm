//
//  AVCaptureSession+DevicePosition.m
//  RtmpStreamingKit
//
//  Created by Zhang Ji on 2019/9/9.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import "AVCaptureSession+DevicePosition.h"

BOOL CFStringContainsString(CFStringRef theString, CFStringRef stringToFind) {
    return CFStringFindWithOptions(theString,
                                   stringToFind,
                                   CFRangeMake(0, CFStringGetLength(theString)),
                                   kCFCompareCaseInsensitive,
                                   nil);
}

@implementation AVCaptureSession (DevicePosition)

+ (AVCaptureDevicePosition)devicePositionForSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    // Check the image's EXIF for the camera the image came from.
    AVCaptureDevicePosition cameraPosition = AVCaptureDevicePositionUnspecified;
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(
                                                                kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    if (attachments) {
        int size = (int)CFDictionaryGetCount(attachments);
        if (size > 0) {
            CFDictionaryRef cfExifDictVal = nil;
            if (CFDictionaryGetValueIfPresent(
                                              attachments, (const void *)CFSTR("{Exif}"), (const void **)&cfExifDictVal)) {
                CFStringRef cfLensModelStrVal;
                if (CFDictionaryGetValueIfPresent(cfExifDictVal,
                                                  (const void *)CFSTR("LensModel"),
                                                  (const void **)&cfLensModelStrVal)) {
                    if (CFStringContainsString(cfLensModelStrVal, CFSTR("front"))) {
                        cameraPosition = AVCaptureDevicePositionFront;
                    } else if (CFStringContainsString(cfLensModelStrVal, CFSTR("back"))) {
                        cameraPosition = AVCaptureDevicePositionBack;
                    }
                }
            }
        }
        CFRelease(attachments);
    }
    return cameraPosition;
}

@end
