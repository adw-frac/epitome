// Inline assembly for x86-64 (AT&T): each constraint and modifier kind,
// early clobbers, tied and fixed registers, numeric labels, clobbers,
// memory.

long add_q(long a, long b) { long r; __asm__("leaq (%1,%2), %0" : "=r"(r) : "r"(a), "r"(b)); return r; }
int add_k(long a, long b) { int r; __asm__("leal (%q1,%q2), %k0" : "=r"(r) : "r"(a), "r"(b)); return r; }
int add_i(int a) { __asm__("addl %1, %0" : "+r"(a) : "i"(7)); return a; }
int add_c(int a) { int r; __asm__("leal %c2(%q1), %0" : "=r"(r) : "r"(a), "i"(100)); return r; }
int add_e(long a) { long r; __asm__("movq %1, %0\n\taddq %2, %0" : "=&r"(r) : "r"(a), "e"(-5)); return (int)r; }
int shift(int a) { __asm__("shll %1, %0" : "+r"(a) : "I"(3)); return a; }
int load(int *p) { int r; __asm__("movl %1, %0" : "=r"(r) : "m"(*p)); return r; }
void store(int *p, int v) { __asm__ volatile("movl %1, %0" : "=m"(*p) : "r"(v)); }
double fadd(double a, double b) { __asm__("addsd %1, %0" : "+x"(a) : "x"(b)); return a; }
float fmul(float a, float b) { __asm__("mulss %1, %0" : "+x"(a) : "x"(b)); return a; }
long early(long a, long b) {
    long r;
    __asm__("movq $1, %0\n\taddq %1, %0\n\taddq %2, %0" : "=&r"(r) : "r"(a), "r"(b));
    return r;
}
long sum_to(long n) {
    long s = 0;
    __asm__("1: testq %1, %1\n\tjz 2f\n\taddq %1, %0\n\tdecq %1\n\tjmp 1b\n2:" : "+r"(s), "+r"(n));
    return s;
}
long byte(long a) { long r = a; __asm__("notb %b0" : "+q"(r)); return r; }
long word(long a) { long r = a; __asm__("incw %w0" : "+r"(r)); return r; }
long fixed(long a) { register long r9 __asm__("r9") = a; __asm__("addq %%r9, %%r9" : "+r"(r9)); return r9; }
long clobber(long a) { long r; __asm__("movq %1, %%r10\n\tleaq 3(%%r10), %0" : "=r"(r) : "r"(a) : "r10"); return r; }
// Writes rbx, which the caller expects kept: the frame must save it.
long saved(long a) { __asm__ volatile("movl $5, %%ebx" ::: "rbx"); return a + 1; }
void barrier(void) { __asm__ volatile("" ::: "memory"); }
// %= is unique to each expansion: twice in one function.
static inline __attribute__((always_inline)) long twice(long a) {
    long r;
    __asm__("movq %1, %0\n\tjmp .Lskip%=\n\tmovq $0, %0\n.Lskip%=:" : "=r"(r) : "r"(a));
    return r;
}
long uid(long a) { return twice(a) + twice(a + 1); }
