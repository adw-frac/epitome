// Calls the functions in ldouble.c, and prints the bits of what they make.
#include <stdio.h>
#include <string.h>
typedef long double L;
void arith(L *o, const L *a, const L *b, int n);
int cmp(const L *a, const L *b, int n);
void conv(double *d, float *f, long *s, unsigned long *u, int *w, L *o, const L *a, const long *li,
          const unsigned long *ul, const double *di, int n);
double sumd(const double *x, int n);
unsigned long big(unsigned long x);
static void pl(L v) { unsigned char b[16] = {0}; memcpy(b, &v, 10); for (int k = 9; k >= 0; k--) printf("%02x", b[k]); printf(" "); }
#define N 8
int main(void) {
    L a[N] = {1, -2.5L, 3.14159265358979323846L, 1e4000L, 0.0L, -0.0L, __builtin_nanl(""), 9223372036854775807.0L};
    L b[N] = {3, 0.5L, -1e-300L, 7, 0.0L, 1e-4940L, 1, 18446744073709551615.0L};
    L o[5 * N];
    arith(o, a, b, N);
    for (int i = 0; i < 5 * N; i++) pl(o[i]);
    printf("\n%d %d\n", cmp(a, b, N), cmp(b, a, N));
    L c[N] = {1.5L, -1e18L, 1e18L, 1.8e19L, 255.75L, -7.9L, 4294967296.5L, 12345678901234567.0L};
    long li[N] = {0, -1, 9223372036854775807L, -9223372036854775807L - 1, 42, 1L << 53 | 1, 3, -77};
    unsigned long ul[N] = {0, ~0UL, 1UL << 63, (1UL << 63) + 1, 5, 1UL << 40, 99, 123456789012345UL};
    double di[N] = {0.1, -0.0, 1e308, -3.5, 2.5e-320, 7, 1.0/3, 65504};
    double d[N]; float f[N]; long s[N]; unsigned long u[N]; int w[N]; L lo[4 * N];
    conv(d, f, s, u, w, lo, c, li, ul, di, N);
    for (int i = 0; i < N; i++) printf("%a %a %ld %lu %d\n", d[i], (double)f[i], s[i], u[i], w[i]);
    for (int i = 0; i < 4 * N; i++) pl(lo[i]);
    printf("\n%a %lu %lu\n", sumd(di, N), big(1UL << 63 | 12345), big(77));
    return 0;
}
