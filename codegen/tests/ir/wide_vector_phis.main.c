// Drives wide_vector_phis.ll for a few steps and multipliers.
#include <stdio.h>
void steps(unsigned __int128 *, unsigned long, int);
int main(void) {
    for (int n = 1; n < 40; n += 7)
        for (unsigned long k = 1; k < 100000; k *= 37) {
            unsigned __int128 o[2];
            steps(o, k, n);
            printf("%d %lu: %016llx%016llx %016llx%016llx\n", n, k, (unsigned long long)(o[0] >> 64), (unsigned long long)o[0], (unsigned long long)(o[1] >> 64), (unsigned long long)o[1]);
        }
    return 0;
}
