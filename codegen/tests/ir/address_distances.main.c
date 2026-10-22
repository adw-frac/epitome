// Drives address_distances.ll.
#include <stdio.h>
long dist(void *), stored(void);
void *at(long);
int main(void) { for (long k = 0; k < 4; k++) printf("%ld ", dist(at(k))); printf("%ld\n", stored()); return 0; }
