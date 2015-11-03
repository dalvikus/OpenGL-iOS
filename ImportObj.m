// clang -g -Wall -DDEBUG ImportObj.m -framework Foundation
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif
#ifndef ALog
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#endif

#import <Foundation/Foundation.h>
/*
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#ifndef BOOL
#define BOOL int
#define true 1
#define false 0
#endif
 */

extern int errno;

int readToken(FILE* fp, char** tokenPtr);

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

#define CAPACITY    1000
#define INFO_INC_UNIT 100
typedef struct {
    int i, j, k;
} int3;
typedef struct {
    float u, v;
} float2, uv;
typedef struct {
    float x, y, z;
} float3;
typedef struct {
    int index_data;
    void* data_ptr;
} info;
typedef struct {
    int index_info;
    unsigned n_info;
    info* info_ptr;
} array;
BOOL add_data2(array* s2_ptr, const void* data_ptr, size_t data_size)
{
    const char NAME[] = "add_data2";

    int index_info = s2_ptr->index_info;
    unsigned n_info = s2_ptr->n_info;
    info* info_ptr = NULL;
    if (s2_ptr->info_ptr)
        info_ptr = &s2_ptr->info_ptr[index_info];
    if (!info_ptr || (info_ptr->index_data == CAPACITY && (index_info + 1) == n_info)) {
        info* q = (info*) realloc(s2_ptr->info_ptr, (n_info + 1) * INFO_INC_UNIT * sizeof(info));
#if defined(DEBUG_ARRAY)
        printf("%s: memory for new info_ptr: %p\n", NAME, q);
#endif
        if (!q) {
            fprintf(stderr, "%s: failed to allocate memory for info_ptr\n", NAME);
            return false;
        }
        s2_ptr->info_ptr = q;       // set pointer to new location
        info_ptr = &q[index_info];  // update info_ptr
        memset(&q[n_info], 0, INFO_INC_UNIT * sizeof(info));
        *&s2_ptr->n_info += INFO_INC_UNIT;  // update n_info field
////    n_info += INFO_INC_UNIT;    // update n_info; not used any more below
    }
    // info_ptr is NOT null
    if (info_ptr->index_data == CAPACITY) {
        ++*&s2_ptr->index_info;     // update index_info field
        ++info_ptr;                 // set info_ptr to next info
    }
    if (!info_ptr->data_ptr) {
        void* q = malloc(CAPACITY * data_size);
#if defined(DEBUG_ARRAY)
        printf("%s: memory for data_ptr: %p\n", NAME, q);
#endif
        if (!q) {
            fprintf(stderr, "fail to allocate memory for data_ptr\n");
            return false;
        }
        info_ptr->data_ptr = q;
    }
    // info_ptr->data_ptr is NOT null
    memcpy(info_ptr->data_ptr + data_size * info_ptr->index_data, data_ptr, data_size);
    ++*&info_ptr->index_data;
    return true;
}

