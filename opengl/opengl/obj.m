#include "obj.h"
extern int errno;

float parseFloat(char* s)
{
    if (!s)
        return NAN;
    char* endPtr;
    errno = 0;
    float f = strtof(s, &endPtr);
    if (errno)
        return NAN;
    if (*endPtr)
        return NAN;
    return f;
}

// "1/2/3"
// "1"
// "1/2"
// "1//2"
BOOL parseIndices(char* s, unsigned ia[])
{
    char* p = s;
    if (!s)
        return NO;

    ia[1] = 0;
    ia[2] = 0;

    for (int i = 0; i < 3; ++i) {
        if (!*p) {
            fprintf(stderr, "|%s|: |%s|: got null\n", s, p);
            return NO;
        }
        errno = 0;
        char* endPtr;
        long l = strtol(p, &endPtr, 10);
//      printf("%p\n%p (|%d %c|)\n", s, endPtr, *endPtr, *endPtr);
        if (errno) {
            fprintf(stderr, "|%s|: |%s|: %s\n", s, p, strerror(errno));
            return NO;
        }
        if (l <= 0) {
            fprintf(stderr, "|%s|: |%s|: got non-positive: %ld\n", s, p, l);
            return NO;
        }
        if (l > (unsigned long) ((unsigned) -1)) {
            fprintf(stderr, "|%s|: |%s|: not fitted to unsigned(%u)\n", s, p, (unsigned) -1);
            return NO;
        }
        ia[i] = (unsigned) l;
        if (!*endPtr)
            break;
        if (*endPtr != '/') {
            fprintf(stderr, "|%s|: |%s|: invalid character(|%c|)\n", s, p, *endPtr);
            return NO;
        }
        p = endPtr + 1;
        if (*p == '/') {
            ++i;
            ++p;
        }
    }
    return YES;
}


void init_container(container* c_ptr)
{
    if (!c_ptr)
        return;
    c_ptr->next_data_index = 0;
    c_ptr->len = 0;
    c_ptr->data_ptr = NULL;
}
void free_container(container* c_ptr)
{
    if (!c_ptr)
        return;
    if (c_ptr->data_ptr)
        free(c_ptr->data_ptr);
    init_container(c_ptr);
}
void make_container_compact(container* c_ptr, size_t data_size)
{
    if (!c_ptr)
        return;
    void* q = realloc(c_ptr->data_ptr, data_size * c_ptr->next_data_index);
    assert(q);
    c_ptr->data_ptr = q;
}
BOOL add_data_to_container(container* container_ptr, void* data_ptr, size_t data_size)
{
    const char NAME[] = "add_data_to_container";
    if (!container_ptr) {
        fprintf(stderr, "%s: container_ptr is null\n", NAME);
        return NO;
    }
    if (!data_ptr) {
        fprintf(stderr, "%s: data_ptr is null\n", NAME);
        return NO;
    }
    if (!container_ptr->data_ptr || container_ptr->next_data_index == container_ptr->len) {
        void* q = realloc(container_ptr->data_ptr, (container_ptr->len + CONTAINER_CAPACITY) * data_size);
        if (!q) {
            fprintf(stderr, "%s: realloc failed\n", NAME);
            return NO;
        }
        container_ptr->len += CONTAINER_CAPACITY;
        container_ptr->data_ptr = q;
    }
    memcpy(container_ptr->data_ptr + container_ptr->next_data_index * data_size, data_ptr, data_size);
    ++container_ptr->next_data_index;
    return YES;
}

