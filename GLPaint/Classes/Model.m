#import "Model.h"
#include "obj.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

#define I27 27
#define F3 (1.0f / 2)
#define ALPHA 1.0f
static GLfloat COLOR_A[][4] = {
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

@interface Model()
{
    BOOL loaded;

    GLuint program;

    GLKMatrix4 modelViewProjectionMatrix;
    GLKMatrix3 normalMatrix;
    GLuint vertexArray;
    GLuint vertexBuffer;

    GLint modelViewProjectionMatrixIndex;
    GLint normalMatrixIndex;
    GLint colorIndex;
    obj_opengl polygon;
}
@end

@implementation Model

- (instancetype)initWith:(NSString *)objPathname use:(GLuint)theProgram modelViewProjectionMatrixIndex:(GLint)theModelViewProjectionMatrixIndex normalMatrixIndex:(GLint)theNormalMatrixIndex colorIndex:(GLint)theColorIndex
{
    self = [super init];
    if (self) {
        program = theProgram;
        modelViewProjectionMatrixIndex = theModelViewProjectionMatrixIndex;
        normalMatrixIndex = theNormalMatrixIndex;
        colorIndex = theColorIndex;

        void* p = parseObj([objPathname UTF8String], &polygon);
        loaded = p != NULL;
        if (loaded) {
            glGenVertexArraysOES(1, &vertexArray);
            glBindVertexArrayOES(vertexArray);
            glGenBuffers(1, &vertexBuffer);
            glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
            glBufferData(GL_ARRAY_BUFFER, polygon.vertex_count * polygon.TRIANGLE_VERTICES_DATA_STRIDE_BYTES, polygon.vertex_ptr, GL_STATIC_DRAW);
            free(polygon.vertex_ptr);
            glEnableVertexAttribArray(GLKVertexAttribPosition);
            glVertexAttribPointer(GLKVertexAttribPosition, COORDS_PER_POSITION, GL_FLOAT, GL_FALSE, polygon.TRIANGLE_VERTICES_DATA_STRIDE_BYTES, BUFFER_OFFSET(polygon.TRIANGLE_VERTICES_DATA_POS_OFFSET_BYTES));
            if (polygon.hasNormal) {
                glEnableVertexAttribArray(GLKVertexAttribNormal);
                glVertexAttribPointer(GLKVertexAttribNormal, COORDS_PER_NORMAL, GL_FLOAT, GL_FALSE, polygon.TRIANGLE_VERTICES_DATA_STRIDE_BYTES, BUFFER_OFFSET(polygon.TRIANGLE_VERTICES_DATA_NORMAL_OFFSET_BYTES));
            }
        }
    }
    return self;
}

- (void)setMVPMatrix:(GLKMatrix4)theModelViewProjectionMatrix normalMatrix:(GLKMatrix3)theNormalMatrix
{
    modelViewProjectionMatrix = theModelViewProjectionMatrix;
    normalMatrix = theNormalMatrix;
}

- (void)renderWith:(GLBlock)glBlock
{
    if (!loaded)
        return;

    glBindVertexArrayOES(vertexArray);
    if (glBlock != nil)
        glBlock();

    glBindVertexArrayOES(vertexArray);
    glUseProgram(program);
    glUniformMatrix4fv(modelViewProjectionMatrixIndex, 1, 0, modelViewProjectionMatrix.m);
    glUniformMatrix3fv(normalMatrixIndex, 1, 0, normalMatrix.m);
    int face_offset = 0;
    if (polygon.gc.next_data_index > 0) {
        int n_color_interval = (I27 - (1 + 1)) / polygon.gc.next_data_index;    // skip black, white
        for (int i = 0; i < polygon.gc.next_data_index; ++i) {
            group* group_ptr = (group*) polygon.gc.data_ptr + i;
            glUniform4fv(colorIndex, 1, COLOR_A[1 + i * n_color_interval]);    // skip black
            glDrawElements(GL_TRIANGLES,
                (group_ptr->nf - face_offset) * N_VERETX_PER_TRIANGLE,
                GL_UNSIGNED_INT,
                polygon.index_ptr + face_offset * N_VERETX_PER_TRIANGLE
            );
            face_offset = group_ptr->nf;
        }
    }
    glBindVertexArrayOES(0);
}

- (void)free
{
    free(polygon.index_ptr);
    free(polygon.gc.data_ptr);
}

@end