void print_data2_float3(const array s2)
{
    for (int i = 0; i <= s2.index_info; ++i) {
        if (!s2.info_ptr)
            break;
        info s = s2.info_ptr[i];
        for (int j = 0; j < s.index_data; ++j) {
            float3* data_ptr = (float3*) s.data_ptr;
            float3 f3 = data_ptr[j];
            printf("(%f, %f, %f)\n", f3.x, f3.y, f3.z);
        }
    }
}
void print_data2_int3(const array s2)
{
    for (int i = 0; i <= s2.index_info; ++i) {
        info s = s2.info_ptr[i];
        for (int j = 0; j < s.index_data; ++j) {
            int3* int3_ptr = (int3*) s.data_ptr;
            int3 i3 = int3_ptr[j];
            printf("(%d, %d, %d)\n", i3.i, i3.j, i3.k);
        }
    }
}
unsigned count(const array s2)
{
    unsigned n = 0;
    for (int i = 0; i <= s2.index_info; ++i) {
        info s = s2.info_ptr[i];
        n += s.index_data;
    }
    return n;
}
float3* data_ptr_float3_at(const array s2, int index)
{
    const char NAME[] = "data_ptr_float3_at";
    int i = index / CAPACITY;
    int j = index % CAPACITY;
    if (i > s2.index_info) {
fprintf(stderr, "index_info = %d, n_info = %u, index = %d, INFO_INC_UNIT = %d, i = %d, j = %d\n", s2.index_info, s2.n_info, index, INFO_INC_UNIT, i, j);
        fprintf(stderr, "%s: %d: out of range (%d: i = %d)\n", NAME, index, s2.index_info, i);
        return NULL;
    }
    info s = s2.info_ptr[i];
    if (j > s.index_data) {
fprintf(stderr, "index_info = %d, n_info = %u, index = %d, INFO_INC_UNIT = %d, i = %d, j = %d\n", s2.index_info, s2.n_info, index, INFO_INC_UNIT, i, j);
        fprintf(stderr, "%s: %d: out of range (%d: j = %d)\n", NAME, index, s.index_data, j);
        return NULL;
    }
    float3* float3_ptr = (float3*) s.data_ptr;
    return &float3_ptr[j];
}
int3* data_ptr_int3_at(const array s2, int index)
{
    const char NAME[] = "data_ptr_int3_at";
    int i = index / INFO_INC_UNIT;
    int j = index % INFO_INC_UNIT;
    if (i > s2.index_info) {
        fprintf(stderr, "%s: %d: out of range\n", NAME, index);
        return NULL;
    }
    info s = s2.info_ptr[i];
    if (j >= s.index_data) {
        fprintf(stderr, "%s: %d: out of range\n", NAME, index);
        return NULL;
    }
    int3* int3_ptr = (int3*) s.data_ptr;
    return &int3_ptr[j];
}
void print_data2_float3_random(const array s2)
{
    for (int i = 0; i < count(s2); ++i) {
        float3* float3_ptr = data_ptr_float3_at(s2, i);
        printf("(%f, %f, %f)\n", float3_ptr->x, float3_ptr->y, float3_ptr->z);
    }
}
void freeStick2(array* s2_ptr)
{
#if defined(DEBUG_ARRAY)
    const char NAME[] = "freeStick2";
#endif
    for (int i = s2_ptr->index_info; i >= 0; --i) {
        float3* data_ptr = s2_ptr->info_ptr[i].data_ptr;
        free(data_ptr);
#if defined(DEBUG_ARRAY)
        printf("%s: free memory for data_ptr: %p\n", NAME, data_ptr);
#endif
    }
    info* info_ptr = s2_ptr->info_ptr;
    free(info_ptr);
#if defined(DEBUG_ARRAY)
    printf("%s: free memory for info_ptr: %p\n", NAME, info_ptr);
#endif
}

typedef struct doubly_linked_list {
    struct doubly_linked_list* prev_ptr;
    struct doubly_linked_list* next_ptr;
    unsigned n;
    void* data_ptr;
} doubly_linked_list;
void* add_data(doubly_linked_list* ptr, const void* data_ptr, size_t data_size)
{
    const char NAME[] = "add_data";

    doubly_linked_list* q = ptr;
    unsigned n;
    if (!ptr || (n = ptr->n) == CAPACITY) {
        q = (doubly_linked_list*) malloc(sizeof(doubly_linked_list));
#if defined(DEBUG_LIST)
        fprintf(stderr, "%s: memory for doubly_linked_list: %p\n", NAME, q);
#endif
        if (!q) {
            fprintf(stderr, "%s: failed to allocate memory for doubly_linked_list\n", NAME);
            return NULL;
        }
        q->prev_ptr = ptr;
        q->next_ptr = NULL;
        q->n = 0;
        q->data_ptr = malloc(CAPACITY * data_size);
#if defined(DEBUG_LIST)
        fprintf(stderr, "%s: memory for data_ptr: %p\n", NAME, q->data_ptr);
#endif
        if (!q->data_ptr) {
            fprintf(stderr, "%s: failed to allocate memory for data_ptr\n", NAME);
            return NULL;
        }
        if (ptr) {  // n = CAPACITY
            ptr->next_ptr = q;
        }
    }
    memcpy((char*) q->data_ptr + q->n * data_size, data_ptr, data_size);
    ++q->n;
    return q;
}
void print_data_float3(doubly_linked_list* ptr)
{
    doubly_linked_list* q = ptr;
    int k = 1;  // # of sticks
    while (q) {
////    fprintf(stderr, "q -> %p\n", q);
        unsigned n = q->n;
        printf("%d stick has %d items\n", k++, n);
        float3* data_ptr = (float3*) q->data_ptr;
        for (int i = 0; i < n; ++i) {
            float3 f3 = data_ptr[i];
            printf("(%f, %f, %f\n", f3.x, f3.y, f3.z);
        }
        q = q->next_ptr;
    }
}
void print_data_int3(doubly_linked_list* ptr)
{
    doubly_linked_list* q = ptr;
#if defined(DEBUG_LIST)
    int k = 1;  // # of sticks
#endif
    while (q) {
////    fprintf(stderr, "q -> %p\n", q);
        unsigned n = q->n;
#if defined(DEBUG_LIST)
        printf("%d stick has %d items\n", k++, n);
#endif
        int3* data_ptr = (int3*) q->data_ptr;
        for (int i = 0; i < n; ++i) {
            int3 i3 = data_ptr[i];
            printf("(%d, %d, %d)\n", i3.i, i3.j, i3.k);
        }
        q = q->next_ptr;
    }
}
void freeStick(doubly_linked_list* head)
{
    doubly_linked_list* q = head;
    if (!q)
        return;
    while (q->next_ptr) {
        q = q->next_ptr;
    }
////fprintf(stderr, "q: %p\n", q);
    do {
#if defined(DEBUG_LIST)
        fprintf(stderr, "free memory for data_ptr: %p\n", q->data_ptr);
#endif
        free(q->data_ptr);
#if defined(DEBUG_LIST)
        fprintf(stderr, "free memory for doubly_linked_list: %p\n", q);
#endif
        free(q);
        q = q->prev_ptr;
    } while (q);
}

