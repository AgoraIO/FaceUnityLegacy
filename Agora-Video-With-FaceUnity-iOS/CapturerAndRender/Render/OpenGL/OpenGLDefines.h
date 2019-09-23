//
//  OpenGLDefines.h
//  RtmpStreamingKit
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#ifndef OpenGLDefines_h
#define OpenGLDefines_h

#import <Foundation/Foundation.h>

#define PIXEL_FORMAT GL_LUMINANCE
#define SHADER_VERSION
#define VERTEX_SHADER_IN "attribute"
#define VERTEX_SHADER_OUT "varying"
#define FRAGMENT_SHADER_IN "varying"
#define FRAGMENT_SHADER_OUT
#define FRAGMENT_SHADER_COLOR "gl_FragColor"
#define FRAGMENT_SHADER_TEXTURE "texture2D"

@class EAGLContext;
typedef EAGLContext GlContextType;

#endif /* OpenGLDefines_h */
