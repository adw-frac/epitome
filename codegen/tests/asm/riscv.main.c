// Calls the functions of riscv.ll (or riscv.ref.c) and prints what they
// return.
#include <stdio.h>

long add_r(long, long);
int addw_r(int, int);
long add_I(long);
long add_reg_or_imm(long, long);
long shift_K(long);
long or_zero(long);
int tied(int);
int load(int *);
void store(int *, int);
long amo(long *);
double fadd(double, double);
float fmul(float, float);
long early(long, long);
long sum_to(long);
long pair(long *);
long fixed(long);
long clobber(long);
long saved(long);
void barrier(void);
long uid(long);

int main(void) {
    int x = 41;
    long p[2] = {3, 4};
    printf("%ld %d %ld %ld %ld %ld %d\n", add_r(1L << 40, 5), addw_r(0x7fffffff, 1), add_I(5000), add_reg_or_imm(7, 8),
           shift_K(3), or_zero(99), tied(9));
    store(&x, load(&x) + 1);
    barrier();
    printf("%d %ld %g %g\n", x, amo(p), fadd(1.5, 2.25), (double)fmul(3.0f, -0.5f));
    printf("%ld %ld %ld %ld %ld\n", early(10, 20), sum_to(100), pair(p), fixed(21), clobber(39));
    long keep = 1000;
    for (int i = 0; i < 3; i++) keep += saved(i) * keep;
    printf("%ld %ld\n", keep, uid(5));
    return 0;
}
