// Half precision (_Float16): arithmetic, square roots and fused
// multiply-adds, comparisons, conversions both ways, vectors of it, and
// halves passed and returned, in registers and on the stack.
typedef _Float16 h;
typedef _Float16 h4 __attribute__((ext_vector_type(4)));
void arith(h *o, const h *a, const h *b, int n) {
    for (int i = 0; i < n; i++) {
        o[6 * i] = a[i] + b[i];
        o[6 * i + 1] = a[i] - b[i];
        o[6 * i + 2] = a[i] * b[i];
        o[6 * i + 3] = a[i] / b[i];
        o[6 * i + 4] = __builtin_sqrtf16(a[i] < 0 ? -a[i] : a[i]);
        o[6 * i + 5] = __builtin_fmaf16(a[i], b[i], a[i]);
    }
}
void conv(h *o, float *f, double *d, int *s, long *l, const h *a, int n) {
    for (int i = 0; i < n; i++) {
        o[2 * i] = (h)f[i];
        o[2 * i + 1] = (h)d[i];
        f[i] = (float)a[i] * 2;
        d[i] = (double)a[i];
        s[i] = (int)a[i];
        l[i] = (long)(h)(l[i]);
    }
}
int cmp(const h *a, const h *b, int n) {
    int c = 0;
    for (int i = 0; i < n; i++) c = c * 3 + (a[i] < b[i]) + 2 * (a[i] == b[i]);
    return c;
}
void vec(h4 *o, const h4 *a, const h4 *b) { *o = *a * *b + *a; }
h hadd(h a, h b) { return a + b; }
h hmany(double a0, double a1, double a2, double a3, double a4, double a5, double a6, h x, h y, int k) { return x * y + (h)k; }
float hwiden(h x, float f) { return (float)x * f; }
h hcall(h x) { return hadd(x, (h)1.5) * hmany(0, 0, 0, 0, 0, 0, 0, x, x, 3); }
