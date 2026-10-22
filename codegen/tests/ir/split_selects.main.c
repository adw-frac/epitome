// Drives split_selects.ll.
#include <stdio.h>
void pick(unsigned char *, const unsigned char *, const unsigned char *, _Bool);
double late(int);
int main(void) {
    unsigned char a[4] = {1, 2, 3, 4}, b[4] = {9, 8, 7, 6}, o[4];
    for (int c = 0; c < 2; c++) { pick(o, a, b, c); printf("%d %d %d %d\n", o[0], o[1], o[2], o[3]); }
    for (int n = 1; n < 8; n++) printf("%g ", late(n));
    printf("\n");
    return 0;
}
