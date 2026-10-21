// Calls the functions in tls.c, and reads and writes the variables they
// use (one, shared, defined here) directly and through their addresses.
#include <stdio.h>

struct pair {
    int a;
    long long b;
};

extern __thread long long counter;
extern __thread int zeroed;
extern __thread unsigned char bytes[5];
extern __thread struct pair pt;
__thread int shared = 100;

long long bump(long long);
int count_up(int);
int sum_bytes(void);
long long pair_sum(void);
short *hidden_at(void);
int add_shared(int);

int main(void) {
    printf("%lld %lld\n", bump(2), bump(-50));
    printf("%lld\n", counter);
    printf("%d %d\n", count_up(10), count_up(3));
    zeroed = 1;
    printf("%d\n", count_up(2));
    printf("%d %d\n", sum_bytes(), sum_bytes());
    printf("%d\n", bytes[2]);
    printf("%lld %lld\n", pair_sum(), pair_sum());
    printf("%d %lld\n", pt.a, pt.b);
    short *h = hidden_at();
    printf("%d\n", *h);
    *h = 1234;
    printf("%d %d\n", *hidden_at(), h == hidden_at());
    printf("%d %d\n", add_shared(5), add_shared(-200));
    printf("%d\n", shared);
    long long *c = &counter;
    *c = 7;
    printf("%lld\n", bump(1));
    return 0;
}
