// Calls the variadic functions in varargs.c.
#include <stdio.h>

long vsum(int, ...);
long vmixed(const char *, ...);
long vlate(int, int, int, int, int, int, int, int, int, ...);
int format(char *, unsigned long, const char *, ...);

int main(void) {
  printf("%ld %ld %ld\n", vsum(0), vsum(3, 1L, 2L, 3L), vsum(10, 1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L, 9L, 10000000000L));
  printf("%ld\n", vmixed("ilsil", 5, 1L << 40, "x", -3, -7L));
  printf("%ld\n", vlate(1, 2, 3, 4, 5, 6, 7, 8, 9, 42, 99L));
  char buf[100];
  int n = format(buf, sizeof buf, "%d-%s-%ld-%c", 12, "abc", -5L, 'z');
  printf("%d %s\n", n, buf);
  return 0;
}
