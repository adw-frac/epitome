// Drives caller.ll with arrays, and prints what comes back.
#include <stdio.h>
void cw(long *, long *, long *); void ct(float *, float *, float); void cb(signed char *, signed char *, signed char *);
void cf8(float *, float *, float *); void ci3(int *, int *); void cq(signed char *, signed char *); long clate(long *);
int main(void) {
    long a[4] = {10, 20, 30, 1L << 40}, b[4] = {1, 2, 3, 4}, o[4];
    cw(o, a, b); printf("%ld %ld %ld %ld\n", o[0], o[1], o[2], o[3]);
    float f[4] = {1.5f, 2.5f, 3.5f, 99}, g[4] = {0, 0, 0, 77};
    ct(g, f, 2); printf("%g %g %g %g\n", g[0], g[1], g[2], g[3]);
    signed char c[2] = {100, -7}, d[2] = {-100, 9}, e[2];
    cb(e, c, d); printf("%d %d\n", e[0], e[1]);
    float x[8], y[8], z[8]; for (int i = 0; i < 8; i++) { x[i] = i * 3; y[i] = i; }
    cf8(z, x, y); for (int i = 0; i < 8; i++) printf("%g ", z[i]); printf("\n");
    int p[4] = {1, 2, 3, 55}, r[4] = {0, 0, 0, 66}; ci3(r, p); printf("%d %d %d %d\n", r[0], r[1], r[2], r[3]);
    signed char s[4] = {1, 2, 30, 40}, t[4]; cq(t, s); printf("%d %d %d %d\n", t[0], t[1], t[2], t[3]);
    printf("%ld\n", clate(a));
    return 0;
}
