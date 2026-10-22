// Drives odd_lanes.ll on random bytes.
#include <stdio.h>
void f(long *, const unsigned char *, const unsigned char *, const unsigned char *);
int main(void) { unsigned s = 7; for (int t = 0; t < 30; t++) { unsigned char a[8], b[8], c[8]; long o[9]; for (int i = 0; i < 8; i++) { s = s * 1103515245 + 12345; a[i] = s >> 8; b[i] = s >> 16; c[i] = s >> 24; } f(o, a, b, c); for (int i = 0; i < 9; i++) printf("%ld ", o[i]); printf("\n"); } return 0; }
