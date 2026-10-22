// Drives mask_inserts.ll.
#include <stdio.h>
void f(unsigned char *, const unsigned char *);
int main(void) { unsigned char a = 1, o[8]; f(o, &a); for (int i = 0; i < 8; i++) printf("%d", o[i]); printf("\n"); return 0; }
