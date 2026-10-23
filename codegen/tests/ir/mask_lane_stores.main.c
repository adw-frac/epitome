// Drives mask_lane_stores.ll on bytes with some `@`s.
#include <stdio.h>
void f(unsigned char *);
int main(void) { const char *t[] = {"--foo=@@", "@@@@@@@@", "abcdefgh", "@b@d@f@h", "a@@@@@@h"}; for (int k = 0; k < 5; k++) { unsigned char b[8]; for (int i = 0; i < 8; i++) b[i] = t[k][i]; f(b); for (int i = 0; i < 8; i++) printf("%02x", b[i]); printf("\n"); } return 0; }
