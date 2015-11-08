//
//  DNViewController.m
//  opengl
//
//  Created by Gwang-Ho KIM on 11/1/15.
//  Copyright (c) 2015 DN2Soft. All rights reserved.
//
/*
        POLYGON     ALL_IN_ONE  (PART)
        SQUARE      DRAW_ARRAYS (DRAW_ELEMENTS)
        CUBE
 */
//#define POLYGON
////#define SQUARE

#ifdef POLYGON
////#define ALL_IN_ONE
#endif

#ifdef SQUARE
////#define DRAW_ARRAYS
#endif


#ifdef POLYGON
#include "obj.h"
#endif
#import "DNViewController.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_DIFFUSE_COLOR,
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

//GLfloat diffuseColor[] = {0.4f, 0.4f, 1.0f, 1.0f};
//GLfloat diffuseColor[] = {1.4f, 0.4f, 0.4f, 1.0f};
GLfloat diffuseColor[] = {1.0f, 0.0f, 0.0f, 1.0f};
#ifdef SQUARE
#ifdef DRAW_ARRAYS
GLfloat gSqureVertexData[1 * 6 * 6] =       // 1: side, 6: vertex, 6: float
{
     0.5f,  0.5f,  0.5f,     0.0f,  0.0f,  1.0f,    // A: top right
    -0.5f,  0.5f,  0.5f,     0.0f,  0.0f,  1.0f,    // B: top left
     0.5f, -0.5f,  0.5f,     0.0f,  0.0f,  1.0f,    // D: bottom right
     0.5f, -0.5f,  0.5f,     0.0f,  0.0f,  1.0f,    // D: bottom right
    -0.5f,  0.5f,  0.5f,     0.0f,  0.0f,  1.0f,    // B: top left
    -0.5f, -0.5f,  0.5f,     0.0f,  0.0f,  1.0f,    // C: bottom left
};
#else
GLfloat gSqureVertexData4index[1 * 4 * 6] = // 1: side, 4: vertex, 6: float
{
     0.5f,  0.5f,  0.5f,     0.0f,  0.0f,  1.0f,    // A: top right
    -0.5f,  0.5f,  0.5f,     0.0f,  0.0f,  1.0f,    // B: top left
    -0.5f, -0.5f,  0.5f,     0.0f,  0.0f,  1.0f,    // C: bottom left
     0.5f, -0.5f,  0.5f,     0.0f,  0.0f,  1.0f,    // D: bottom right
};
GLuint gSqureDrawOrder[2 * 3] = // 2: triangle, 3: vertex
{
    0, 1, 3,
    3, 1, 2,
};
#endif  // !DRAW_ARRAYS (DRAW_ELEMENTS)
#else
#ifdef POLYGON  // by DRAW_ELEMENTS
#define I27 27
#define F3 (1.0f / 2)
#define ALPHA 1.0f
GLfloat COLOR_A[][4] = {
    {0 * F3, 0 * F3, 0 * F3, ALPHA},
    {0 * F3, 0 * F3, 1 * F3, ALPHA},
    {0 * F3, 0 * F3, 2 * F3, ALPHA},
    {0 * F3, 1 * F3, 0 * F3, ALPHA},
    {0 * F3, 1 * F3, 1 * F3, ALPHA},
    {0 * F3, 1 * F3, 2 * F3, ALPHA},
    {0 * F3, 2 * F3, 0 * F3, ALPHA},
    {0 * F3, 2 * F3, 1 * F3, ALPHA},
    {0 * F3, 2 * F3, 2 * F3, ALPHA},
    {1 * F3, 0 * F3, 0 * F3, ALPHA},
    {1 * F3, 0 * F3, 1 * F3, ALPHA},
    {1 * F3, 0 * F3, 2 * F3, ALPHA},
    {1 * F3, 1 * F3, 0 * F3, ALPHA},
    {1 * F3, 1 * F3, 1 * F3, ALPHA},
    {1 * F3, 1 * F3, 2 * F3, ALPHA},
    {1 * F3, 2 * F3, 0 * F3, ALPHA},
    {1 * F3, 2 * F3, 1 * F3, ALPHA},
    {1 * F3, 2 * F3, 2 * F3, ALPHA},
    {2 * F3, 0 * F3, 0 * F3, ALPHA},
    {2 * F3, 0 * F3, 1 * F3, ALPHA},
    {2 * F3, 0 * F3, 2 * F3, ALPHA},
    {2 * F3, 1 * F3, 0 * F3, ALPHA},
    {2 * F3, 1 * F3, 1 * F3, ALPHA},
    {2 * F3, 1 * F3, 2 * F3, ALPHA},
    {2 * F3, 2 * F3, 0 * F3, ALPHA},
    {2 * F3, 2 * F3, 1 * F3, ALPHA},
    {2 * F3, 2 * F3, 2 * F3, ALPHA},
};
obj_opengl polygon;
#else   // by DRAW_ARRAYS
/*
...
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
...
says

    B     A
    +-----+
    | \   |
    |   \ |
    +-----+
    C     D

ABD, DBC
 */

