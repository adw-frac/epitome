// Drives masks_moved.ll on random data.
#include <stdio.h>
unsigned char halves(const double *); _Bool pair(const float *); unsigned short pick(const unsigned char *, const unsigned char *); void join(float *, const float *, const float *);
int main(void) {
    unsigned s = 3;
    for (int t = 0; t < 40; t++) {
        double d[8]; float f[2], g[2], o[4]; unsigned char a[16], b[16]; int x[8], y[8];
        for (int i = 0; i < 8; i++) { s = s * 1103515245 + 12345; d[i] = (s >> 16) % 3 ? 2.0 * (i + 1) : 1.0; x[i] = (int)(s >> 8) - (1 << 22); y[i] = (int)s; }
        for (int i = 0; i < 16; i++) { s = s * 1103515245 + 12345; a[i] = s >> 16; b[i] = (s >> 20) % 4 ? a[i] : s >> 8; }
        f[0] = (int)(s % 7) - 3; f[1] = (int)(s % 5) - 2; g[0] = s % 11; g[1] = -(float)(s % 13);
        join(o, f, g);
        printf("%02x %d %04x %g %g %g %g\n", halves(d), pair(f), pick(a, b), o[0], o[1], o[2], o[3]);
    }
    return 0;
}
