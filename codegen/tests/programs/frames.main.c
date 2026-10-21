// Calls the functions in frames.c and prints what they return.
#include <stdio.h>

long big_frame(int n);
long medium_frame(int n);
long odd_frame(int k);

void touch(char *p, int n) {
    for (int i = 0; i < n; i++) p[i] = (char)(i * 7 + 1);
}
long mix(long a, long b) { return a * 31 + b; }

int main(void) {
    printf("%ld %ld\n", big_frame(3), big_frame(1000));
    printf("%ld %ld\n", medium_frame(2), medium_frame(77));
    printf("%ld %ld\n", odd_frame(5), odd_frame(67000));
    return 0;
}
