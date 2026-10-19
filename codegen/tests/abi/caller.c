// Calls the functions in callee.c with arguments on the stack.

long many(int, long, signed char, short, int, long, unsigned char, int, signed char, short, int, long, unsigned short, int);
long sum10(long, long, long, long, long, long, long, long, long, long);
int small(int, int, int, int, int, int, int, int, signed char, signed char, short, int, unsigned char, long);
long relay(int, int, int, int, int, int, int, int, signed char, long);

long run_many(int x) {
  return many(x, x + 1, (signed char)(x + 2), (short)(x * 300), x + 4, -x * 100000L, (unsigned char)(x + 6), x + 7,
              (signed char)(x - 8), (short)(-x * 9), x + 10, (long)x << 33, (unsigned short)(x * 1000), x + 13);
}

long run_sum10(long x) { return sum10(x, x + 1, x + 2, x + 3, x + 4, x + 5, x + 6, x + 7, x * 1000, -x * 77); }

long run_small(int x) {
  return small(x, x + 1, x + 2, x + 3, x + 4, x + 5, x + 6, x + 7, (signed char)(x + 8), (signed char)-(x + 9), (short)(x * 100), x * 7,
               (unsigned char)(x + 200), (long)x << 35);
}

long run_relay(int x) { return relay(x, x * 2, x * 3, x * 4, x * 5, x * 6, x * 7, x * 8, (signed char)(x - 1), x * 100000L); }

__int128 wide_odd(long, __int128, long);
__int128 wide_late(long, long, long, long, long, long, long, __int128, long);
struct big { long a, b, c, d, e; };
struct big make_big(long, int);

long run_wide(long x) {
  __int128 big = ((__int128)x << 70) | (unsigned long)(x * 12345);
  __int128 r = wide_odd(x, big, x * 3) + wide_late(1, 2, 3, 4, 5, 6, 7, big, x);
  return (long)(r >> 64) ^ (long)r;
}

long run_big(long x) {
  struct big b = make_big(x, (int)x + 3);
  return b.a + b.b * 2 + b.c * 3 + b.d * 4 + b.e * 5;
}

double vmix(int, double, ...);

long run_vmix(long x) {
  double a = vmix(2, 0.5, x, 1.25, x * 2, 2.5);
  double b = vmix(9, 2.0, x, 0.5, x + 1, 1.5, x + 2, 2.5, x + 3, 3.5, x + 4, 4.5, x + 5, 5.5, x + 6, 6.5, x + 7, 7.5, x + 8,
                  8.5);
  return (long)(a * 100) + (long)(b * 10);
}
