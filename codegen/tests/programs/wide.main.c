// Calls the functions in wide.c and prints what they return, in hex
// halves.
#include <stdio.h>

typedef __int128 i128;
typedef unsigned __int128 u128;

u128 mul_wide(unsigned long, unsigned long);
i128 mac(i128, long, long);
u128 shl(u128, int);
u128 shr(u128, int);
i128 sar(i128, int);
u128 rot(u128);
int cmp(i128, i128);
u128 udiv(u128, u128);
i128 sdiv(i128, i128);
u128 umod(u128, u128);
long narrow(i128);
i128 widen(int);
u128 odd_place(long, u128, long);
u128 last_place(long, long, long, long, long, long, long, u128);
u128 total(const u128 *, int);
void fill(u128 *, int, u128);
long sum_to(long, long);
u128 callback(u128 (*)(u128, int), u128);

static void show(const char *what, u128 x) {
    printf("%s %016lx%016lx\n", what, (unsigned long)(x >> 64), (unsigned long)x);
}

static u128 twist(u128 x, int n) { return (x << n) ^ (x >> (128 - n)); }

int main(void) {
    u128 big = ((u128)0x0123456789abcdefUL << 64) | 0xfedcba9876543210UL;
    show("mul", mul_wide(0xffffffffffffffffUL, 0xfffffffffffffffeUL));
    show("mac", (u128)mac(-5, -3000000000000L, 7000000000000L));
    for (int n = 0; n < 128; n += 13) {
        show("shl", shl(big, n));
        show("shr", shr(big, n));
        show("sar", (u128)sar((i128)big | ((i128)1 << 127), n));
    }
    show("rot", rot(big));
    i128 xs[] = {0, 1, -1, (i128)big, -(i128)big, (i128)1 << 100};
    for (int i = 0; i < 6; i++)
        for (int j = 0; j < 6; j++) printf("%d", cmp(xs[i], xs[j]));
    printf("\n");
    show("udiv", udiv(big, 0x1000000007UL));
    show("sdiv", (u128)sdiv(-(i128)big, 12345));
    show("umod", umod(big, 1000000007));
    printf("%ld %ld\n", narrow(-(i128)big), narrow((i128)big));
    show("widen", (u128)widen(-42));
    show("odd", odd_place(1, big, 2));
    show("last", last_place(1, 2, 3, 4, 5, 6, 7, big));
    u128 arr[10];
    fill(arr, 10, big >> 4);
    show("total", total(arr, 10));
    printf("%ld %ld %ld\n", sum_to(10, 0), sum_to(100000, 5), sum_to(0, 9));
    show("callback", callback(twist, big));
    return 0;
}
