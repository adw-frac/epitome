// Calls the functions in tails.c, and is called back by them, in tail
// position, millions of times deep.
#include <stdio.h>

long odd_steps(long n, long acc);
long twist(long a, long b, long c, long n);
long with_frame(long n);

long even_steps(long n, long acc) {
    if (n == 0) return acc;
    return odd_steps(n - 1, acc ^ n);
}

long down_by(long n, long k, long acc) {
    (void)k;
    return twist(acc, n, k, n - 1);
}

long counted(long n) { return n * 2; }

int main(void) {
    printf("%ld\n", odd_steps(30000000, 1));
    printf("%ld\n", twist(1, 2, 3, 0));
    printf("%ld\n", with_frame(10));
    return 0;
}