typedef struct
{
    int next_data_index;
    size_t  len;    // capacity of container
    void* data_ptr;
} container;
BOOL add_data_to_container(container* container_ptr, void* data_ptr, size_t data_size)
{
    const char NAME[] = "add_data";
    if (!container_ptr) {
        fprintf(stderr, "%s: container_ptr is null\n", NAME);
        return false;
    }
    if (!data_ptr) {
        fprintf(stderr, "%s: data_ptr is null\n", NAME);
        return false;
    }
    if (!container_ptr->data_ptr || container_ptr->next_data_index == container_ptr->len) {
        void* q = realloc(container_ptr->data_ptr, (container_ptr->len + CAPACITY) * data_size);
        if (!q) {
            fprintf(stderr, "%s: realloc failed\n", NAME);
            return false;
        }
        container_ptr->len += CAPACITY;
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

int main(int argc, char *argv[])
{
#define N 10000000
    container c;
    c.next_data_index = 0;
    c.len = 0;
    c.data_ptr = 0;
    for (int i = 0; i < N; ++i) {
        float3 f3;
        f3.x = i; f3.y = i + 1; f3.z = i + 2;
        add_data_to_container(&c, &f3, sizeof(float3));
    }
    print_container_float3(c);
    return 0;
/*
    float3* float3_ptr = (float3*) malloc(N * sizeof(float3));
    for (int i = 0; i < N; ++i) {
        float3* f3_ptr = float3_ptr + i;
        f3_ptr->x = i; f3_ptr->y = i + 1; f3_ptr->z = i + 2;
    }
    for (int i = 0; i < N; ++i) {
        float3* f3_ptr = float3_ptr + i;
        printf("(%f, %f, %f)\n", f3_ptr->x, f3_ptr->y, f3_ptr->z);
    }
    free(float3_ptr);
    return 0;
 */
    unsigned n_float3 = 0;
    float3* float3_ptr = 0;
    for (int i = 0; i < N; ++i, ++n_float3) {
        if (n_float3 % CAPACITY == 0) {
            void* q = realloc(float3_ptr, (n_float3 + 1) * CAPACITY * sizeof(float3));
            if (!q) {
                fprintf(stderr, "realloc failed\n");
                assert(0);
            }
            float3_ptr = (float3*) q;
        }
        float3* f3_ptr = float3_ptr + i;
        f3_ptr->x = i; f3_ptr->y = i + 1; f3_ptr->z = i + 2;
    }
    for (int i = 0; i < N; ++i) {
        float3* f3_ptr = float3_ptr + i;
        printf("(%f, %f, %f)\n", f3_ptr->x, f3_ptr->y, f3_ptr->z);
    }
    free(float3_ptr);
    return 0;
    array data;
    data.index_info = 0;
    data.n_info = 0;
    data.info_ptr = NULL;

    print_data2_float3(data);
    for (int i = 0; i < N; ++i) {
        float3 f3;
        f3.x = i; f3.y = i + 1; f3.z = i + 2;
        BOOL done = add_data2(&data, &f3, sizeof(float3));
        assert(done);
/*
        int3 i3;
        i3.i = i; i3.j = i + 1; i3.k = i + 2;
        BOOL done = add_data2(&data, &i3, sizeof(int3));
        assert(done);
 */
    }
    fprintf(stderr, "# of data = %u\n", count(data));
    return 0;
//  print_data2_float3(data);
    print_data2_float3_random(data);
//  print_data2_int3(data);
    freeStick2(&data);

    doubly_linked_list* head = NULL;
    doubly_linked_list* ptr = NULL;
    for (int i = 0; i < 10; ++i) {
/*
        float3 f3;
        f3.x = i; f3.y = i + 1; f3.z = i + 2;
        ptr = add_data(ptr, &f3, sizeof(float3));
 */
        int3 i3;
        i3.i = i; i3.j = i + 1; i3.k = i + 2;
        ptr = add_data(ptr, &i3, sizeof(int3));
        assert(ptr);
        if (head == NULL)
            head = ptr;
    }
    if (head) {
//      print_data_float3(head);
        print_data_int3(head);
        freeStick(head);
    }
    return 0;
    int a[10];
    for (int i = 0; i < 10; ++i)
        a[i] = i;
    for (int i = 0; i < 10; ++i)
        printf("a[%d] = %d\n", i, a[i]);
    char* p = (char*) a;
    p += 3 * sizeof(int);
    *((int*) p) = 0;
    *((int**) p) = a;
    for (int i = 0; i < 10; ++i)
        printf("a[%d] = %d (%x)\n", i, a[i], a[i]);
    printf("%p\n", a);
    printf("%zu", sizeof(void*));
    return 0;
    NSString *s1 = @"abc";
    NSString *s2 = @"123";

    NSLog(@"%@", [s1 stringByAppendingString: s2]);
    ALog(@"%@", [s1 stringByAppendingString: s2]);
    const char msg[] = "hello, world";
    NSString *s = [NSString stringWithUTF8String:msg];
    ALog(@"%@", s);

    if (argc == 1) {
        printf("Usage:...\n");
        return 0;
    }
//  for (int i = 0; i < argc; ++i) {
//      printf("argv[%d]: |%s|\n", i, argv[i]);
//  }
/*
    char *line = NULL;
    size_t len = 0;
    ssize_t read;
 */

    FILE *fp = fopen(argv[1], "r");
    if (fp == NULL) {
        perror("fopen");
        exit(EXIT_FAILURE);
    }

    int k;
    char* token = NULL;
    size_t zv = 0, zvt = 0, zvn = 0;
    float Xm = INFINITY, XM = -INFINITY;
    float Ym = INFINITY, YM = -INFINITY;
    float Zm = INFINITY, ZM = -INFINITY;
    float X = 0, Y = 0, Z = 0;
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
                    X += vx;
                    if (vx < Xm)
                        Xm = vx;
                    else if (vx > XM)
                        XM = vx;
                    k = readToken(fp, &token); assert(k > 0);
                    vy = parseFloat(token); assert(vy != NAN);
////printf(" %s", token);
//printf("vy: %f\n", vy);
                    Y += vy;
                    if (vy < Ym)
                        Ym = vy;
                    else if (vy > YM)
                        YM = vy;
                    k = readToken(fp, &token); assert(k > 0);
                    vz = parseFloat(token); assert(vz != NAN);
////printf(" %s", token);
//printf("vz: %f\n", vz);
                    Z += vz;
                    if (vz < Zm)
                        Zm = vz;
                    else if (vz > ZM)
                        ZM = vz;
////printf("\n");
                    ++zv;
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
                    ++zvt;
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
                    ++zvn;
                    token = NULL;
                } else {
                    assert(0);
                }
            } else if (c == 'f') {
////printf("f");
                unsigned ia[3];
                BOOL b;
                k = readToken(fp, &token); assert(k > 0);
                b = parseIndices(token, ia); assert(b);
////printf(" %s", token);
//printf("f1: %s\n", token);
                k = readToken(fp, &token); assert(k > 0);
                b = parseIndices(token, ia); assert(b);
////printf(" %s", token);
//printf("f2: %s\n", token);
                k = readToken(fp, &token); assert(k > 0);
                b = parseIndices(token, ia); assert(b);
////printf(" %s", token);
//printf("f3: %s\n", token);
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
                        b = parseIndices(token, ia); assert(b);
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
    fprintf(stderr, "(zv, zvt, zvn): (%zu, %zu, %zu)\n", zv, zvt, zvn);
    fprintf(stderr, "(%f, %f), (%f, %f), (%f, %f)\n", Xm, XM, Ym, YM, Zm, ZM);
    fprintf(stderr, "(lx, ly, lz): (%f, %f, %f)\n", XM - Xm, YM - Ym, ZM - Zm);
    float L = XM - Xm;
    if (L < YM - Ym)
        L = YM - Ym;
    if (L < ZM - Zm)
        L = ZM - Zm;
    fprintf(stderr, "L: %f\n", L);
    fprintf(stderr, "(%f, %f, %f)\n", X / zv, Y / zv, Z / zv);
    fprintf(stderr, "(%f, %f, %f)\n", (Xm + XM) / 2, (Ym + YM) / 2, (Zm + ZM) / 2);

    if (fclose(fp)) {
        perror("fclose");
    }
    return 0;
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
