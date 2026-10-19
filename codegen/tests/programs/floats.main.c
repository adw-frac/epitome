// Calls the functions in floats.c.
#include <stdio.h>
#include <math.h>

double poly(double);
float fpoly(float);
double mix(double, float, int, long);
long to_long(double);
unsigned long to_ulong(double);
int to_int(float);
short to_short(double);
double from_long(long);
double from_ulong(unsigned long);
float from_char(signed char);
double widen(float);
float narrow(double);
int compare(double, double);
int fcompare(float, float);
double fmax_of(double, double);
double pick(int, double, double);
double many(double, double, double, double, double, double, double, double, double, double, int, float);
double call_many(double);
double sum(const double *, int);
double dot(const float *, const double *, int);
void scale(double *, int, double);
double norm(double, double);
unsigned long bits_of(double);
double from_bits(unsigned long);
double lookup(int);
int report(double, float, int);

int main(void) {
  double xs[] = {0.0, -0.0, 1.0, -2.5, 3.75, 1e-300, 1e300, 123456.789, -98765.4321, 0.1, NAN, INFINITY, -INFINITY};
  int n = sizeof xs / sizeof xs[0];
  for (int i = 0; i < n; i++) {
    double x = xs[i], y = xs[(i * 5 + 3) % n];
    printf("%.17g %.17g: %.17g %.9g %.17g %d %d %.17g %.17g %lx\n", x, y, poly(x), (double)fpoly((float)x), mix(x, (float)y, i, i * 1000L),
           compare(x, y), fcompare((float)x, (float)y), fmax_of(x, y), pick(i & 1, x, y), bits_of(x));
    if (isfinite(x) && fabs(x) < 1e18) {
      printf("  %ld %d %d %.17g %.17g %.9g\n", to_long(x), to_int((float)x), to_short(x / 8), widen((float)x), (double)narrow(x),
             (double)from_char((signed char)i));
      if (x >= 0) printf("  %lu\n", to_ulong(x));
    }
    printf("  %.17g %.17g %.17g\n", from_long((long)i * 1000000007L), norm(x, y), lookup(i));
  }
  printf("%.17g %.17g\n", from_ulong(18446744073709551615UL), from_bits(0x400921fb54442d18UL));
  printf("%.17g %.17g\n", call_many(1.25), many(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, -3, 2.5f));
  double a[10];
  float f[10];
  for (int i = 0; i < 10; i++) {
    a[i] = i * 1.1;
    f[i] = (float)(i * 0.7);
  }
  scale(a, 10, -0.5);
  printf("%.17g %.17g\n", sum(a, 10), dot(f, a, 10));
  int r = report(1234.5678, 0.333f, 42);
  printf("%d\n", r);
  return 0;
}
