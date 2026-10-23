// Calls the functions in x86.c and prints what they return.
#include <stdio.h>

long add_q(long, long);
int add_k(long, long);
int add_i(int);
int add_c(int);
int add_e(long);
int shift(int);
int load(int *);
void store(int *, int);
double fadd(double, double);
float fmul(float, float);
long early(long, long);
long sum_to(long);
long byte(long);
long word(long);
long fixed(long);
long clobber(long);
long saved(long);
void barrier(void);
long uid(long);

int main(void) {
    int x = 41;
    printf("%ld %d %d %d %d %d\n", add_q(1L << 40, 5), add_k(-7, 3), add_i(1), add_c(10), add_e(9), shift(5));
    store(&x, load(&x) + 1);
    barrier();
    printf("%d %g %g\n", x, fadd(1.5, 2.25), (double)fmul(3.0f, -0.5f));
    printf("%ld %ld %lx %lx %ld %ld\n", early(10, 20), sum_to(100), byte(0x1234), word(0x1ffff), fixed(21), clobber(39));
    long keep = 1000;
    for (int i = 0; i < 3; i++) keep += saved(i) * keep;
    printf("%ld %ld\n", keep, uid(5));
    return 0;
}
