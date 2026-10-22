// Drives wide_overflow.ll: the largest power of each base in 128 bits.
#include <stdio.h>
int powers(unsigned __int128 *, unsigned long);
int main(void) {
    unsigned long bases[] = {2, 3, 10, 255, 65537, 4294967311ul, 18446744073709551557ul};
    for (int i = 0; i < 7; i++) {
        unsigned __int128 v;
        int n = powers(&v, bases[i]);
        printf("%lu: %d %016llx%016llx\n", bases[i], n, (unsigned long long)(v >> 64), (unsigned long long)v);
    }
    return 0;
}
