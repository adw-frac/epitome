// Drives wide_swaps.ll: the bytes before and after.
#include <stdio.h>
#include <string.h>
void swaps(unsigned char *, const unsigned char *);
int main(void) {
    unsigned char a[48], o[48];
    for (int i = 0; i < 48; i++) a[i] = i * 7 + 1;
    memset(o, 0xee, 48);
    swaps(o, a);
    for (int i = 0; i < 48; i++) printf("%02x%s", o[i], i % 16 == 15 ? "\n" : " ");
    return 0;
}