GLfloat gCubeVertexData[216] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
     0.5f, -0.5f, -0.5f,     1.0f,  0.0f,  0.0f,
     0.5f,  0.5f, -0.5f,     1.0f,  0.0f,  0.0f,
     0.5f, -0.5f,  0.5f,     1.0f,  0.0f,  0.0f,
     0.5f, -0.5f,  0.5f,     1.0f,  0.0f,  0.0f,
     0.5f,  0.5f, -0.5f,     1.0f,  0.0f,  0.0f,
     0.5f,  0.5f,  0.5f,     1.0f,  0.0f,  0.0f,

     0.5f,  0.5f, -0.5f,     0.0f,  1.0f,  0.0f,
    -0.5f,  0.5f, -0.5f,     0.0f,  1.0f,  0.0f,
     0.5f,  0.5f,  0.5f,     0.0f,  1.0f,  0.0f,
     0.5f,  0.5f,  0.5f,     0.0f,  1.0f,  0.0f,
    -0.5f,  0.5f, -0.5f,     0.0f,  1.0f,  0.0f,
    -0.5f,  0.5f,  0.5f,     0.0f,  1.0f,  0.0f,

    -0.5f,  0.5f, -0.5f,    -1.0f,  0.0f,  0.0f,
    -0.5f, -0.5f, -0.5f,    -1.0f,  0.0f,  0.0f,
    -0.5f,  0.5f,  0.5f,    -1.0f,  0.0f,  0.0f,
    -0.5f,  0.5f,  0.5f,    -1.0f,  0.0f,  0.0f,
    -0.5f, -0.5f, -0.5f,    -1.0f,  0.0f,  0.0f,
    -0.5f, -0.5f,  0.5f,    -1.0f,  0.0f,  0.0f,

    -0.5f, -0.5f, -0.5f,     0.0f, -1.0f,  0.0f,
     0.5f, -0.5f, -0.5f,     0.0f, -1.0f,  0.0f,
    -0.5f, -0.5f,  0.5f,     0.0f, -1.0f,  0.0f,
    -0.5f, -0.5f,  0.5f,     0.0f, -1.0f,  0.0f,
     0.5f, -0.5f, -0.5f,     0.0f, -1.0f,  0.0f,
     0.5f, -0.5f,  0.5f,     0.0f, -1.0f,  0.0f,

     0.5f,  0.5f,  0.5f,     0.0f,  0.0f,  1.0f,
    -0.5f,  0.5f,  0.5f,     0.0f,  0.0f,  1.0f,
     0.5f, -0.5f,  0.5f,     0.0f,  0.0f,  1.0f,
     0.5f, -0.5f,  0.5f,     0.0f,  0.0f,  1.0f,
    -0.5f,  0.5f,  0.5f,     0.0f,  0.0f,  1.0f,
    -0.5f, -0.5f,  0.5f,     0.0f,  0.0f,  1.0f,

     0.5f, -0.5f, -0.5f,     0.0f,  0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,     0.0f,  0.0f, -1.0f,
     0.5f,  0.5f, -0.5f,     0.0f,  0.0f, -1.0f,
     0.5f,  0.5f, -0.5f,     0.0f,  0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,     0.0f,  0.0f, -1.0f,
    -0.5f,  0.5f, -0.5f,     0.0f,  0.0f, -1.0f,
};
#endif  // CUBE
#endif  // !SQUARE (POLYGON || CUBE)

@interface DNViewController () {
    GLuint _program;

    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;

    GLuint _vertexArray;
    GLuint _vertexBuffer;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation DNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }

    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;

    [self setupGL];
}

- (void)dealloc
{
    [self tearDownGL];

    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;

        [self tearDownGL];

        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];

    [self loadShaders];

    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);

    glEnable(GL_DEPTH_TEST);

    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);

    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
#ifdef POLYGON
    glBufferData(GL_ARRAY_BUFFER, polygon.vertex_count * polygon.TRIANGLE_VERTICES_DATA_STRIDE_BYTES, polygon.vertex_ptr, GL_STATIC_DRAW);
    free(polygon.vertex_ptr);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, COORDS_PER_POSITION, GL_FLOAT, GL_FALSE, polygon.TRIANGLE_VERTICES_DATA_STRIDE_BYTES, BUFFER_OFFSET(polygon.TRIANGLE_VERTICES_DATA_POS_OFFSET_BYTES));
    if (polygon.hasNormal) {
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, COORDS_PER_NORMAL, GL_FLOAT, GL_FALSE, polygon.TRIANGLE_VERTICES_DATA_STRIDE_BYTES, BUFFER_OFFSET(polygon.TRIANGLE_VERTICES_DATA_NORMAL_OFFSET_BYTES));
    }
