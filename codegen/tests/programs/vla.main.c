// Calls the functions in vla.c and prints what they return.
#include <stdio.h>

long squares(int n);
long in_loop(int n);
double matrix(int n);

void fill(char *p, int n) {
    for (int i = 0; i < n; i++) p[i] = (char)(i + n);
}
long many(long a, long b, long c, long d, long e, long f, long g, long h, long i, long j) {
    return a + b * 2 + c + d + e + f + g + h + i * 10 + j * 100;
}

int main(void) {
    printf("%ld %ld %ld\n", squares(1), squares(10), squares(1000));
    printf("%ld %ld\n", in_loop(1), in_loop(60));
    printf("%g %g\n", matrix(1), matrix(17));
    return 0;
}
