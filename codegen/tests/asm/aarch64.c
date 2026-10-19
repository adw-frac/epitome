// Inline assembly for AArch64: each constraint and modifier kind, early
// clobbers, tied and fixed registers, numeric labels, clobbers, memory.

long add_x(long a, long b) { long r; __asm__("add %0, %1, %2" : "=r"(r) : "r"(a), "r"(b)); return r; }
int add_w(int a, int b) { int r; __asm__("add %w0, %w1, %w2" : "=r"(r) : "r"(a), "r"(b)); return r; }
int add_I(int a) { int r; __asm__("add %w0, %w1, %2" : "=r"(r) : "r"(a), "I"(4095)); return r; }
int sub_i(int a) { int r; __asm__("sub %w0, %w1, #%2" : "=r"(r) : "r"(a), "i"(7)); return r; }
int tied(int a) { __asm__("add %w0, %w0, #1" : "+r"(a)); return a; }
int load(int *p) { int r; __asm__("ldr %w0, %1" : "=r"(r) : "m"(*p)); return r; }
void store(int *p, int v) { __asm__ volatile("str %w1, %0" : "=m"(*p) : "r"(v)); }
double fadd(double a, double b) { double r; __asm__("fadd %d0, %d1, %d2" : "=w"(r) : "w"(a), "w"(b)); return r; }
float fmul(float a, float b) { float r; __asm__("fmul %s0, %s1, %s2" : "=w"(r) : "w"(a), "w"(b)); return r; }
long early(long a, long b) {
    long r;
    __asm__("mov %0, #1\n\tadd %0, %0, %1\n\tadd %0, %0, %2" : "=&r"(r) : "r"(a), "r"(b));
    return r;
}
long sum_to(long n) {
    long s = 0;
    __asm__("1: cbz %1, 2f\n\tadd %0, %0, %1\n\tsub %1, %1, #1\n\tb 1b\n2:" : "+r"(s), "+r"(n));
    return s;
}
long pair(long *p) { long a, b; __asm__("ldp %0, %1, [%2]" : "=r"(a), "=r"(b) : "r"(p)); return a * 10 + b; }
long fixed(long a) { register long x9 __asm__("x9") = a; __asm__("add x9, x9, x9" : "+r"(x9)); return x9; }
long clobber(long a) { long r; __asm__("mov x10, %1\n\tadd %0, x10, #3" : "=r"(r) : "r"(a) : "x10"); return r; }
// Writes x19, which the caller expects kept: the frame must save it.
long saved(long a) { __asm__ volatile("mov x19, #5" ::: "x19"); return a + 1; }
int zero(int a) { int r; __asm__("add %w0, %w1, %w2" : "=r"(r) : "r"(a), "rZ"(0)); return r; }
void barrier(void) { __asm__ volatile("" ::: "memory"); }
// %= is unique to each expansion: twice in one function.
static inline __attribute__((always_inline)) long twice(long a) {
    long r;
    __asm__("mov %0, %1\n\tb .Lskip%=\n\tmov %0, #0\n.Lskip%=:" : "=r"(r) : "r"(a));
    return r;
}
long uid(long a) { return twice(a) + twice(a + 1); }