void* parseObj(const char* objPathname, obj_opengl* obj_opengl_ptr)
{
    if (!obj_opengl_ptr)
        return NULL;
    container* gc_ptr = &obj_opengl_ptr->gc; init_container(gc_ptr);
    container vc; init_container(&vc);
    container vtc; init_container(&vtc);
    container vnc; init_container(&vnc);
    container ivc; init_container(&ivc);
    container ivtc; init_container(&ivtc);
    container ivnc; init_container(&ivnc);

    FILE *fp = fopen(objPathname, "r");
    if (fp == NULL) {
        perror("fopen");
        return NULL;
    }

    int k = 0;
    char* token = NULL;
    char* group_name_ptr = NULL;
    BOOL all_indices_same = YES;    // all indices like "l/m/n" are the same if they are positive
    BOOL all_has_texture = YES;
    BOOL all_has_normal = YES;
    while (1) {
        if (token == NULL)
            k = readToken(fp, &token);
        if (token) {
//          printf("%s\n", token);
            if (strcmp(token, "g") == 0) {
                k = readToken(fp, &token);
                assert(k > 0);
                if (group_name_ptr) {
                    group g;
                    g.name_ptr = group_name_ptr;
                    g.nf = ivc.next_data_index;
                    add_data_to_container(gc_ptr, &g, sizeof(group));
                    group_name_ptr = NULL;
                }
                size_t token_len = strlen(token);
                group_name_ptr = (char*) malloc(token_len + 1); // 1 for '\0'
                assert(group_name_ptr);
                strncpy(group_name_ptr, token, token_len + 1);  // including '\0'
//              printf("g: |%s|\n", token);
                token = NULL;
                continue;
            } else if (strcmp(token, "v") == 0) {
////printf("v");
                float vx, vy, vz;
                k = readToken(fp, &token); assert(k > 0);
                vx = parseFloat(token); assert(vx != NAN);
////printf(" %s", token);
//printf("vx: %f\n", vx);
                k = readToken(fp, &token); assert(k > 0);
                vy = parseFloat(token); assert(vy != NAN);
////printf(" %s", token);
//printf("vy: %f\n", vy);
                k = readToken(fp, &token); assert(k > 0);
                vz = parseFloat(token); assert(vz != NAN);
////printf(" %s", token);
//printf("vz: %f\n", vz);
////printf("\n");

                float P[3] = {vx, vy, vz};
                add_data_to_container(&vc, P, sizeof(float[3]));

                token = NULL;
            } else if (strcmp(token, "vt") == 0) {
////printf("vt");
                float vtu, vtv;
                k = readToken(fp, &token); assert(k > 0);
                vtu = parseFloat(token); assert(vtu != NAN && vtu >= 0.0f && vtu <= 1.0f);
////printf(" %s", token);
//printf("vtu: %f\n", vtu);
                k = readToken(fp, &token); assert(k > 0);
                vtv = parseFloat(token); assert(vtv != NAN && vtv >= 0.0f && vtv <= 1.0f);
////printf(" %s", token);
//printf("vtv: %f\n", vtv);
////printf("\n");

                float uv[2] = {vtu, vtv};
                add_data_to_container(&vtc, uv, sizeof(float[2]));

                token = NULL;
            } else if (strcmp(token, "vn") == 0) {
////printf("vn");
                float vnx, vny, vnz;
                k = readToken(fp, &token); assert(k > 0);
                vnx = parseFloat(token); assert(vnx != NAN);
////printf(" %s", token);
//printf("vnx: %f\n", vnx);
                k = readToken(fp, &token); assert(k > 0);
                vny = parseFloat(token); assert(vny != NAN);
////printf(" %s", token);
//printf("vny: %f\n", vny);
                k = readToken(fp, &token); assert(k > 0);
                vnz = parseFloat(token); assert(vnz != NAN);
////printf(" %s", token);
//printf("vnz: %f\n", vnz);
////printf("\n");

                float N[3] = {vnx, vny, vnz};
                add_data_to_container(&vnc, N, sizeof(float[3]));

                token = NULL;
            } else if (strcmp(token, "f") == 0) {
////printf("f");
                BOOL b;
                k = readToken(fp, &token); assert(k > 0);
                unsigned ia1[3];
                b = parseIndices(token, ia1); assert(b);
                if (ia1[1] == 0)
                    all_has_texture = NO;
                else if (ia1[1] != ia1[0])
                    all_indices_same = NO;
                if (ia1[2] == 0)
                    all_has_normal = NO;
                else if (ia1[2] != ia1[0])
                    all_indices_same = NO;
////printf(" %s", token);
//printf("f1: %s\n", token);
                k = readToken(fp, &token); assert(k > 0);
                unsigned ia2[3];
                b = parseIndices(token, ia2); assert(b);
                if (ia2[1] == 0)
                    all_has_texture = NO;
                else if (ia2[1] != ia2[0])
                    all_indices_same = NO;
                if (ia2[2] == 0)
                    all_has_normal = NO;
                else if (ia2[2] != ia2[0])
                    all_indices_same = NO;
////printf(" %s", token);
//printf("f2: %s\n", token);
                k = readToken(fp, &token); assert(k > 0);
                unsigned ia3[3];
                b = parseIndices(token, ia3); assert(b);
                if (ia3[1] == 0)
                    all_has_texture = NO;
                else if (ia3[1] != ia3[0])
                    all_indices_same = NO;
                if (ia3[2] == 0)
                    all_has_normal = NO;
                else if (ia3[2] != ia3[0])
                    all_indices_same = NO;
////printf(" %s", token);
//printf("f3: %s\n", token);

                int i3v[3] = {ia1[0] - 1, ia2[0] - 1, ia3[0] - 1};
                add_data_to_container(&ivc, i3v, sizeof(int[3]));
                int i3vt[3] = {ia1[1], ia2[1], ia3[1]};
                add_data_to_container(&ivtc, i3vt, sizeof(int[3]));
                int i3vn[3] = {ia1[2], ia2[2], ia3[2]};
                add_data_to_container(&ivnc, i3vn, sizeof(int[3]));

                k = readToken(fp, &token);
                if (k == 0) {
                    // EOF
                    assert(token == NULL);
////printf("\n");
                } else {
                    char d = token[0];
                    if (d >= '1' && d <= '9') {
////printf(" %s", token);
//printf("f4: %s\n", token);
                        fprintf(stderr, "triangles only");
                        assert(0);
                        unsigned ia4[3];
                        b = parseIndices(token, ia4); assert(b);
                        token = NULL;
                    } else {
                        // use this token next
                    }
////printf("\n");
                }
            } else if (strcmp(token, "mtllib") == 0) {
                k = readToken(fp, &token);
                assert(k > 0);
                printf("mtllib: |%s|\n", token);
                token = NULL;
            } else if (strcmp(token, "usemtl") == 0) {
                k = readToken(fp, &token);
                assert(k > 0);
                printf("mtllib: |%s|\n", token);
                token = NULL;
            } else if (strcmp(token, "s") == 0) {
                k = readToken(fp, &token);
                assert(k > 0);
                printf("s: |%s|\n", token);
                token = NULL;
            } else {
                fprintf(stderr, "unhandled token: |%s|\n", token);
                assert(0);
            }
        }
        if (k == 0) {
            if (feof(fp))
                break;
            perror("ferror");
        }
    }
    group g;
    g.name_ptr = group_name_ptr;
    g.nf = ivc.next_data_index;
    add_data_to_container(gc_ptr, &g, sizeof(group));
    make_container_compact(gc_ptr, sizeof(group));
    group_name_ptr = NULL;
/*
    for (int i = 0; i < gc_ptr->next_data_index; ++i) {
        group* group_ptr = (group*) gc_ptr->data_ptr + i;
        printf("group: |%s|\n", group_ptr->name_ptr);
        printf("# of faces = %d\n", group_ptr->nf);
    }
 */

    if (fclose(fp)) {
        perror("fclose");
    }

    float Cm[3], L[3], Cbb[3];
    calculateScaleAndCenter(&vc, Cm, L, Cbb);
#if 0
    printf("Cm: (%f, %f, %f)\n", Cm[0], Cm[1], Cm[2]);
    printf("L: (%f, %f, %f)\n", L[0], L[1], L[2]);
    printf("Cbb: (%f, %f, %f)\n", Cbb[0], Cbb[1], Cbb[2]);
#endif
    fitToCube(&vc, L, Cbb);
    calculateScaleAndCenter(&vc, Cm, L, Cbb);
#if 0
    printf("Cm: (%f, %f, %f)\n", Cm[0], Cm[1], Cm[2]);
    printf("L: (%f, %f, %f)\n", L[0], L[1], L[2]);
    printf("Cbb: (%f, %f, %f)\n", Cbb[0], Cbb[1], Cbb[2]);
#endif

    assert(vc.next_data_index > 0);
/*
    if (vtc.next_data_index > 0) {
        assert(vc.next_data_index == vtc.next_data_index);
    }
    if (vnc.next_data_index > 0) {
        assert(vc.next_data_index == vnc.next_data_index);
    }
 */

#if 0
    printf("all_indices_same? %s\n", all_indices_same ? "True" : "False");
    printf("all_has_texture? %s\n", all_has_texture ? "True" : "False");
    printf("all_has_normal? %s\n", all_has_normal ? "True" : "False");
#endif
    BOOL hasTexture = all_has_texture;
    BOOL hasNormal = all_has_normal;
    int STRIDE_FLOATS = 3;
    if (hasTexture)
        STRIDE_FLOATS += 2;
    if (hasNormal)
        STRIDE_FLOATS += 3;
    const int TEXTURE_OFFSET_FLOATS = 3;   // always; valid only if hasTexture
    const int NORMAL_OFFSET_FLOATS = hasTexture ? 5 : 3;
    float* P_a = (float*) vc.data_ptr;
    float* UV_a = (float*) vtc.data_ptr;
    float* N_a = (float*) vnc.data_ptr;
    int* Pi_a = (int*) ivc.data_ptr;
    int* UVi_a = (int*) ivtc.data_ptr;
    int* Ni_a = (int*) ivnc.data_ptr;
    container vertex; init_container(&vertex);
    if (all_indices_same) {
        container* vertex_ptr = &vertex;
        for (int i = 0; i < vc.next_data_index; ++i) {
            float* P = P_a + 3 * i;
            float* UV = UV_a + 2 * i;
            float* N = N_a + 3 * i;
            if (hasTexture && hasNormal) {
                float f8[] = {
                    *P, *(P + 1), *(P + 2),
                    *UV, *(UV + 1),
                    *N, *(N + 1), *(N + 2),
                };
                add_data_to_container(vertex_ptr, f8, sizeof(float[8]));
            } else if (hasTexture && !hasNormal) {
                float f5[] = {
                    *P, *(P + 1), *(P + 2),
                    *UV, *(UV + 1),
                };
                add_data_to_container(vertex_ptr, f5, sizeof(float[5]));
            } else if (!hasTexture && hasNormal) {
                float f6[] = {
                    *P, *(P + 1), *(P + 2),
                    *N, *(N + 1), *(N + 2),
                };
                add_data_to_container(vertex_ptr, f6, sizeof(float[6]));
            } else {
                float f3[] = {
                    *P, *(P + 1), *(P + 2),
                };
                add_data_to_container(vertex_ptr, f3, sizeof(float[3]));
            }
        }
    } else {
#if 0
        container vertex1; init_container(&vertex1);
#endif
        container* vertex_ptr = &vertex;
        for (int i = 0; i < vc.next_data_index; ++i) {
            float* P = P_a + 3 * i;
            if (hasTexture && hasNormal) {
                float f8[] = {
                    *P, *(P + 1), *(P + 2),
                    NAN, NAN,
                    NAN, NAN, NAN,
                };
                add_data_to_container(vertex_ptr, f8, sizeof(float[8]));
            } else if (hasTexture && !hasNormal) {
                float f5[] = {
                    *P, *(P + 1), *(P + 2),
                    NAN, NAN,
                };
                add_data_to_container(vertex_ptr, f5, sizeof(float[5]));
            } else if (!hasTexture && hasNormal) {
                float f6[] = {
                    *P, *(P + 1), *(P + 2),
                    NAN, NAN, NAN,
                };
                add_data_to_container(vertex_ptr, f6, sizeof(float[6]));
            } else {
                float f3[] = {
                    *P, *(P + 1), *(P + 2),
                };
                add_data_to_container(vertex_ptr, f3, sizeof(float[3]));
            }
        }

        float* V_a = (float*) vertex_ptr->data_ptr;
        for (int i = 0; i < ivc.next_data_index; ++i) {
            // i-th triangle
            int* Pi = Pi_a + 3 * i;
            int* UVi = UVi_a + 3 * i;
            int* Ni = Ni_a + 3 * i;
            for (int j = 0; j < 3; ++j, ++Pi, ++UVi, ++Ni) {
                int Pij = *Pi;
                float* V = V_a + STRIDE_FLOATS * Pij;
                if (hasTexture) {
                    int UVij = *UVi - 1;
                    float* UV = UV_a + 2 * UVij;
                    float* UVinV = V + TEXTURE_OFFSET_FLOATS;
                    UVinV[0] = UV[0];   // given physical vertex has several (U, V) like pole in a sphere
#if 0
                    if (isNAN(UVinV[0]))
                        UVinV[0] = UV[0];
                    else {
//                      assert(UVinV[0] == UV[0]);
                        if (UV[0] != UVinV[0]) {
                            printf("U: (i = %d, j = %d): overwrite %f with %f\n", i, j, UVinV[0], UV[0]);
                            UVinV[0] = UV[0];
                        }
                    }
#endif
                    UVinV[1] = UV[1];   // given physical vertex has several (U, V) like pole in a sphere
#if 0
                    if (isNAN(UVinV[1]))
                        UVinV[1] = UV[1];
                    else {
//                      assert(UVinV[1] == UV[1]);
                        if (UV[1] != UVinV[1]) {
                            printf("V: (i = %d, j = %d): overwrite %f with %f\n", i, j, UVinV[1], UV[1]);
                            UVinV[1] = UV[1];
                        }
                    }
#endif
                }
                if (hasNormal) {
                    int Nij = *Ni - 1;
                    float* N = N_a + 3 * Nij;
                    float* NinV = V + NORMAL_OFFSET_FLOATS;
                    NinV[0] = N[0];
                    NinV[1] = N[1];
                    NinV[2] = N[2];
#if 0
                    if (isNAN(NinV[0]))
                        NinV[0] = N[0];
                    else
                        assert(NinV[0] == N[0]);
                    if (isNAN(NinV[1]))
                        NinV[1] = N[1];
                    else
                        assert(NinV[1] == N[1]);
                    if (isNAN(NinV[2]))
                        NinV[2] = N[2];
                    else
                        assert(NinV[2] == N[2]);
#endif
                }
            }
        }
#if 0
        printf("%d %d\n", vertex.next_data_index, vertex1.next_data_index);
        float* V0_a = (float*) vertex.data_ptr;
        float* V1_a = (float*) vertex1.data_ptr;
        for (int i = 0; i < vertex.next_data_index; ++i) {
            float* V0 = V0_a + STRIDE_FLOATS * i;
            float* V1 = V1_a + STRIDE_FLOATS * i;
            printf("%d\n", memcmp(V0, V1, sizeof(float) * STRIDE_FLOATS));
        }
        printf("==== %d\n", memcmp(V0_a, V1_a, sizeof(float) * STRIDE_FLOATS * vertex.next_data_index));
        free_container(&vertex1);
#endif
    }
    free_container(&vc);
    free_container(&vtc);
    free_container(&vnc);
//  free_container(&ivc);   // used in obj_opengl_ptr below
    free_container(&ivtc);
    free_container(&ivnc);

    obj_opengl_ptr->hasTexture = hasTexture;
    obj_opengl_ptr->TRIANGLE_VERTICES_DATA_POS_OFFSET_BYTES = 0;    // always
    obj_opengl_ptr->TRIANGLE_VERTICES_DATA_UV_OFFSET_BYTES = TEXTURE_OFFSET_FLOATS * FLOAT_SIZE_BYTES;  // always but valid only if mHasTexture
    obj_opengl_ptr->TRIANGLE_VERTICES_DATA_NORMAL_OFFSET_BYTES = NORMAL_OFFSET_FLOATS * FLOAT_SIZE_BYTES;
    obj_opengl_ptr->TRIANGLE_VERTICES_DATA_STRIDE_BYTES = STRIDE_FLOATS * FLOAT_SIZE_BYTES;
    obj_opengl_ptr->hasNormal = hasNormal;
    obj_opengl_ptr->vertex_count = (unsigned) vertex.next_data_index;
    make_container_compact(&vertex, sizeof(float) * STRIDE_FLOATS);
    obj_opengl_ptr->vertex_ptr = (float*) vertex.data_ptr;
    obj_opengl_ptr->triangle_count = (unsigned) ivc.next_data_index;
    make_container_compact(&ivc, sizeof(int[3]));
    obj_opengl_ptr->index_ptr = (unsigned*) ivc.data_ptr;
    return obj_opengl_ptr;
}

