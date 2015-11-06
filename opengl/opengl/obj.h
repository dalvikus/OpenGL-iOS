#ifndef _OBJ
#define _OBJ
#if 1   // obj.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <math.h>   // NAM, INFINITY
#ifndef BOOL
#define BOOL int
#define true 1
#define false 0
#endif
#endif
float parseFloat(char* s);
#define isNAN(f)    (f != f)

typedef struct
{
    int next_data_index;
    size_t  len;    // capacity of container
    void* data_ptr;
} container;
void init_container(container* c_ptr);
void free_container(container* c_ptr);
void make_container_compact(container* c_ptr, size_t data_size);

#define N_VERETX_PER_TRIANGLE   3
#define FLOAT_SIZE_BYTES        sizeof(float)
#define COORDS_PER_POSITION 3
#define COORDS_PER_UV       2
#define COORDS_PER_NORMAL   3
typedef struct
{
    int TRIANGLE_VERTICES_DATA_STRIDE_BYTES; // (3 + 2 if texture + 3 if normal) * FLOAT_SIZE_BYTES;
    int TRIANGLE_VERTICES_DATA_POS_OFFSET_BYTES;    // always 0
    int TRIANGLE_VERTICES_DATA_UV_OFFSET_BYTES;     // always 3 * FLOAT_SIZE_BYTES but valid only if mHasTexture
    int TRIANGLE_VERTICES_DATA_NORMAL_OFFSET_BYTES;   // (5 if texture, 3 unless texture) * FLOAT_SIZE_BYTES; valid only if mHasNormal
    BOOL hasTexture;
    BOOL hasNormal;
    unsigned vertex_count;
    float* vertex_ptr;          // SHOULD be freed; it is safe to free after glBufferData
    unsigned triangle_count;
    unsigned* index_ptr;        // SHOULD be freed
    container gc;               // gc.data_ptr: SHOULD be freed
} obj_opengl;
void parseObj(const char* objPathname, obj_opengl* obj_opengl_ptr);

int readToken(FILE* fp, char** tokenPtr);
BOOL parseIndices(char* s, unsigned ia[]);
#define CONTAINER_CAPACITY    10000

typedef struct {
    char* name_ptr;
    int nf;
} group;

BOOL add_data_to_container(container* container_ptr, void* data_ptr, size_t data_size);
void print_container_float3(container c);
void print_container_int3(container c);
void calculateScaleAndCenter(const container* vc_ptr, float Cm[3], float L[3], float Cbb[3]);
void fitToCube(container* vc_ptr, float L[3], float Cbb[3]);    // X: [-0.5, 0.5], Y: [-0.5, 0.5], Z: [-0.5, 0.5]
#endif
