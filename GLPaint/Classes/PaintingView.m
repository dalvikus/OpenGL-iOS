#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <GLKit/GLKit.h>

#import "Model.h"

#import "PaintingView.h"
#import "shaderUtil.h"
#import "fileUtil.h"
#import "debug.h"

//CONSTANTS:

#define kBrushOpacity       1//(1.0 / 3.0)
#define kBrushPixelStep     3
#define kBrushScale         1


#ifdef opengl
#define POLYGON
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
//#define EFFECT
enum
{
    UNIFORM_DIFFUSE_COLOR,
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS2
};
GLint uniforms[NUM_UNIFORMS2];

#ifdef NOT_USED
// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};
#endif

//GLfloat diffuseColor[] = {1.4f, 0.4f, 0.4f, 1.0f};
//GLfloat diffuseColor[] = {1.0f, 0.0f, 0.0f, 1.0f};
GLfloat diffuseColor[] = {0.4f, 0.4f, 1.0f, 1.0f};
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
obj_opengl sphere;
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
#endif
// Shaders
enum {
    PROGRAM_POINT,
    NUM_PROGRAMS
};

enum {
    UNIFORM_MVP,
    UNIFORM_POINT_SIZE,
    UNIFORM_VERTEX_COLOR,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};

enum {
    ATTRIB_VERTEX,
    NUM_ATTRIBS
};

typedef struct {
    char *vert, *frag;
    GLint uniform[NUM_UNIFORMS];
    GLuint id;
} programInfo_t;

programInfo_t program[NUM_PROGRAMS] = {
    { "point.vsh",   "point.fsh" },     // PROGRAM_POINT
};


// Texture
typedef struct {
    GLuint id;
    GLsizei width, height;
} textureInfo_t;


#ifdef opengl
#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#endif
@interface PaintingView()
{
    // The pixel dimensions of the backbuffer
    GLint backingWidth;
    GLint backingHeight;

    EAGLContext *context;

    // OpenGL names for the renderbuffer and framebuffers used to render to this view
    GLuint viewRenderbuffer, viewFramebuffer;

    // OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
    GLuint depthRenderbuffer;

    textureInfo_t brushTexture;     // brush texture
    GLfloat brushColor[4];          // brush color

    Boolean firstTouch;
    Boolean needsErase;

    // Shader objects
    GLuint vertexShader;
    GLuint fragmentShader;
    GLuint shaderProgram;

    // Buffer Objects
    GLuint vboId;

    BOOL initialized;
#ifdef opengl
    GLuint _program;

    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;

    GLuint _vertexArray;
    GLuint _vertexBuffer;

    GLuint _vertexArray2;
    GLuint _vertexBuffer2;
    GLKMatrix4 _modelViewProjectionMatrix2;
    GLKMatrix3 _normalMatrix2;

    Model* Sphere;
    Model* Chips;
#endif
}

#ifdef opengl
#ifdef EFFECT
@property (strong, nonatomic) GLKBaseEffect *effect;
#endif
- (void)update;
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
#endif
@end

@implementation PaintingView

@synthesize  location;
@synthesize  previousLocation;

// Implement this to override the default layer class (which is [CALayer class]).
// We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
+ (Class)layerClass
{
printf("layerClass\n");
    return [CAEAGLLayer class];
}

// The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
printf("initWithCoder\n");
    if ((self = [super initWithCoder:coder])) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;

        eaglLayer.opaque = YES;
        // In this application, we want to retain the EAGLDrawable contents after a call to presentRenderbuffer.
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];

        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

        if (!context || ![EAGLContext setCurrentContext:context]) {
            return nil;
        }

        // Set the view's scale factor as you wish
        self.contentScaleFactor = [[UIScreen mainScreen] scale];

        // Make sure to start with a cleared buffer
        needsErase = YES;
    }

    return self;
}

// If our view is resized, we'll be asked to layout subviews.
// This is the perfect opportunity to also update the framebuffer so that it is
// the same size as our display area.
-(void)layoutSubviews
{
printf("layoutSubviews\n");
    [EAGLContext setCurrentContext:context];

    if (!initialized) {
        initialized = [self initGL];
    }
    else {
        [self resizeFromLayer:(CAEAGLLayer*)self.layer];
    }

////#ifndef opengl
    // Clear the framebuffer the first time it is allocated
    if (needsErase) {
        [self erase];
        needsErase = NO;
    }
////#endif
}

