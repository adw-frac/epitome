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