void fitToCube(container* vc_ptr, float L[3], float Cbb[3])
{
    float LM = L[0]; // longest length
    if (LM < L[1])
        LM = L[1];
    if (LM < L[2])
        LM = L[2];
    float* P_a = (float*) vc_ptr->data_ptr;
    for (int i = 0; i < vc_ptr->next_data_index; ++i) {
        float* P = P_a + 3 * i;
        *P = (*P - Cbb[0]) / LM;
        *(P + 1) = (*(P + 1) - Cbb[1]) / LM;
        *(P + 2) = (*(P + 2) - Cbb[2]) / LM;
    }
}

void calculateScaleAndCenter(const container* vc_ptr, float Cm[3], float L[3], float Cbb[3])
{
    float Xm = INFINITY, XM = -INFINITY;
    float Ym = INFINITY, YM = -INFINITY;
    float Zm = INFINITY, ZM = -INFINITY;
    float X = 0, Y = 0, Z = 0;
    float* P_a = (float*) vc_ptr->data_ptr;
    for (int i = 0; i < vc_ptr->next_data_index; ++i) {
        float* P = P_a + 3 * i;
        float x = *P, y = *(P + 1), z = *(P + 2);
        if (x < Xm)
            Xm = x;
        else if (x > XM)
            XM = x;
        X += x;
        if (y < Ym)
            Ym = y;
        else if (y > YM)
            YM = y;
        Y += y;
        if (z < Zm)
            Zm = z;
        else if (z > ZM)
            ZM = z;
        Z += z;
    }
    Cm[0] = X / vc_ptr->next_data_index;
    Cm[1] = Y / vc_ptr->next_data_index;
    Cm[2] = Z / vc_ptr->next_data_index;
    L[0] = XM - Xm;
    L[1] = YM - Ym;
    L[2] = ZM - Zm;
    Cbb[0] = (Xm + XM) / 2;
    Cbb[1] = (Ym + YM) / 2;
    Cbb[2] = (Zm + ZM) / 2;
}


