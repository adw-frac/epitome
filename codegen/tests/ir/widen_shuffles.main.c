// Drives widen_shuffles.ll.
#include <stdio.h>
void widen(void *, const int *, const float *, short);
int main(void) {
    int a[2] = {111, -222}; float b[2] = {1.25f, -3.5f}; unsigned char o[52];
    widen(o, a, b, 1234);
    int *i = (int *)o; float *f = (float *)(o + 16); short *h = (short *)(o + 32);
    printf("%d %d %d %d | %g %g %g %g | %d %d %d %d %d %d %d %d | %d\n", i[0], i[1], i[2], i[3], f[0], f[1], f[2], f[3], h[0], h[1], h[2], h[3], h[4], h[5], h[6], h[7], *(int *)(o + 48));
    return 0;
}
