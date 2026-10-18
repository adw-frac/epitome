// Loops for clang's vectoriser: built with -O2 by the "vec" configuration,
// and without vectorising by the others.
// no-fwrapv

int sum_i32(const int *a, int n) { int s = 0; for (int i = 0; i < n; i++) s += a[i]; return s; }
long sum_i64(const long *a, int n) { long s = 0; for (int i = 0; i < n; i++) s += a[i]; return s; }
void add_i32(int *c, const int *a, const int *b, int n) { for (int i = 0; i < n; i++) c[i] = a[i] + b[i]; }
void mul_i16(short *c, const short *a, const short *b, int n) { for (int i = 0; i < n; i++) c[i] = (short)(a[i] * b[i]); }
void xor_u8(unsigned char *c, const unsigned char *a, unsigned char k, int n) { for (int i = 0; i < n; i++) c[i] = a[i] ^ k; }
void saxpy(float *y, const float *x, float a, int n) { for (int i = 0; i < n; i++) y[i] = a * x[i] + y[i]; }
void scale_f64(double *y, const double *x, double a, int n) { for (int i = 0; i < n; i++) y[i] = x[i] * a; }
int max_i32(const int *a, int n) { int m = a[0]; for (int i = 1; i < n; i++) m = a[i] > m ? a[i] : m; return m; }
unsigned min_u32(const unsigned *a, int n) { unsigned m = ~0u; for (int i = 0; i < n; i++) m = a[i] < m ? a[i] : m; return m; }
void abs_i32(int *c, const int *a, int n) { for (int i = 0; i < n; i++) c[i] = a[i] < 0 ? -a[i] : a[i]; }
void clamp_i32(int *c, const int *a, int lo, int hi, int n) { for (int i = 0; i < n; i++) { int v = a[i]; c[i] = v < lo ? lo : v > hi ? hi : v; } }
long dot_i32(const int *a, const int *b, int n) { long s = 0; for (int i = 0; i < n; i++) s += (long)a[i] * b[i]; return s; }
int sum_bytes(const unsigned char *a, int n) { int s = 0; for (int i = 0; i < n; i++) s += a[i]; return s; }
void widen(int *c, const short *a, int n) { for (int i = 0; i < n; i++) c[i] = a[i] * 3; }
void narrow(short *c, const int *a, int n) { for (int i = 0; i < n; i++) c[i] = (short)(a[i] >> 4); }
void fill(int *c, int v, int n) { for (int i = 0; i < n; i++) c[i] = v + i; }
int count_eq(const int *a, int k, int n) { int c = 0; for (int i = 0; i < n; i++) c += a[i] == k; return c; }
void to_float(float *c, const int *a, int n) { for (int i = 0; i < n; i++) c[i] = (float)a[i] * 0.5f; }
void shift(unsigned *c, const unsigned *a, int n) { for (int i = 0; i < n; i++) c[i] = (a[i] << 3) | (a[i] >> 29); }
double sum_f64(const double *a, int n) { double s = 0; for (int i = 0; i < n; i++) s += a[i]; return s; }
double dot_f32(const float *a, const float *b, int n) { double s = 0; for (int i = 0; i < n; i++) s += (double)a[i] * b[i]; return s; }
void max_f32(float *c, const float *a, const float *b, int n) { for (int i = 0; i < n; i++) c[i] = a[i] > b[i] ? a[i] : b[i]; }
void to_int(int *c, const float *a, int n) { for (int i = 0; i < n; i++) c[i] = (int)a[i]; }
int count_lt(const signed char *a, signed char k, int n) { int c = 0; for (int i = 0; i < n; i++) c += a[i] < k; return c; }
void rgb_gray(unsigned char *g, const unsigned char *rgb, int n) { for (int i = 0; i < n; i++) g[i] = (unsigned char)((rgb[3 * i] * 77 + rgb[3 * i + 1] * 150 + rgb[3 * i + 2] * 29) >> 8); }
void select_i64(long *c, const long *a, const long *b, int n) { for (int i = 0; i < n; i++) c[i] = a[i] < b[i] ? a[i] : b[i] * 2; }