- (void)setupShaders
{
    for (int i = 0; i < NUM_PROGRAMS; i++)
    {
        char *vsrc = readFile(pathForResource(program[i].vert));
        char *fsrc = readFile(pathForResource(program[i].frag));
        GLsizei attribCt = 0;
        GLchar *attribUsed[NUM_ATTRIBS];
        GLint attrib[NUM_ATTRIBS];
        GLchar *attribName[NUM_ATTRIBS] = {
            "inVertex",
        };
        const GLchar *uniformName[NUM_UNIFORMS] = {
            "MVP", "pointSize", "vertexColor", "texture",
        };

        // auto-assign known attribs
        for (int j = 0; j < NUM_ATTRIBS; j++)
        {
            if (strstr(vsrc, attribName[j]))
            {
                attrib[attribCt] = j;
                attribUsed[attribCt++] = attribName[j];
            }
        }

        glueCreateProgram(vsrc, fsrc,
                          attribCt, (const GLchar **)&attribUsed[0], attrib,
                          NUM_UNIFORMS, &uniformName[0], program[i].uniform,
                          &program[i].id);
        free(vsrc);
        free(fsrc);

        // Set constant/initalize uniforms
        if (i == PROGRAM_POINT)
        {
            glUseProgram(program[PROGRAM_POINT].id);

            // the brush texture will be bound to texture unit 0
            glUniform1i(program[PROGRAM_POINT].uniform[UNIFORM_TEXTURE], 0);

            // viewing matrices
            GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth, 0, backingHeight, -1, 1);
            GLKMatrix4 modelViewMatrix = GLKMatrix4Identity; // this sample uses a constant identity modelView matrix
            GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);

            glUniformMatrix4fv(program[PROGRAM_POINT].uniform[UNIFORM_MVP], 1, GL_FALSE, MVPMatrix.m);

            // point size
            glUniform1f(program[PROGRAM_POINT].uniform[UNIFORM_POINT_SIZE], brushTexture.width / kBrushScale);

            // initialize brush color
            glUniform4fv(program[PROGRAM_POINT].uniform[UNIFORM_VERTEX_COLOR], 1, brushColor);
        }
    }

    glError();
}

// Create a texture from an image
- (textureInfo_t)textureFromName:(NSString *)name
{
    CGImageRef      brushImage;
    CGContextRef    brushContext;
    GLubyte         *brushData;
    size_t          width, height;
    GLuint          texId;
    textureInfo_t   texture;

    // First create a UIImage object from the data in a image file, and then extract the Core Graphics image
    brushImage = [UIImage imageNamed:name].CGImage;

    // Get the width and height of the image
    width = CGImageGetWidth(brushImage);
    height = CGImageGetHeight(brushImage);
printf("%d x %d\n", width, height);

    // Make sure the image exists
    if(brushImage) {
        // Allocate  memory needed for the bitmap context
        brushData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
        // Use  the bitmatp creation function provided by the Core Graphics framework.
        brushContext = CGBitmapContextCreate(brushData, width, height, 8, width * 4, CGImageGetColorSpace(brushImage), kCGImageAlphaPremultipliedLast);
        // After you create the context, you can draw the  image to the context.
        CGContextDrawImage(brushContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), brushImage);
        // You don't need the context at this point, so you need to release it to avoid memory leaks.
        CGContextRelease(brushContext);
        // Use OpenGL ES to generate a name for the texture.
        glGenTextures(1, &texId);
        // Bind the texture name.
        glBindTexture(GL_TEXTURE_2D, texId);
        // Set the texture parameters to use a minifying filter and a linear filer (weighted average)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        // Specify a 2D texture image, providing the a pointer to the image data in memory
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, brushData);
        // Release  the image data; it's no longer needed
        free(brushData);

        texture.id = texId;
        texture.width = (int)width;
        texture.height = (int)height;
    }

    return texture;
}

