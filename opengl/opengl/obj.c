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
        return false;

    ia[1] = 0;
    ia[2] = 0;

    for (int i = 0; i < 3; ++i) {
        if (!*p) {
            fprintf(stderr, "|%s|: |%s|: got null\n", s, p);
            return false;
        }
        errno = 0;
        char* endPtr;
        long l = strtol(p, &endPtr, 10);
//      printf("%p\n%p (|%d %c|)\n", s, endPtr, *endPtr, *endPtr);
        if (errno) {
            fprintf(stderr, "|%s|: |%s|: %s\n", s, p, strerror(errno));
            return false;
        }
        if (l <= 0) {
            fprintf(stderr, "|%s|: |%s|: got non-positive: %ld\n", s, p, l);
            return false;
        }
        if (l > (unsigned long) ((unsigned) -1)) {
            fprintf(stderr, "|%s|: |%s|: not fitted to unsigned(%u)\n", s, p, (unsigned) -1);
            return false;
        }
        ia[i] = (unsigned) l;
        if (!*endPtr)
            break;
        if (*endPtr != '/') {
            fprintf(stderr, "|%s|: |%s|: invalid character(|%c|)\n", s, p, *endPtr);
            return false;
        }
        p = endPtr + 1;
        if (*p == '/') {
            ++i;
            ++p;
        }
    }
    return true;
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
BOOL add_data_to_container(container* container_ptr, void* data_ptr, size_t data_size)
{
    const char NAME[] = "add_data_to_container";
    if (!container_ptr) {
        fprintf(stderr, "%s: container_ptr is null\n", NAME);
        return false;
    }
    if (!data_ptr) {
        fprintf(stderr, "%s: data_ptr is null\n", NAME);
        return false;
    }
    if (!container_ptr->data_ptr || container_ptr->next_data_index == container_ptr->len) {
        void* q = realloc(container_ptr->data_ptr, (container_ptr->len + CONTAINER_CAPACITY) * data_size);
        if (!q) {
            fprintf(stderr, "%s: realloc failed\n", NAME);
            return false;
        }
        container_ptr->len += CONTAINER_CAPACITY;
        container_ptr->data_ptr = q;
    }
    memcpy(container_ptr->data_ptr + container_ptr->next_data_index * data_size, data_ptr, data_size);
    ++container_ptr->next_data_index;
    return true;
}
void print_container_float3(container c)
{
    for (int i = 0; i < c.next_data_index; ++i) {
        float3* float3_ptr = (float3*) c.data_ptr + i;
        printf("(%f %f %f)\n", float3_ptr->x, float3_ptr->y, float3_ptr->z);
    }
}
void print_container_int3(container c)
{
    for (int i = 0; i < c.next_data_index; ++i) {
        int3* int3_ptr = (int3*) c.data_ptr + i;
        printf("(%d %d %d)\n", int3_ptr->i, int3_ptr->j, int3_ptr->k);
    }
}