/*
    return 1 if more token might be available
    otherwise return 0 (feof or ferror)

    in either case, if tokenPtr is not NULL, it points to token
 */
int readToken(FILE* fp, char** tokenPtr)
{
    #define BUFLEN 120
    static char buf[BUFLEN + BUFLEN];   // second half used for actual read;
                                        // first half contains part of token which is right-adjusted in order that next read can use it with token_start_index
    static size_t nread = 0;
    static BOOL comment = NO;
    static BOOL continuous = NO;
    static int token_start_index = BUFLEN;
    static int last_i = BUFLEN;

    while (1) {
        for (int i = last_i; i < BUFLEN + nread; ++i) {
            char c = buf[i];
            if (c == ' ' || c == '\r' || c == '\n') {
                if (token_start_index != i) {
                    buf[i] = '\0';  // make null-terminated string for printf
                    char* token = buf + token_start_index;

                    if (comment) {
////                    fprintf(stderr, "token after comment: |%s|: ignored\n", token);
                    } else {
                        if (token[0] == '\\') {
                            if (continuous) {
                                fprintf(stderr, "WARN: another \\ after \\ in one line: ignored\n");
                            }
                            int len = i - token_start_index;
                            if (len > 1) {
                                fprintf(stderr, "WARN: \\ not alone: |%s|: treated as \\\n", token);
                            }
                            continuous = YES;
                        } else if (token[0] == '#') {
                            comment = YES;
                        } else {
                            *tokenPtr = token;
                            if (continuous) {
                                fprintf(stderr, "WARN: token: |%s| after \\: ignored\n", token);
                            } else {
                                token_start_index = i + 1;
                                last_i = i + 1;
                                return 1;
                            }
                        }
                    }
                    if (c == '\r' || c == '\n') {   // reset at new line
                        comment = NO;
                        continuous = NO;
                    }
                }
                token_start_index = i + 1;
            }
        }
        int n = (int) (BUFLEN + nread - token_start_index);
        memcpy(buf + BUFLEN - n, buf + BUFLEN + nread - n, n);
        token_start_index = BUFLEN - n;
        last_i = BUFLEN;

        nread = fread(buf + BUFLEN, sizeof(char), BUFLEN, fp);
        if (nread == 0) {
            if (n > 0) {
                buf[BUFLEN] = '\0'; // make null-terminated string for printf
                char* token = buf + token_start_index;
                *tokenPtr = token;
            } else {
                *tokenPtr = NULL;
            }
            return 0;
        }
    }
}
