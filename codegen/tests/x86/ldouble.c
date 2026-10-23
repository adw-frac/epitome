// long double (x86_fp80, on the x87 unit): arithmetic, comparisons (with
// NaNs), conversions to and from floating-point and integer types (unsigned
// ones past 2^63), phis that read each other, and selects.
typedef long double L;
void arith(L *o, const L *a, const L *b, int n) {
    for (int i = 0; i < n; i++) {
        o[5 * i] = a[i] + b[i];
        o[5 * i + 1] = a[i] - b[i];
        o[5 * i + 2] = a[i] * b[i];
        o[5 * i + 3] = a[i] / b[i];
        o[5 * i + 4] = __builtin_fabsl(b[i]) - a[i];
    }
}
int cmp(const L *a, const L *b, int n) {
    int c = 0;
    for (int i = 0; i < n; i++) {
        L x = a[i], y = b[i];
        c = c * 7 + (x < y) + 2 * (x == y) + 4 * (x > y);
        c ^= (x <= y) << 3 | (x >= y) << 4 | (x != y) << 5 | __builtin_isunordered(x, y) << 6;
    }
    return c;
}
void conv(double *d, float *f, long *s, unsigned long *u, int *w, L *o, const L *a, const long *li,
          const unsigned long *ul, const double *di, int n) {
    for (int i = 0; i < n; i++) {
        d[i] = (double)a[i];
        f[i] = (float)a[i];
        s[i] = (long)(a[i] / 3);
        u[i] = a[i] < 0 ? 0 : (unsigned long)a[i];
        w[i] = (int)(a[i] / 1e10L);
        o[4 * i] = (L)li[i];
        o[4 * i + 1] = (L)ul[i];
        o[4 * i + 2] = (L)di[i];
        o[4 * i + 3] = (L)(float)di[i] + (L)w[i];
    }
}
void sum(L *out, const double *x, int n) {
    L s = 0, p = 1;
    for (int i = 0; i < n; i++) {
        L t = s;
        s = p + (L)x[i];
        p = t * 0.5L;
    }
    *out = s * 1.0e300L > p ? s : p;
}
double sumd(const double *x, int n) {
    L r;
    sum(&r, x, n);
    return (double)r;
}
unsigned long big(unsigned long x) {
    L v = (L)x * 2.0L;
    return (unsigned long)(v / 2);
}