- (BOOL)initGL
{
printf("initGL\n");
#ifdef opengl
#if 1
#else
    [EAGLContext setCurrentContext:context];
#endif

    [self loadShaders];

#ifdef EFFECT
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
#endif

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

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
    glGenVertexArraysOES(1, &_vertexArray2);
    glBindVertexArrayOES(_vertexArray2);
    glGenBuffers(1, &_vertexBuffer2);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer2);
    glBufferData(GL_ARRAY_BUFFER, sphere.vertex_count * sphere.TRIANGLE_VERTICES_DATA_STRIDE_BYTES, sphere.vertex_ptr, GL_STATIC_DRAW);
    free(sphere.vertex_ptr);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, COORDS_PER_POSITION, GL_FLOAT, GL_FALSE, sphere.TRIANGLE_VERTICES_DATA_STRIDE_BYTES, BUFFER_OFFSET(sphere.TRIANGLE_VERTICES_DATA_POS_OFFSET_BYTES));
    if (sphere.hasNormal) {
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, COORDS_PER_NORMAL, GL_FLOAT, GL_FALSE, sphere.TRIANGLE_VERTICES_DATA_STRIDE_BYTES, BUFFER_OFFSET(sphere.TRIANGLE_VERTICES_DATA_NORMAL_OFFSET_BYTES));
    }

    glBindVertexArrayOES(0);
#endif
    // Generate IDs for a framebuffer object and a color renderbuffer
    glGenFramebuffers(1, &viewFramebuffer);
    glGenRenderbuffers(1, &viewRenderbuffer);

    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    // This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
    // allowing us to draw into a buffer that will later be rendered to screen wherever the layer is (which corresponds with our view).
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderbuffer);

    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);

#ifdef opengl
    // For this sample, we do not need a depth buffer. If you do, this is how you can create one and attach it to the framebuffer:
      glGenRenderbuffers(1, &depthRenderbuffer);
      glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
      glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
      glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
#endif

    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }

    // Setup the view port in Pixels
    glViewport(0, 0, backingWidth, backingHeight);

////#ifndef opengl
    // Create a Vertex Buffer Object to hold our data
    glGenBuffers(1, &vboId);

    // Load the brush texture
    brushTexture = [self textureFromName:@"Particle.png"];

    // Load shaders
    [self setupShaders];

    // Enable blending and set a blending function appropriate for premultiplied alpha pixel data
//  glEnable(GL_BLEND);
//  glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

    // Playback recorded path, which is "Shake Me"
    NSMutableArray* recordedPaths = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Recording" ofType:@"data"]];
    if([recordedPaths count])
        [self performSelector:@selector(playback:) withObject:recordedPaths afterDelay:0.2];
////#endif

    return YES;
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{
printf("resizeFromLayer\n");
    // Allocate color buffer backing based on the current layer size
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);

    // For this sample, we do not need a depth buffer. If you do, this is how you can allocate depth buffer backing:
//    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
//    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Failed to make complete framebuffer objectz %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }

    // Update projection matrix
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth, 0, backingHeight, -1, 1);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity; // this sample uses a constant identity modelView matrix
    GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);

    glUseProgram(program[PROGRAM_POINT].id);
    glUniformMatrix4fv(program[PROGRAM_POINT].uniform[UNIFORM_MVP], 1, GL_FALSE, MVPMatrix.m);

    // Update viewport
    glViewport(0, 0, backingWidth, backingHeight);

    return YES;
}

