// Drives mask_fields.ll on each mask of four lanes.
#include <stdio.h>
void f(unsigned char *, const int *, const int *);
int main(void) { for (int m = 0; m < 16; m++) { int a[4], b[4]; unsigned char o[2]; for (int i = 0; i < 4; i++) { a[i] = 0; b[i] = (m >> i) & 1; } f(o, a, b); printf("%d %d\n", o[0], o[1]); } return 0; }
