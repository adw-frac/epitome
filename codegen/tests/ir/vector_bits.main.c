// Drives vector_bits.ll on random words.
#include <stdio.h>
int bits(const unsigned *);
int main(void) {
    unsigned s = 11;
    for (int t = 0; t < 30; t++) { unsigned v[4]; for (int i = 0; i < 4; i++) { s = s * 1103515245 + 12345; v[i] = s; } printf("%02x ", bits(v)); }
    printf("\n");
    return 0;
}
