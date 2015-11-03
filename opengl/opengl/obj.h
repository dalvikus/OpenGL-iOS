#ifndef _OBJ
#define _OBJ
void parseObj(const char* objPathname);
int readToken(FILE* fp, char** tokenPtr);
float parseFloat(char* s);
BOOL parseIndices(char* s, unsigned ia[]);
#define CONTAINER_CAPACITY    10000
typedef struct {
    int i, j, k;
} int3;
typedef struct {
    float u, v;
} float2;
typedef struct {
    float x, y, z;
} float3;
typedef struct
{
    int next_data_index;
    size_t  len;    // capacity of container
    void* data_ptr;
} container;
void init_container(container* c_ptr);
void free_container(container* c_ptr);
typedef struct {
    float3 v;
    float2 uv;
    float3 vn;
} float8;
typedef struct {
    int3 iv;
    int3 ivt;
    int3 ivn;
} int9;
typedef struct {
    container vertex;
    container index;
} obj_data;
void init_obj_data(obj_data* obj_ptr);
void free_obj_data(obj_data* obj_ptr);
BOOL add_data_to_container(container* container_ptr, void* data_ptr, size_t data_size);
void print_container_float3(container c);
void print_container_int3(container c);
void calculateScaleAndCenter(const container* vc_ptr, float3* Cm_ptr, float3* L_ptr, float3* Cbb_ptr);
void fitToCube(container* vc_ptr, float3 L, float3 Cbb);
#endif
