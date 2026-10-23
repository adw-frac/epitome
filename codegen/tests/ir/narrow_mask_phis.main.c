// Drives narrow_mask_phis.ll on runs of bytes.
#include <stdio.h>
void f(long *, const unsigned char *, long);
int main(void) {
  unsigned s = 9;
  for (int t = 0; t < 20; t++) {
    unsigned char b[32]; long o[3];
    for (int i = 0; i < 32; i++) { s = s * 1103515245 + 12345; b[i] = (s >> 16) % 11 + 1; }
    f(o, b, 2 + 2 * (t % 16));
    printf("%ld %ld %ld\n", o[0], o[1], o[2]);
  }
  return 0;
}
