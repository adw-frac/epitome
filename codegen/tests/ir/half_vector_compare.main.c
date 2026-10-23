// Drives half_vector_compare.ll on numbers, zeros of each sign and an infinity.
#include <stdio.h>
void f(unsigned char *, const unsigned short *, const unsigned short *);
int main(void) { unsigned short a[8] = {0x3c00, 0x4000, 0xbc00, 0x0000, 0x3c00, 0x7c00, 0x3800, 0x4200}, b[8] = {0x4000, 0x3c00, 0x3c00, 0x8000, 0x3c00, 0x7bff, 0x3c00, 0x4400}; unsigned char o[8]; f(o, a, b); for (int i = 0; i < 8; i++) printf("%d", o[i]); printf("\n"); return 0; }
