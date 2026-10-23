// Drives module_asm.ll.
#include <stdio.h>
long first(void);
int second_called(void);
int main(void) { printf("%ld %d\n", first(), second_called()); return 0; }