void parseObj(const char* objPathname)
{
    container vc; init_container(&vc);
    container vtc; init_container(&vtc);
    container vnc; init_container(&vnc);
    container ivc; init_container(&ivc);
    container ivtc; init_container(&ivtc);
    container ivnc; init_container(&ivnc);

    FILE *fp = fopen(objPathname, "r");
    if (fp == NULL) {
        perror("fopen");
        return;
    }

    int k = 0;
    char* token = NULL;
    while (1) {
        if (token == NULL)
            k = readToken(fp, &token);
        if (token) {
//          printf("%s\n", token);
            char c = token[0];
            if (c == 'g') {
                k = readToken(fp, &token);
                assert(k > 0);
                printf("g %s\n", token);
//              printf("g: |%s|\n", token);
                token = NULL;
                continue;
            } else if (c == 'v') {
                char c2 = token[1];
                if (c2 == '\0') {   // "v"
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

                    float3 v = {vx, vy, vz};
                    add_data_to_container(&vc, &v, sizeof(float3));

                    token = NULL;
                } else if (c2 == 't') { // "vt"
                    assert(token[2] == '\0');
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

                    float2 uv = {vtu, vtv};
                    add_data_to_container(&vtc, &uv, sizeof(float2));

                    token = NULL;
                } else if (c2 == 'n') { // "vn"
                    assert(token[2] == '\0');
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

                    float3 n = {vnx, vny, vnz};
                    add_data_to_container(&vnc, &n, sizeof(float3));

                    token = NULL;
                } else {
                    assert(0);
                }
            } else if (c == 'f') {
////printf("f");
                BOOL b;
                k = readToken(fp, &token); assert(k > 0);
                unsigned ia1[3];
                b = parseIndices(token, ia1); assert(b);
////printf(" %s", token);
//printf("f1: %s\n", token);
                k = readToken(fp, &token); assert(k > 0);
                unsigned ia2[3];
                b = parseIndices(token, ia2); assert(b);
////printf(" %s", token);
//printf("f2: %s\n", token);
                k = readToken(fp, &token); assert(k > 0);
                unsigned ia3[3];
                b = parseIndices(token, ia3); assert(b);
////printf(" %s", token);
//printf("f3: %s\n", token);

                int3 i3v = {ia1[0], ia2[0], ia3[0]};
                add_data_to_container(&ivc, &i3v, sizeof(int3));
                int3 i3vt = {ia1[1], ia2[1], ia3[1]};
                add_data_to_container(&ivtc, &i3vt, sizeof(int3));
                int3 i3vn = {ia1[2], ia2[2], ia3[2]};
                add_data_to_container(&ivnc, &i3vn, sizeof(int3));

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

    if (fclose(fp)) {
        perror("fclose");
    }

/*
    fprintf(stderr, "(nv, nvt, nvn): (%d, %d, %d)\n", vc.next_data_index, vtc.next_data_index, vnc.next_data_index);
    float x, y, z;
    x = 0, y = 0, z = 0;
    for (int i = 0; i < vc.next_data_index; ++i) {
        float3* float3_ptr = (float3*) vc.data_ptr + i;
        x += float3_ptr->x;
        y += float3_ptr->y;
        z += float3_ptr->z;
    }
    float3 Cm = {X / zv, Y / zv, Z / zv};
    float3 Cbb = {(Xm + XM) / 2, (Ym + YM) / 2, (Zm + ZM) / 2};
    printf("(%f %f %f)\n", Cbb.x, Cbb.y, Cbb.z);
    printf("(%f %f %f)\n", x / vc.next_data_index, y / vc.next_data_index, z / vc.next_data_index);
 */
    float3 Cm, L, Cbb;
    calculateScaleAndCenter(&vc, &Cm, &L, &Cbb);
    printf("Cm: (%f, %f, %f)\n", Cm.x, Cm.y, Cm.z);
    printf("L: (%f, %f, %f)\n", L.x, L.y, L.z);
    printf("Cbb: (%f, %f, %f)\n", Cbb.x, Cbb.y, Cbb.z);
    fitToCube(&vc, L, Cbb);
    calculateScaleAndCenter(&vc, &Cm, &L, &Cbb);
    printf("Cm: (%f, %f, %f)\n", Cm.x, Cm.y, Cm.z);
    printf("L: (%f, %f, %f)\n", L.x, L.y, L.z);
    printf("Cbb: (%f, %f, %f)\n", Cbb.x, Cbb.y, Cbb.z);

    assert(vc.next_data_index == vtc.next_data_index && vc.next_data_index == vnc.next_data_index);
    obj_data obj; init_obj_data(&obj);
    for (int i = 0; i < vc.next_data_index; ++i) {
        float3* v_ptr = (float3*) vc.data_ptr + i;
        float2* vt_ptr = (float2*) vtc.data_ptr + i;
        float3* vn_ptr = (float3*) vnc.data_ptr + i;
        float8 f8 = {
            v_ptr->x, v_ptr->y, v_ptr->z,
            vt_ptr->u, vt_ptr->v,
            vn_ptr->x, vn_ptr->y, vn_ptr->z,
        };
        add_data_to_container(&obj.vertex, &f8, sizeof(float8));
    }
    for (int i = 0; i < ivc.next_data_index; ++i) {
        int3* iv_ptr = (int3*) ivc.data_ptr + i;
        int3* ivt_ptr = (int3*) ivtc.data_ptr + i;
        int3* ivn_ptr = (int3*) ivnc.data_ptr + i;
        int9 i9 = {
            iv_ptr->i, iv_ptr->j, iv_ptr->k,
            ivt_ptr->i, ivt_ptr->j, ivt_ptr->k,
            ivn_ptr->i, ivn_ptr->j, ivn_ptr->k,
        };
        add_data_to_container(&obj.index, &i9, sizeof(int9));
    }
    free_container(&vc);
    free_container(&vtc);
    free_container(&vnc);
    free_container(&ivc);
    free_container(&ivtc);
    free_container(&ivnc);

    free_obj_data(&obj);

    return;
}
void init_obj_data(obj_data* obj_ptr)
{
    if (!obj_ptr)
        return;
    init_container(&obj_ptr->vertex);
    init_container(&obj_ptr->index);
}
void free_obj_data(obj_data* obj_ptr)
{
    if (!obj_ptr)
        return;
    free_container(&obj_ptr->vertex);
    free_container(&obj_ptr->index);
}

void fitToCube(container* vc_ptr, float3 L, float3 Cbb)
{
    float LM = L.x; // longest length
    if (LM < L.y)
        LM = L.y;
    if (LM < L.z)
        LM = L.z;
    for (int i = 0; i < vc_ptr->next_data_index; ++i) {
        float3* float3_ptr = (float3*) vc_ptr->data_ptr + i;
        float3_ptr->x = (float3_ptr->x - Cbb.x) / LM;
        float3_ptr->y = (float3_ptr->y - Cbb.y) / LM;
        float3_ptr->z = (float3_ptr->z - Cbb.z) / LM;
    }
}

void calculateScaleAndCenter(const container* vc_ptr, float3* Cm_ptr, float3* L_ptr, float3* Cbb_ptr)
{
    float Xm = INFINITY, XM = -INFINITY;
    float Ym = INFINITY, YM = -INFINITY;
    float Zm = INFINITY, ZM = -INFINITY;
    float X = 0, Y = 0, Z = 0;
    for (int i = 0; i < vc_ptr->next_data_index; ++i) {
        float3* float3_ptr = (float3*) vc_ptr->data_ptr + i;
        float x = float3_ptr->x, y = float3_ptr->y, z = float3_ptr->z;
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
    Cm_ptr->x = X / vc_ptr->next_data_index;
    Cm_ptr->y = Y / vc_ptr->next_data_index;
    Cm_ptr->z = Z / vc_ptr->next_data_index;
    L_ptr->x = XM - Xm;
    L_ptr->y = YM - Ym;
    L_ptr->z = ZM - Zm;
    Cbb_ptr->x = (Xm + XM) / 2;
    Cbb_ptr->y = (Ym + YM) / 2;
    Cbb_ptr->z = (Zm + ZM) / 2;
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
    static BOOL comment = false;
    static BOOL continuous = false;
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
                        fprintf(stderr, "token after comment: |%s|: ignored\n", token);
                    } else {
                        if (token[0] == '\\') {
                            if (continuous) {
                                fprintf(stderr, "WARN: another \\ after \\ in one line: ignored\n");
                            }
                            int len = i - token_start_index;
                            if (len > 1) {
                                fprintf(stderr, "WARN: \\ not alone: |%s|: treated as \\\n", token);
                            }
                            continuous = true;
                        } else if (token[0] == '#') {
                            comment = true;
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
                        comment = false;
                        continuous = false;
                    }
                }
                token_start_index = i + 1;
            }
        }
        int n = BUFLEN + nread - token_start_index;
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