#else
#ifdef SQUARE
#ifdef DRAW_ARRAYS
    glBufferData(GL_ARRAY_BUFFER, sizeof(gSqureVertexData), gSqureVertexData, GL_STATIC_DRAW);
#else
    glBufferData(GL_ARRAY_BUFFER, sizeof(gSqureVertexData4index), gSqureVertexData4index, GL_STATIC_DRAW);
#endif
#else   // CUBE
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
#endif
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
#endif

    glBindVertexArrayOES(0);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];

    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);

    self.effect = nil;

    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);

    self.effect.transform.projectionMatrix = projectionMatrix;

    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);

    // Compute the model view matrix for the object rendered with GLKit
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);

    self.effect.transform.modelviewMatrix = modelViewMatrix;

    // Compute the model view matrix for the object rendered with ES2
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);

    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);

    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);

    _rotation += self.timeSinceLastUpdate * 0.5f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glBindVertexArrayOES(_vertexArray);

    // Render the object with GLKit
/*
    [self.effect prepareToDraw];

    glDrawArrays(GL_TRIANGLES, 0, 36);
 */

    // Render the object again with ES2
    glUseProgram(_program);

    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    glUniform4fv(uniforms[UNIFORM_DIFFUSE_COLOR], 1, diffuseColor);
#ifdef POLYGON
#ifdef ALL_IN_ONE
    glDrawElements(GL_TRIANGLES, polygon.triangle_count * N_VERETX_PER_TRIANGLE, GL_UNSIGNED_INT, polygon.index_ptr);
#else
    int face_offset = 0;
    container* gc_ptr = &polygon.gc;
    int n_color_interval = (I27 - (1 + 1)) / gc_ptr->next_data_index;    // skip black, white
    for (int i = 0; i < gc_ptr->next_data_index; ++i) {
        group* group_ptr = (group*) gc_ptr->data_ptr + i;
        glUniform4fv(uniforms[UNIFORM_DIFFUSE_COLOR], 1, COLOR_A[1 + i * n_color_interval]);    // skip black
        glDrawElements(GL_TRIANGLES,
            (group_ptr->nf - face_offset) * N_VERETX_PER_TRIANGLE,
            GL_UNSIGNED_INT,
            polygon.index_ptr + face_offset * N_VERETX_PER_TRIANGLE
        );
        face_offset = group_ptr->nf;
    }
#endif
#else
#ifdef SQUARE
#ifdef DRAW_ARRAYS
    glDrawArrays(GL_TRIANGLES, 0, 6);
#else
    glDrawElements(GL_TRIANGLES, 2 * 3, GL_UNSIGNED_INT, gSqureDrawOrder);
#endif
#else
    glDrawArrays(GL_TRIANGLES, 0, 36);
#endif
#endif
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;

    // Create shader program.
    _program = glCreateProgram();

#ifdef POLYGON
    NSString *objPathname = [[NSBundle mainBundle] pathForResource:@"Chips3" ofType:@"obj"];
    NSLog(@"%@", objPathname);
    parseObj([objPathname UTF8String], &polygon);
#endif
/*
    container* gc_ptr = &polygon.gc;
    for (int i = 0; i < gc_ptr->next_data_index; ++i) {
        group* group_ptr = (group*) gc_ptr->data_ptr + i;
        printf("group: |%s|\n", group_ptr->name_ptr);
        printf("# of faces = %d\n", group_ptr->nf);
    }
 */

    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }

    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }

    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);

    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);

    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");

    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);

        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }

        return NO;
    }

    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_DIFFUSE_COLOR] = glGetUniformLocation(_program, "diffuseColor");

    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }

    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;

    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }

    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);

#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif

    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }

    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);

#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif

    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }

    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;

    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }

    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }

    return YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
NSLog(@"%@", touch);
/*
    CGPoint location = [touch locationInView:self.view];    
    CGPoint lastLoc = [touch previousLocationInView:self.view];
    CGPoint diff = CGPointMake(lastLoc.x - location.x, lastLoc.y - location.y);
    float rotX = -1 * GLKMathDegreesToRadians(diff.y / 2.0);
    float rotY = -1 * GLKMathDegreesToRadians(diff.x / 2.0);
    GLKVector3 xAxis = GLKVector3Make(1, 0, 0);
    _rotMatrix = GLKMatrix4Rotate(_rotMatrix, rotX, xAxis.x, xAxis.y, xAxis.z);
    GLKVector3 yAxis = GLKVector3Make(0, 1, 0);
    _rotMatrix = GLKMatrix4Rotate(_rotMatrix, rotY, yAxis.x, yAxis.y, yAxis.z);
 */
}

@end