// Releases resources when they are not longer needed.
- (void)dealloc
{
printf("dealloc\n");
    // Destroy framebuffers and renderbuffers
    if (viewFramebuffer) {
        glDeleteFramebuffers(1, &viewFramebuffer);
        viewFramebuffer = 0;
    }
    if (viewRenderbuffer) {
        glDeleteRenderbuffers(1, &viewRenderbuffer);
        viewRenderbuffer = 0;
    }
    if (depthRenderbuffer)
    {
        glDeleteRenderbuffers(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
    // texture
    if (brushTexture.id) {
        glDeleteTextures(1, &brushTexture.id);
        brushTexture.id = 0;
    }
    // vbo
    if (vboId) {
        glDeleteBuffers(1, &vboId);
        vboId = 0;
    }

    // tear down context
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
}

////#ifndef opengl
// Erases the screen
- (void)erase
{
printf("erase\n");
    [EAGLContext setCurrentContext:context];

    // Clear the buffer
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);

    // Display the buffer
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}
////#endif

// Drawings a line onscreen based on where the user touches
#if 0
#ifdef opengl
- (void)renderLineFromPoint
#else
- (void)renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end
#endif
#else
- (void)renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end
#endif
{
printf("renderLineFromPoint\n");
#if 0
//  glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClearColor(1.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
#else
#ifdef opengl
    [self update];
#if 1
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
//  glClearColor(0.0, 0.0, 0.0, 0.0);
//  glClearColor(diffuseColor[0], diffuseColor[1], diffuseColor[2], diffuseColor[3]);
//  glClearColor(1.0, 1.0, 1.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
#endif
#if 0
{
#if 0
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClearColor(diffuseColor[0], diffuseColor[1], diffuseColor[2], diffuseColor[3]);
    glClearColor(1.0, 1.0, 1.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
#endif
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glBindVertexArrayOES(_vertexArray);

    // Render the object with GLKit
#ifdef EFFECT
    [self.effect prepareToDraw];

    glDrawArrays(GL_TRIANGLES, 0, 36);
#endif

    glDisable(GL_BLEND);
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
if (gc_ptr->next_data_index > 0) {
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
#endif

#if 0
{
    glBindVertexArrayOES(_vertexArray2);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    // Render the object again with ES2
    glUseProgram(_program);

    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix2.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix2.m);
    glUniform4fv(uniforms[UNIFORM_DIFFUSE_COLOR], 1, diffuseColor);
    int face_offset = 0;
    container* gc_ptr = &sphere.gc;
    if (gc_ptr->next_data_index > 0) {
        int n_color_interval = (I27 - (1 + 1)) / gc_ptr->next_data_index;    // skip black, white
        for (int i = 0; i < gc_ptr->next_data_index; ++i) {
            group* group_ptr = (group*) gc_ptr->data_ptr + i;
            glUniform4fv(uniforms[UNIFORM_DIFFUSE_COLOR], 1, COLOR_A[1 + i * n_color_interval]);    // skip black
            glDrawElements(GL_TRIANGLES,
                (group_ptr->nf - face_offset) * N_VERETX_PER_TRIANGLE,
                GL_UNSIGNED_INT,
                sphere.index_ptr + face_offset * N_VERETX_PER_TRIANGLE
            );
            face_offset = group_ptr->nf;
        }
    }
}
#endif
    [Chips
        renderWith:^() {
            glDisable(GL_BLEND);
        }
    ];
    [Sphere
        renderWith:^() {
            glEnable(GL_BLEND);
            glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        }
    ];
    glBindVertexArrayOES(0);
#endif
////#else
    static GLfloat*     vertexBuffer = NULL;
    static NSUInteger   vertexMax = 64;
    NSUInteger          vertexCount = 0,
                        count,
                        i;

    [EAGLContext setCurrentContext:context];
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);

    // Convert locations from Points to Pixels
    CGFloat scale = self.contentScaleFactor;
    start.x *= scale;
    start.y *= scale;
    end.x *= scale;
    end.y *= scale;

    // Allocate vertex array buffer
    if(vertexBuffer == NULL)
        vertexBuffer = malloc(vertexMax * 2 * sizeof(GLfloat));

    // Add points to the buffer so there are drawing points every X pixels
    count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / kBrushPixelStep), 1);
    for(i = 0; i < count; ++i) {
        if(vertexCount == vertexMax) {
            vertexMax = 2 * vertexMax;
            vertexBuffer = realloc(vertexBuffer, vertexMax * 2 * sizeof(GLfloat));
        }

        vertexBuffer[2 * vertexCount + 0] = start.x + (end.x - start.x) * ((GLfloat)i / (GLfloat)count);
        vertexBuffer[2 * vertexCount + 1] = start.y + (end.y - start.y) * ((GLfloat)i / (GLfloat)count);
        vertexCount += 1;
    }

    // Load data to the Vertex Buffer Object
    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    glBufferData(GL_ARRAY_BUFFER, vertexCount*2*sizeof(GLfloat), vertexBuffer, GL_DYNAMIC_DRAW);

    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, 0);

