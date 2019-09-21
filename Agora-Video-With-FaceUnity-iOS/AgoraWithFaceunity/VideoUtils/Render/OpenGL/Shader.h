//
//  Shader.h
//  TestProject
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import "VideoFrame.h"

NS_ASSUME_NONNULL_BEGIN

@interface Shader : NSObject

extern const char kVertexShaderSource[];

extern GLuint CreateShader(GLenum type, const GLchar* source);
extern GLuint CreateProgram(GLuint vertexShader, GLuint fragmentShader);
extern GLuint CreateProgramFromFragmentSource(const char fragmentShaderSource[_Nonnull]);
extern BOOL CreateVertexBuffer(GLuint* vertexBuffer, GLuint* vertexArray);
extern void SetVertexData(VideoRotation rotation, BOOL mirrored, GLuint model, GLfloat widthAspito, GLfloat heightAspito);
//extern void SetVertexData(VideoRotation rotation);


@end

NS_ASSUME_NONNULL_END
