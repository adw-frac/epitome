// Drives huge_integers.ll on random words.
#include <stdio.h>
void f(unsigned long *, const unsigned long *, const unsigned long *, int);
int main(void) {
  unsigned long s = 77;
  for (int t = 0; t < 6; t++) {
    unsigned long a[18], b[18], o[93] = {0};
    for (int i = 0; i < 18; i++) { s = s * 6364136223846793005ul + 1442695040888963407ul; a[i] = s; s = s * 6364136223846793005ul + 1; b[i] = t == 3 ? a[i] : s; }
    f(o, a, b, 1 + t);
    unsigned long h = 0; for (int i = 0; i < 93; i++) h = h * 1000003 ^ o[i];
    printf("%016lx %016lx %016lx %016lx\n", h, o[0], o[17], o[36]);
  }
  return 0;
}