//  glEnable(GL_BLEND);
//  glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    // Draw
    glUseProgram(program[PROGRAM_POINT].id);
    glDrawArrays(GL_POINTS, 0, (int)vertexCount);
////#endif
#endif

    // Display the buffer
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

// Reads previously recorded points and draws them onscreen. This is the Shake Me message that appears when the application launches.
- (void)playback:(NSMutableArray*)recordedPaths
{
printf("playback\n");
    // NOTE: Recording.data is stored with 32-bit floats
    // To make it work on both 32-bit and 64-bit devices, we make sure we read back 32 bits each time.

    Float32 x[1], y[1];
    CGPoint point1, point2;

    NSData*             data = [recordedPaths objectAtIndex:0];
    NSUInteger          count = [data length] / (sizeof(Float32)*2), // each point contains 64 bits (32-bit x and 32-bit y)
                        i;

    // Render the current path
    for(i = 0; i < count - 1; i++) {

        [data getBytes:&x range:NSMakeRange(8*i, sizeof(Float32))]; // read 32 bits each time
        [data getBytes:&y range:NSMakeRange(8*i+sizeof(Float32), sizeof(Float32))];
        point1 = CGPointMake(x[0], y[0]);

        [data getBytes:&x range:NSMakeRange(8*(i+1), sizeof(Float32))];
        [data getBytes:&y range:NSMakeRange(8*(i+1)+sizeof(Float32), sizeof(Float32))];
        point2 = CGPointMake(x[0], y[0]);

#if 0
#ifdef opengl
        [self renderLineFromPoint];
#else
        [self renderLineFromPoint:point1 toPoint:point2];
#endif
#else
        [self renderLineFromPoint:point1 toPoint:point2];
#endif
    }

    // Render the next path after a short delay
    [recordedPaths removeObjectAtIndex:0];
    if([recordedPaths count])
        [self performSelector:@selector(playback:) withObject:recordedPaths afterDelay:0.01];
}


// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
printf("touchesBegan\n");
    CGRect              bounds = [self bounds];
    UITouch*            touch = [[event touchesForView:self] anyObject];
    firstTouch = YES;
    // Convert touch point from UIView referential to OpenGL one (upside-down flip)
    location = [touch locationInView:self];
    location.y = bounds.size.height - location.y;
}

// Handles the continuation of a touch.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
printf("touchesMoved\n");
    CGRect              bounds = [self bounds];
    UITouch*            touch = [[event touchesForView:self] anyObject];

    // Convert touch point from UIView referential to OpenGL one (upside-down flip)
    if (firstTouch) {
        firstTouch = NO;
        previousLocation = [touch previousLocationInView:self];
        previousLocation.y = bounds.size.height - previousLocation.y;
    } else {
        location = [touch locationInView:self];
        location.y = bounds.size.height - location.y;
        previousLocation = [touch previousLocationInView:self];
        previousLocation.y = bounds.size.height - previousLocation.y;
    }

    // Render the stroke
#if 0
#ifdef opengl
    [self renderLineFromPoint];
#else
    [self renderLineFromPoint:previousLocation toPoint:location];
#endif
#else
    [self renderLineFromPoint:previousLocation toPoint:location];
#endif
}

// Handles the end of a touch event when the touch is a tap.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
printf("touchesEnded\n");
    CGRect              bounds = [self bounds];
    UITouch*            touch = [[event touchesForView:self] anyObject];
    if (firstTouch) {
        firstTouch = NO;
        previousLocation = [touch previousLocationInView:self];
        previousLocation.y = bounds.size.height - previousLocation.y;
#if 0
#ifdef opengl
        [self renderLineFromPoint];
#else
        [self renderLineFromPoint:previousLocation toPoint:location];
#endif
#else
        [self renderLineFromPoint:previousLocation toPoint:location];
#endif
    }
}

// Handles the end of a touch event.
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
printf("touchesCancelled\n");
    // If appropriate, add code necessary to save the state of the application.
    // This application is not saving state.
}

- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
printf("setBrushColorWithRed\n");
    // Update the brush color
    brushColor[0] = red * kBrushOpacity;
    brushColor[1] = green * kBrushOpacity;
    brushColor[2] = blue * kBrushOpacity;
    brushColor[3] = kBrushOpacity;
#ifdef opengl
for (int i = 0; i < 4; ++i)
    diffuseColor[i] = brushColor[i];
diffuseColor[0] = red;
diffuseColor[1] = green;
diffuseColor[2] = blue;
diffuseColor[3] = 1.0f;
/*
diffuseColor[0] = 1.0f;
diffuseColor[1] = 0.0f;
diffuseColor[2] = 0.0f;
diffuseColor[3] = 1.0f;
 */
#endif

printf("initialized? %s\n", initialized ? "True" : "False");
#if 0
#ifdef opengl
    if (!initialized) {
        initialized = [self initGL];
    }
    if (initialized) {
        [self renderLineFromPoint];
    }
#else
    if (initialized) {
        glUseProgram(program[PROGRAM_POINT].id);
        glUniform4fv(program[PROGRAM_POINT].uniform[UNIFORM_VERTEX_COLOR], 1, brushColor);
    }
#endif
#else
#ifdef opengl
    if (!initialized) {
        initialized = [self initGL];
    }
#endif
    if (initialized) {
        glUseProgram(program[PROGRAM_POINT].id);
        glUniform4fv(program[PROGRAM_POINT].uniform[UNIFORM_VERTEX_COLOR], 1, brushColor);
    }
#endif
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}

#ifdef opengl
- (void)update
{
#if 1
    CGRect rect = [[UIScreen mainScreen] bounds];
//  printf("%f, %f\n", rect.size.width, rect.size.height);
    float aspect = fabsf(rect.size.width / rect.size.height);
#else
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
#endif
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);

#ifdef EFFECT
    self.effect.transform.projectionMatrix = projectionMatrix;
#endif

    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);

    // Compute the model view matrix for the object rendered with GLKit
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);

#ifdef EFFECT
    self.effect.transform.modelviewMatrix = modelViewMatrix;
#endif

    // Compute the model view matrix for the object rendered with ES2
//  modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 1.5f);
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    [Chips setMVPMatrix:_modelViewProjectionMatrix normalMatrix:_normalMatrix];

    modelViewMatrix = GLKMatrix4MakeScale(1.0f, 2.0f, 3.0f);
//  modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    _normalMatrix2 = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    _modelViewProjectionMatrix2 = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);

    [Sphere setMVPMatrix:_modelViewProjectionMatrix2 normalMatrix:_normalMatrix2];
#if 1
    _rotation += 1.0f * (3.1415926535897932384f / 180);
#else
    _rotation += self.timeSinceLastUpdate * 0.5f;
#endif
}
- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;

    // Create shader program.
    _program = glCreateProgram();

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
#ifdef POLYGON
    NSString *objPathname = [[NSBundle mainBundle] pathForResource:@"Chips3" ofType:@"obj"];
    parseObj([objPathname UTF8String], &polygon);
    Chips = [[Model alloc] initWith:objPathname use:_program modelViewProjectionMatrixIndex:uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] normalMatrixIndex:uniforms[UNIFORM_NORMAL_MATRIX] colorIndex:uniforms[UNIFORM_DIFFUSE_COLOR]];
    objPathname = [[NSBundle mainBundle] pathForResource:@"Sphere" ofType:@"obj"];
    parseObj([objPathname UTF8String], &sphere);
    Sphere = [[Model alloc] initWith:objPathname use:_program modelViewProjectionMatrixIndex:uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] normalMatrixIndex:uniforms[UNIFORM_NORMAL_MATRIX] colorIndex:uniforms[UNIFORM_DIFFUSE_COLOR]];
#endif
/*
    container* gc_ptr = &polygon.gc;
    for (int i = 0; i < gc_ptr->next_data_index; ++i) {
        group* group_ptr = (group*) gc_ptr->data_ptr + i;
        printf("group: |%s|\n", group_ptr->name_ptr);
        printf("# of faces = %d\n", group_ptr->nf);
    }
 */


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
#endif
@end
