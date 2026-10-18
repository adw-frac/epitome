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
