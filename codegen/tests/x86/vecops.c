// Vector operations SSE2 does in a few instructions (gen_sel.py's
// sse_recipes): every comparison of 8-, 16- and 32-bit lanes, signed and
// unsigned; 32-bit multiplication; the least and greatest; a float's
// sign flipped and cleared.
typedef signed char s8 __attribute__((vector_size(16)));
typedef unsigned char u8 __attribute__((vector_size(16)));
typedef short s16 __attribute__((vector_size(16)));
typedef unsigned short u16 __attribute__((vector_size(16)));
typedef int s32 __attribute__((vector_size(16)));
typedef unsigned u32 __attribute__((vector_size(16)));
typedef float f32 __attribute__((vector_size(16)));
typedef double f64 __attribute__((vector_size(16)));
#define CMPS(T, N) \
    void cmp_##N(T *o, T a, T b) { \
        o[0] = a == b; o[1] = a != b; o[2] = a < b; o[3] = a <= b; o[4] = a > b; o[5] = a >= b; \
        o[6] = __builtin_elementwise_min(a, b); o[7] = __builtin_elementwise_max(a, b); \
    }
CMPS(s8, s8)
CMPS(u8, u8)
CMPS(s16, s16)
CMPS(u16, u16)
CMPS(s32, s32)
CMPS(u32, u32)
s32 mul32(s32 a, s32 b) { return a * b + (a * 3); }
u32 mulu32(u32 a, u32 b) { return a * b; }
f32 negf(f32 a, f32 b) { return -a * b; }
f64 negd(f64 a) { return -a; }
f32 absf(f32 a) { return __builtin_elementwise_abs(a); }
f64 absd(f64 a) { return __builtin_elementwise_abs(a); }
