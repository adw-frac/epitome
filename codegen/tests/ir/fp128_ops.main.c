// Drives fp128_ops.ll on quad-precision values given by their bits (one,
// halves, large and small numbers, zeros of each sign, infinities, NaNs)
// and doubles.
// links: compiler-builtins
#include <stdio.h>
#include <string.h>
void arith(unsigned char *, const unsigned char *, const unsigned char *);
void compare(unsigned char *, const unsigned char *, const unsigned char *);
void convert(unsigned char *, const unsigned char *, const double *);
void calls(unsigned char *, const unsigned char *, const unsigned char *, int);
// Little-endian halves: high is sign, exponent and the mantissa's top.
static void q(unsigned char *b, unsigned long long hi, unsigned long long lo) { memcpy(b, &lo, 8); memcpy(b + 8, &hi, 8); }
static void show(const unsigned char *b, int n) { for (int i = n - 1; i >= 0; i--) printf("%02x", b[i]); printf(" "); }
int main(void) {
  unsigned long long v[][2] = {
    {0x3fff000000000000ull, 0}, {0xbfff000000000000ull, 0}, {0x3ffe000000000000ull, 0},
    {0x4000800000000000ull, 0x123456789abcdefull}, {0x401e000000000000ull, 0x5555}, {0x3f00123456789abcull, 0x1},
    {0, 0}, {0x8000000000000000ull, 0}, {0x7fff000000000000ull, 0}, {0xffff000000000000ull, 0},
    {0x7fff800000000000ull, 0}, {0x4005c00000000000ull, 0x8000000000000000ull}, {0xc03e000000000000ull, 0},
  };
  int n = sizeof v / sizeof v[0];
  for (int i = 0; i < n; i++) for (int j = 0; j < n; j++) {
    unsigned char a[16], b[16], o[128] = {0};
    q(a, v[i][0], v[i][1]); q(b, v[j][0], v[j][1]);
    arith(o, a, b); for (int k = 0; k < 8; k++) show(o + 16 * k, 16);
    compare(o, a, b); show(o, 14);
    printf("\n");
  }
  double d[] = {0.0, -0.0, 1.0, -1.5, 3.25e10, -7.0e-300, 1.0e300, 123456789.0, -2147483649.0};
  for (int i = 0; i < 9; i++) for (int j = 0; j < n; j++) {
    unsigned char a[16], o[128] = {0};
    q(a, v[j][0], v[j][1]);
    convert(o, a, &d[i]);
    show(o, 8); show(o + 8, 4); show(o + 12, 2); for (int k = 1; k < 8; k++) show(o + 16 * k, 16); printf("\n");
  }
  for (int i = 0; i < n; i++) {
    unsigned char a[16], b[16], o[16];
    q(a, v[i][0], v[i][1]); q(b, v[(i + 3) % n][0], v[(i + 3) % n][1]);
    calls(o, a, b, 1 + i % 5); show(o, 16); printf("\n");
  }
  return 0;
}
