typedef float v4f __attribute__((vector_size(16)));
typedef int v4i __attribute__((vector_size(16)));
v4f vadd(v4f a, v4f b) { return a + b * 2.0f; }
v4i vshuf(v4i a, v4i b) { return __builtin_shufflevector(a, b, 0, 4, 1, 5); }
float vsum(v4f a) { return a[0] + a[1] + a[2] + a[3]; }
int atom(int *p) { __atomic_fetch_add(p, 1, __ATOMIC_SEQ_CST); int e = 0; __atomic_compare_exchange_n(p, &e, 5, 0, __ATOMIC_ACQ_REL, __ATOMIC_ACQUIRE); return __atomic_load_n(p, __ATOMIC_ACQUIRE); }
_Bool overflow(int a, int b, int *r) { return __builtin_sadd_overflow(a, b, r); }
int bits(unsigned x) { return __builtin_popcount(x) + __builtin_clz(x | 1) + __builtin_ctz(x | 8); }
__int128 big(__int128 a) { return a * ((__int128)1 << 100) + 12345678901234567890ULL; }
_Complex double cmul(_Complex double a, _Complex double b) { return a * b; }
