// Calls the functions in half.c and prints the bits of what they give.
#include <stdio.h>
#include <string.h>
typedef _Float16 h;
typedef _Float16 h4 __attribute__((ext_vector_type(4)));
void arith(h *, const h *, const h *, int);
void conv(h *, float *, double *, int *, long *, const h *, int);
int cmp(const h *, const h *, int);
void vec(h4 *, const h4 *, const h4 *);
h hadd(h, h); h hmany(double, double, double, double, double, double, double, h, h, int); float hwiden(h, float); h hcall(h);
static unsigned hbits(h x) { unsigned short u; memcpy(&u, &x, 2); return u; }
static void bits(const h *x, int n) { for (int i = 0; i < n; i++) { unsigned short u; memcpy(&u, &x[i], 2); printf("%04x ", u); } printf("\n"); }
int main(void) {
    enum { N = 12 };
    h a[N], b[N], o[6 * N];
    float vals[N] = {1, -2.5f, 3.14159f, 65504, 1e-7f, -0.0f, 1000.3f, 0.333333f, 7, -65519, 2049, 6e-5f};
    for (int i = 0; i < N; i++) { a[i] = (h)vals[i]; b[i] = (h)(vals[(i + 5) % N] * 0.7f + 0.1f); }
    arith(o, a, b, N); bits(o, 6 * N);
    float f[N]; double d[N]; int s[N]; long l[N];
    for (int i = 0; i < N; i++) { f[i] = vals[i] * 1.0001f; d[i] = vals[i] * 0.999999; l[i] = (long)i * 4097 - 3 + (i == 3 ? (1L << 40) : 0); }
    conv(o, f, d, s, l, a, N); bits(o, 2 * N);
    for (int i = 0; i < N; i++) printf("%a %a %d %ld\n", f[i], d[i], s[i], l[i]);
    printf("%d\n", cmp(a, b, N));
    h4 x = {1.5, -2, 3, 1e-3}, y = {2, 0.5, -1, 1e4}, z; vec(&z, &x, &y); bits((h *)&z, 4);
    printf("%04x %04x %g %04x\n", hbits(hadd(1.25, 2.5)), hbits(hmany(1, 2, 3, 4, 5, 6, 7, 1.5, -3, 7)), hwiden(0.1, 3), hbits(hcall(2.25)));
    return 0;
}
