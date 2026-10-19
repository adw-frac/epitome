// Calls the functions in aarch64.c and prints what they return.
#include <stdio.h>

long add_x(long, long);
int add_w(int, int);
int add_I(int);
int sub_i(int);
int tied(int);
int load(int *);
void store(int *, int);
double fadd(double, double);
float fmul(float, float);
long early(long, long);
long sum_to(long);
long pair(long *);
long fixed(long);
long clobber(long);
long saved(long);
int zero(int);
void barrier(void);
long uid(long);

int main(void) {
    int x = 41;
    long p[2] = {3, 4};
    printf("%ld %d %d %d %d\n", add_x(1L << 40, 5), add_w(-7, 3), add_I(1), sub_i(10), tied(9));
    store(&x, load(&x) + 1);
    barrier();
    printf("%d %g %g\n", x, fadd(1.5, 2.25), (double)fmul(3.0f, -0.5f));
    printf("%ld %ld %ld %ld %ld\n", early(10, 20), sum_to(100), pair(p), fixed(21), clobber(39));
    long keep = 1000;
    for (int i = 0; i < 3; i++) keep += saved(i) * keep;
    printf("%ld %d %ld\n", keep, zero(17), uid(5));
    return 0;
}
