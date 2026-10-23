// Drives extended_bools.ll with matching and other values, both sides of
// the float compare, and both booleans.
#include <stdio.h>
int f(short, double, const unsigned char *);
int main(void) {
  unsigned char t = 1, u = 0;
  short as[] = {26211, 26210, 0};
  double xs[] = {0.5, 1.5, 2.0};
  for (int i = 0; i < 3; i++)
    for (int j = 0; j < 3; j++)
      printf("%d %d ", f(as[i], xs[j], &t), f(as[i], xs[j], &u));
  printf("\n");
  return 0;
}
