// Drives wide_selects.ll with each boolean both ways.
#include <stdio.h>
void pick(double *, const double *, const double *, int);
int main(void) {
    double a[11], b[11], o[11];
    for (int i = 0; i < 11; i++) { a[i] = i + 0.5; b[i] = -i - 0.25; }
    for (int k = 0; k < 7; k++) {
        pick(o, a, b, k);
        float *f = (float *)(o + 4);
        printf("%d: %g %g %g %g | %g %g %g %g | %g %g %g\n", k, o[0], o[1], o[2], o[3], f[0], f[3], f[4], f[7], o[8], o[9], o[10]);
    }
    return 0;
}
