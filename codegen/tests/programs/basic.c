// Integer functions compiled by smaugian-llc and called from basic.main.c,
// which clang builds. See tests/programs.rs.

int add3(int a, int b, int c) { return a + b * c + 7; }

long fact(long n) { return n <= 1 ? 1 : n * fact(n - 1); }

int fib(int n) { return n < 2 ? n : fib(n - 1) + fib(n - 2); }

int gcd(int a, int b) {
  while (b) {
    int t = a % b;
    a = b;
    b = t;
  }
  return a;
}

unsigned popcount(unsigned x) {
  unsigned n = 0;
  while (x) {
    n += x & 1;
    x >>= 1;
  }
  return n;
}

long sum_array(const int *a, int n) {
  long s = 0;
  for (int i = 0; i < n; i++) s += a[i];
  return s;
}

void reverse(int *a, int n) {
  for (int i = 0, j = n - 1; i < j; i++, j--) {
    int t = a[i];
    a[i] = a[j];
    a[j] = t;
  }
}

int max_of(const int *a, int n) {
  int m = a[0];
  for (int i = 1; i < n; i++)
    if (a[i] > m) m = a[i];
  return m;
}

int classify(int x) {
  switch (x) {
  case 0: return 10;
  case 1: return 20;
  case 5: return 30;
  case 100: return 40;
  default: return -1;
  }
}

int string_length(const char *s) {
  int n = 0;
  while (s[n]) n++;
  return n;
}

unsigned hash(const char *s) {
  unsigned h = 2166136261u;
  while (*s) {
    h ^= (unsigned char)*s++;
    h *= 16777619u;
  }
  return h;
}

long mix(long a, int b, short c, signed char d, unsigned char e) { return a * b - c / (d | 1) + e; }

int global_counter;
int bump(int k) {
  global_counter += k;
  return global_counter;
}

static const int table[8] = {3, 1, 4, 1, 5, 9, 2, 6};
int lookup(int i) { return table[i & 7]; }

struct point {
  int x, y;
  long z;
};
long dot(const struct point *p, const struct point *q) { return (long)p->x * q->x + p->y * q->y + p->z * q->z; }

int many(int a, int b, int c, int d, int e, int f, int g, int h) { return a - b + c - d + e - f + g - h * 2; }
int call_many(int x) { return many(x, x + 1, x + 2, x + 3, x + 4, x + 5, x + 6, x + 7) + many(1, 2, 3, 4, 5, 6, 7, 8); }

long div_mod(long a, long b) { return a / b * 1000 + a % b; }
unsigned udiv_mod(unsigned a, unsigned b) { return a / b + a % b; }

int shifts(int a, unsigned b, int s) { return (a << s) ^ (int)(b >> s) ^ (a >> 3) ^ (a << 5); }

int select_max(int a, int b) { return a > b ? a : b; }
long select_ptr(long *p, long *q, int c) { return *(c ? p : q); }

int bools(int a, int b) { return (a < b) + (a == b) * 2 + (a != 0 && b != 0) * 4 + ((unsigned)a > (unsigned)b) * 8; }

void fill(char *p, int n, char c) {
  for (int i = 0; i < n; i++) p[i] = c;
}

long big_const(long x) { return x * 0x123456789abcLL + 0xdeadbeefLL - 0x7fffffff00000000LL; }
int odd_consts(int x) { return x - 5 + (x & -256) + (x | 0xff00) + (x ^ 0x55555555) + 0x12345678; }

long ptr_diff(const int *a, const int *b) { return b - a; }

int local_array(int n) {
  int a[10];
  for (int i = 0; i < 10; i++) a[i] = i * n;
  int s = 0;
  for (int i = 0; i < 10; i += 3) s += a[i];
  return s;
}

int sum_squares(int n) {
  if (n == 0) return 0;
  return n * n + sum_squares(n - 1);
}

// More values live at once than there are registers.
int pressure(int a, int b) {
  int x1 = a + b, x2 = a - b, x3 = a * b, x4 = a ^ b, x5 = a | b, x6 = a & b, x7 = a + 2 * b, x8 = a - 3 * b;
  int x9 = x1 * x2, x10 = x3 + x4, x11 = x5 - x6, x12 = x7 * x8, x13 = x1 + x9, x14 = x2 + x10;
  int x15 = x3 + x11, x16 = x4 + x12, x17 = x5 * x13, x18 = x6 * x14, x19 = x7 ^ x15, x20 = x8 ^ x16;
  int x21 = x9 + x17, x22 = x10 + x18, x23 = x11 + x19, x24 = x12 + x20, x25 = x13 * x21, x26 = x14 * x22;
  int y = x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10 + x11 + x12 + x13;
  int z = x14 + x15 + x16 + x17 + x18 + x19 + x20 + x21 + x22 + x23 + x24 + x25 + x26;
  return y * 3 + z * 5 + x1 * x26 - x2 * x25;
}

// Values live across calls.
int across_calls(int a) {
  int x = a * 3, y = a + 11, z = a ^ 5;
  int p = fib(10) + x;
  int q = gcd(y, 12) + z;
  return p * 100 + q * 10 + x + y + z;
}

unsigned short narrow(unsigned short a, short b) { return (unsigned short)(a * 3 + b); }
_Bool is_odd(int x) { return x & 1; }
int count_odd(const int *a, int n) {
  int c = 0;
  for (int i = 0; i < n; i++) c += is_odd(a[i]) ? 1 : 0;
  return c;
}
