// Small helpers that the inliner should take, and larger ones it should
// weigh against code size.
#include <stdio.h>

static inline int clamp(int x, int lo, int hi) { return x < lo ? lo : x > hi ? hi : x; }

static int sq(int x) { return x * x; }

// Branches on a mode argument that is constant at each call.
static int apply(int mode, int a, int b) {
    switch (mode) {
    case 0: return a + b;
    case 1: return a - b;
    case 2: return a * b;
    case 3: return b ? a / b : 0;
    default: return a ^ b;
    }
}

// Called once: inlining it removes the function entirely.
static long checksum(const int *v, int n) {
    long h = 1469598103;
    for (int i = 0; i < n; i++) {
        h ^= v[i];
        h *= 1099511628211L;
        h ^= h >> 29;
        h += (long)i * 0x9E3779B97F4A7C15L;
        h ^= h << 7;
        h = (h << 13) | ((unsigned long)h >> 51);
    }
    return h;
}

// Takes the address of a caller's local.
static void accumulate(long *acc, int v) { *acc += sq(v) - clamp(v, -5, 5); }

// A bigger function called from many places: only worth inlining at -O3.
static int mix(int a, int b, int c) {
    int x = a * 31 + b;
    x ^= x >> 3;
    x += c * 17;
    x ^= x << 5;
    x += (a ^ b ^ c) * 13;
    x ^= x >> 7;
    x += a * b - c;
    x ^= x << 11;
    x += sq(a) + sq(b) + sq(c);
    x ^= x >> 2;
    x += clamp(a - b, -100, 100) * clamp(c, 0, 50);
    x ^= x << 3;
    return x;
}

// Never returns normally: calls to it are cold.
static void fail(const char *msg, int code) {
    printf("fatal: %s %d\n", msg, code);
    fflush(stdout);
    __builtin_trap();
}

int main(int argc, char **argv) {
    (void)argv;
    int k = argc + 6; // 7
    int v[64];
    for (int i = 0; i < 64; i++) v[i] = clamp(i * k - 100, -50, 200);
    long acc = 0;
    for (int i = 0; i < 64; i++) accumulate(&acc, v[i]);
    printf("acc %ld\n", acc);
    printf("apply %d %d %d %d %d\n", apply(0, k, 3), apply(1, k, 3), apply(2, k, 3), apply(3, k, 3), apply(9, k, 3));
    printf("checksum %ld\n", checksum(v, 64));
    int m = 0;
    for (int i = 0; i < 10; i++) m += mix(i, k, m & 15);
    printf("mix %d %d %d\n", m, mix(1, 2, 3), mix(k, k, k));
    if (m == 12345) fail("unexpected", m);
    return 0;
}
