// Drives address_bits.ll: the address's bits come back whole.
#include <stdio.h>
#include <string.h>
int low(void *), round_trip(void);
float pick(int, float);
void *base(void);
int main(void) {
  char *g = base();
  float f = pick(0, 1.0f); unsigned u; memcpy(&u, &f, 4);
  printf("%d %d %d %d %f\n", low(g + 8), low(g), round_trip(), u == (unsigned)(unsigned long)g, pick(1, 2.5f));
  return 0;
}
