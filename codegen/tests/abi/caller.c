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

typedef float v4f __attribute__((vector_size(16)));
struct f3 { float x, y, z; };
struct d4 { double a, b, c, d; };
struct q2 { v4f a, b; };
float hfa_late(double, double, double, double, double, double, double, struct f3, float, struct f3, int, struct d4);
struct d4 hfa_rev(struct d4, double _Complex);
struct q2 hfa_vec(struct q2, v4f);
float vec_late(v4f, v4f, v4f, v4f, v4f, v4f, v4f, float, v4f, v4f, v4f);

long run_hfa(long x) {
  float k = (float)x;
  struct f3 v = {k, k + 1, k + 2}, w = {k * 2, k * 3, k * 4};
  struct d4 d = {x, x * 2.5, x - 7, x * x};
  float a = hfa_late(1, 2, 3, 4, 5, 6, 7, v, k / 4, w, (int)x * 3, d);
  double _Complex z = (double)x + 2.0i * (double)x;
  struct d4 r = hfa_rev(d, z);
  v4f q0 = {k, k + 1, k + 2, k + 3}, q1 = {1, 2, 3, 4};
  struct q2 q = hfa_vec((struct q2){q0, q1}, (v4f){k, 2, k, 4});
  v4f s[10];
  for (int i = 0; i < 10; i++) s[i] = (v4f){i + k, i * 2 + k, i * 3 + k, i * 4 + k};
  float b = vec_late(s[0], s[1], s[2], s[3], s[4], s[5], s[6], k * 3, s[7], s[8], s[9]);
  return (long)(a * 10) + (long)(r.a + r.b * 3 + r.c * 5 + r.d * 7) + (long)(q.a[0] + q.a[3] * 3 + q.b[1] * 5 + q.b[2] * 7) +
         (long)(b * 100);
}
