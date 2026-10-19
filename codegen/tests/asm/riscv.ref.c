// What riscv.ll's functions do, in C: the expected output's source.
#include <string.h>

long add_r(long a, long b) { return a + b; }
int addw_r(int a, int b) { return a + b; }
long add_I(long a) { return a - 2048; }
long add_reg_or_imm(long a, long b) { return a + b; }
long shift_K(long a) { return (long)((unsigned long)a << 31); }
long or_zero(long a) { return a; }
int tied(int a) { return a + 1; }
int load(int *p) { return *p; }
void store(int *p, int v) { *p = v; }
long amo(long *p) { return *p; }
double fadd(double a, double b) { return a + b; }
float fmul(float a, float b) { return a * b; }
long early(long a, long b) { return 1 + a + b; }
long sum_to(long n) { long s = 0; for (; n; n--) s += n; return s; }
long pair(long *p) { return p[0] * 10 + p[1]; }
long fixed(long a) { return a + a; }
long clobber(long a) { return a + 3; }
long saved(long a) { return a + 1; }
void barrier(void) {}
long uid(long a) { return a + a + 1; }
