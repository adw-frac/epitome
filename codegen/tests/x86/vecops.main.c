// Calls the functions in vecops.c and prints their results' bytes.
#include <stdio.h>
#include <string.h>
typedef signed char s8 __attribute__((vector_size(16)));
typedef unsigned char u8 __attribute__((vector_size(16)));
typedef short s16 __attribute__((vector_size(16)));
typedef unsigned short u16 __attribute__((vector_size(16)));
typedef int s32 __attribute__((vector_size(16)));
typedef unsigned u32 __attribute__((vector_size(16)));
typedef float f32 __attribute__((vector_size(16)));
typedef double f64 __attribute__((vector_size(16)));
#define DECL(T, N) void cmp_##N(T *, T, T);
DECL(s8, s8) DECL(u8, u8) DECL(s16, s16) DECL(u16, u16) DECL(s32, s32) DECL(u32, u32)
s32 mul32(s32, s32); u32 mulu32(u32, u32); f32 negf(f32, f32); f64 negd(f64); f32 absf(f32); f64 absd(f64);
static void show(const void *p, int n) { const unsigned char *b = p; for (int i = 0; i < n; i++) printf("%02x", b[i]); printf("\n"); }
static unsigned seed = 12345;
static unsigned rnd(void) { seed = seed * 1103515245 + 12345; return seed >> 7; }
static void fill(void *p) { unsigned char *b = p; for (int i = 0; i < 16; i++) { unsigned r = rnd(); b[i] = (r & 7) == 0 ? 0x80 : (r & 7) == 1 ? 0x7f : (r & 7) == 2 ? 0xff : r; } }
int main(void) {
    for (int t = 0; t < 4; t++) {
        unsigned char a[16], b[16], o[8 * 16];
        fill(a); fill(b);
        if (t == 1) memcpy(b, a, 16);
        if (t == 2) for (int i = 0; i < 16; i += 2) b[i] = a[i];
#define RUN(T, N) { T x, y; memcpy(&x, a, 16); memcpy(&y, b, 16); cmp_##N((T *)o, x, y); show(o, 8 * 16); }
        RUN(s8, s8) RUN(u8, u8) RUN(s16, s16) RUN(u16, u16) RUN(s32, s32) RUN(u32, u32)
        { s32 x, y; memcpy(&x, a, 16); memcpy(&y, b, 16); s32 r = mul32(x, y); show(&r, 16); }
        { u32 x, y; memcpy(&x, a, 16); memcpy(&y, b, 16); u32 r = mulu32(x, y); show(&r, 16); }
        { f32 x = {1.5f, -2.0f, 0.0f, -0.0f}, y = {3.0f, 4.0f, -1.0f, 2.0f}; f32 r = negf(x, y); show(&r, 16); r = absf(x); show(&r, 16); }
        { f64 x = {-1.25, 0.0}; f64 r = negd(x); show(&r, 16); r = absd(x); show(&r, 16); }
    }
    return 0;
}
