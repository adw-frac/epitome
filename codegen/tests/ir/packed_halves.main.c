// Drives packed_halves.ll over a few starting values and lengths.
#include <stdio.h>
void f(unsigned *, const unsigned *, long);
int main(void) {
  for (int t = 0; t < 12; t++) {
    unsigned in[2] = {0x9e3779b9u * (t + 1), 0x7f4a7c15u ^ (unsigned)t}, out[2];
    f(out, in, 1 + 3 * t);
    printf("%08x %08x\n", out[0], out[1]);
  }
  return 0;
}
