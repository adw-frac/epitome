// Drives neon_pairs.ll on random words.
#include <stdio.h>
void p(unsigned *, const unsigned *, const unsigned *);
int main(void) { unsigned s = 3; for (int t = 0; t < 10; t++) { unsigned a[2], b[2], o[2]; for (int i = 0; i < 2; i++) { s = s * 1103515245 + 12345; a[i] = s; s = s * 1103515245 + 12345; b[i] = s; } p(o, a, b); printf("%08x %08x\n", o[0], o[1]); } return 0; }
