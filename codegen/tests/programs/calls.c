// Calls: more arguments than there are registers, arguments of mixed
// sizes on the stack, function pointers, and variadic calls to printf.
int printf(const char *, ...);

long many(int a, long b, char c, short d, int e, long f, unsigned char g, int h, char i, short j, int k, long l,
          unsigned short m, int n) {
  return a + b * 2 + c * 3 + d * 4 + e * 5 + f * 6 + g * 7 + h * 8 + i * 9 + j * 10 + k * 11 + l * 12 + m * 13 + n * 14;
}

long call_many(int x) {
  return many(x, x + 1, (char)(x + 2), (short)(x + 3), x + 4, x + 5, (unsigned char)(x + 6), x + 7, (char)(x + 8),
              (short)(x + 9), x + 10, x + 11, (unsigned short)(x + 12), x + 13);
}

// Arguments that arrive on the stack, passed on in other places.
long forward(int a, int b, int c, int d, int e, int f, int g, int h, char i, long j) {
  return many(h, g, (char)f, (short)e, d, c, (unsigned char)b, a, i, (short)j, a + i, j, (unsigned short)b, c) + i + j;
}

long call_forward(int x) { return forward(x, x * 2, x * 3, x * 4, x * 5, x * 6, x * 7, x * 8, (char)(x - 1), x * 1000L); }

int report(const char *name, int a, long b, unsigned c, char d) { return printf("%s: %d %ld %u %c\n", name, a, b, c, d); }

// More variable arguments than there are registers.
int report_many(int x) {
  return printf("%d %d %d %d %d %d %d %d %d %d %ld %s\n", x, x + 1, x + 2, x + 3, x + 4, x + 5, x + 6, x + 7, x + 8,
                x + 9, (long)x * 1000000, "end");
}

long apply(long (*f)(int), int x) { return f(x) + f(x + 1); }
long twice(int x) { return 2L * x; }
long use_apply(int x) { return apply(twice, x) + apply(call_many, x); }

// Small structs passed by value: clang passes them as [2 x i64], in two
// registers if both fit, or else on the stack.
struct pair {
  long a, b;
};
long sum_pair(struct pair p) { return p.a * 3 + p.b; }
long late_pair(int a, int b, int c, int d, int e, int f, int g, struct pair p) { return a + g + p.a - p.b; }
long call_pairs(long x) {
  struct pair p = {x, x + 1};
  return sum_pair(p) + late_pair(1, 2, 3, 4, 5, 6, 7, p);
}
