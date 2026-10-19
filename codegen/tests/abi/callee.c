// Functions taking arguments on the stack, for tests/abi.rs. `char` is
// signed on Apple's platforms and unsigned on Linux, so it is spelt out.

long many(int a, long b, signed char c, short d, int e, long f, unsigned char g, int h, signed char i, short j, int k, long l,
          unsigned short m, int n) {
  return a + b * 2 + c * 3 + d * 4 + e * 5 + f * 6 + g * 7 + h * 8 + i * 9 + j * 10 + k * 11 + l * 12 + m * 13 + n * 14;
}

long sum10(long a, long b, long c, long d, long e, long f, long g, long h, long i, long j) {
  return a + 2 * b + 3 * c + 4 * d + 5 * e + 6 * f + 7 * g + 8 * h + 9 * i + 10 * j;
}

// Small types past the registers: packed on Apple's stack, 8-byte slots in
// AAPCS64's.
int small(int a, int b, int c, int d, int e, int f, int g, int h, signed char i, signed char j, short k, int l, unsigned char m,
          long n) {
  return a - b + c - d + e - f + g - h + i * 2 + j * 3 + k * 4 + l * 5 + m * 6 + (int)(n >> 30);
}

// Takes arguments on the stack and passes others on.
long relay(int a, int b, int c, int d, int e, int f, int g, int h, signed char i, long j) {
  return many(h, g, (signed char)f, (short)e, d, c, (unsigned char)b, a, i, (short)j, a + i, j, (unsigned short)b, c) +
         small(a, b, c, d, e, f, g, h, i, (signed char)(i + 1), (short)j, (int)j, (unsigned char)a, j) + i + j;
}

// An __int128 starts in an even register in AAPCS64 (x2, here, not x1), and
// goes on the stack, 16-aligned, when a pair is not left.
__int128 wide_odd(long a, __int128 b, long c) { return b * 3 + a - c; }
__int128 wide_late(long a, long b, long c, long d, long e, long f, long g, __int128 x, long y) {
  return x + a + b + c + d + e + f + g - y;
}

// A struct too big for registers comes back through the address in x8.
struct big { long a, b, c, d, e; };
struct big make_big(long x, int y) {
  struct big r = {x, x * y, x - y, x + y, y};
  return r;
}

// Variadic: AAPCS64 puts variable arguments where named ones would go, and
// va_arg finds them in the register save areas va_start makes, then on the
// stack. Integers and doubles, more of each than fit in registers.
#include <stdarg.h>
double vmix(int n, double scale, ...) {
  va_list ap, again;
  va_start(ap, scale);
  va_copy(again, ap);
  double s = 0;
  for (int i = 0; i < n; i++) {
    long k = va_arg(ap, long);
    double d = va_arg(ap, double);
    s += k * scale + d;
  }
  // The copy reads them again.
  long first = va_arg(again, long);
  va_end(again);
  va_end(ap);
  return s + first;
}
