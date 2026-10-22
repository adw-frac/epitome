// Drives wide_products.ll on random 128-bit numbers, and edges.
#include <stdio.h>
void products(unsigned __int128 *, const unsigned __int128 *, const unsigned __int128 *);
int main(void) {
    unsigned long long s = 0x9e3779b97f4a7c15ull;
    for (int t = 0; t < 40; t++) {
        unsigned __int128 a, b, o[2];
        s = s * 6364136223846793005ull + 1442695040888963407ull; a = ((unsigned __int128)s << 64);
        s = s * 6364136223846793005ull + 1442695040888963407ull; a |= s;
        s = s * 6364136223846793005ull + 1442695040888963407ull; b = ((unsigned __int128)s << 64);
        s = s * 6364136223846793005ull + 1442695040888963407ull; b |= s;
        if (t == 0) a = b = ~(unsigned __int128)0;
        if (t == 1) b >>= 70;
        products(o, &a, &b);
        printf("%016llx%016llx %016llx%016llx\n", (unsigned long long)(o[0] >> 64), (unsigned long long)o[0], (unsigned long long)(o[1] >> 64), (unsigned long long)o[1]);
    }
    return 0;
}
