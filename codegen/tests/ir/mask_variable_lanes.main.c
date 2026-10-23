// Drives mask_variable_lanes.ll on each lane.
#include <stdio.h>
unsigned char get(const int *, const int *, long);
void set(int *, const int *, const int *, long, _Bool);
int main(void) {
  int a[4] = {1, 5, -3, 8}, b[4] = {2, 4, -3, 9}, o[4];
  for (long k = 0; k < 4; k++) {
    printf("%d", get(a, b, k));
    for (int v = 0; v < 2; v++) { set(o, a, b, k, v); printf(" %d,%d,%d,%d", o[0], o[1], o[2], o[3]); }
    printf("\n");
  }
  return 0;
}
