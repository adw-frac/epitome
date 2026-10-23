// Drives clean_bools.ll over small values, bytes with high bits set, and both arguments.
#include <stdio.h>
#include <stdbool.h>
long f(long, long, unsigned char, bool);
int main(void) {
  for (long a = 5; a < 10; a++)
    for (long b = 6; b < 9; b++)
      for (int t = 0; t < 4; t++)
        printf("%ld", f(a, b, (unsigned char)(t * 0x7f), t & 2));
  printf("\n");
  return 0;
}
