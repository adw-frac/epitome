// Drives pointer_vector_splats.ll on null, @g and another address.
#include <stdio.h>
void f(unsigned char *, void **);
void *gaddr(void);
int main(void) {
  int x; void *g = gaddr();
  void *in[4][2] = {{0, 0}, {g, 0}, {&x, g}, {&x, &x}};
  for (int k = 0; k < 4; k++) {
    unsigned char o[24] __attribute__((aligned(8)));
    f(o, in[k]);
    void **s = (void **)(o + 8);
    printf("%d %d %d %d %d %d\n", o[0], o[1], o[2], o[3], s[0] == g ? 1 : s[0] == &x ? 2 : 0, s[1] == g ? 1 : s[1] == &x ? 2 : 0);
  }
  return 0;
}
