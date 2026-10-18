// Calls the functions in calls.c, including with stack arguments from here.
#include <stdio.h>

long many(int, long, char, short, int, long, unsigned char, int, char, short, int, long, unsigned short, int);
long call_many(int);
long forward(int, int, int, int, int, int, int, int, char, long);
long call_forward(int);
int report(const char *, int, long, unsigned, char);
int report_many(int);
long use_apply(int);
struct pair { long a, b; };
long sum_pair(struct pair);
long call_pairs(long);

int main(void) {
  for (int x = -3; x < 40; x += 7) {
    printf("%d: %ld %ld %ld\n", x, call_many(x), call_forward(x), use_apply(x));
    printf("  %ld %ld\n", many(x, -x, 'a', 1000, x * x, 1L << 40, 200, -7, 'z', -300, 99, -(1L << 33), 65000, x),
           forward(1, 2, 3, 4, 5, 6, 7, 8, (char)x, -12345678901L));
  }
  struct pair q = {7, -9};
  printf("pairs %ld %ld\n", sum_pair(q), call_pairs(1000));
  int n = report("first", -42, 1L << 50, 4000000000u, 'Q');
  n += report_many(5);
  printf("%d characters\n", n);
  return 0;
}
