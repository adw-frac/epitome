// Floating point: arithmetic, conversions, comparisons (with NaN), calls
// with floating-point arguments on the stack, and printf of doubles.
int printf(const char *, ...);

double poly(double x) { return ((3.5 * x - 2.25) * x + 1.0) * x - 7.0; }
float fpoly(float x) { return (x * x - 1.5f) / (x + 0.25f); }
double mix(double a, float b, int c, long d) { return a * b + c - d / 2.0; }

long to_long(double x) { return (long)x; }
unsigned long to_ulong(double x) { return (unsigned long)x; }
int to_int(float x) { return (int)x; }
short to_short(double x) { return (short)x; }
double from_long(long x) { return (double)x; }
double from_ulong(unsigned long x) { return (double)x; }
float from_char(signed char c) { return c; }
double widen(float x) { return x; }
float narrow(double x) { return (float)x; }

int compare(double a, double b) {
  return (a == b) + (a != b) * 2 + (a < b) * 4 + (a <= b) * 8 + (a > b) * 16 + (a >= b) * 32 + (!(a < b)) * 64 +
         (!(a >= b)) * 128 + (a != a) * 256;
}
int fcompare(float a, float b) { return (a < b) + (a > b) * 2 + (a == b) * 4; }
double fmax_of(double a, double b) { return a > b ? a : b; }
double pick(int c, double a, double b) { return c ? a : b; }

double many(double a, double b, double c, double d, double e, double f, double g, double h, double i, double j, int k,
            float l) {
  return a + 2 * b + 3 * c + 4 * d + 5 * e + 6 * f + 7 * g + 8 * h + 9 * i + 10 * j + k + l;
}
double call_many(double x) { return many(x, x + 1, x + 2, x + 3, x + 4, x + 5, x + 6, x + 7, x + 8, x + 9, 11, 0.5f); }

double sum(const double *a, int n) {
  double s = 0;
  for (int i = 0; i < n; i++) s += a[i];
  return s;
}
double dot(const float *a, const double *b, int n) {
  double s = 0;
  for (int i = 0; i < n; i++) s += a[i] * b[i];
  return s;
}
void scale(double *a, int n, double k) {
  for (int i = 0; i < n; i++) a[i] = a[i] * k + 1;
}

double fabs(double);
double sqrt(double);
double norm(double x, double y) { return sqrt(x * x + y * y) + fabs(x - y); }

unsigned long bits_of(double x) {
  union { double d; unsigned long u; } v;
  v.d = x;
  return v.u;
}
double from_bits(unsigned long u) {
  union { double d; unsigned long u; } v;
  v.u = u;
  return v.d;
}

double table[4] = {1.5, -2.25, 1e100, 0.1};
double lookup(int i) { return table[i & 3] * 2; }

int report(double a, float b, int c) { return printf("%.17g %.9g %d %f %e\n", a, (double)b, c, a / 3, a * 1e10); }
