long double ld = 1.1L;
__float128 q = 2.5;
long double addl(long double a, long double b) { return a * b + 0.1L; }
__float128 addq(__float128 a) { return a + q; }
_Float16 h(_Float16 a) { return a * (_Float16)0.3; }
__bf16 bf(__bf16 a) { return a; }
int gotos(int x) { static void *t[] = {&&a, &&b}; goto *t[x & 1]; a: return 1; b: return 2; }
int asmf(int x) { int r; __asm__ volatile("bswap %0" : "=r"(r) : "0"(x) : "memory"); return r; }
int ga(int x) { asm goto("jmp %l1" :: "r"(x) :: out); return 0; out: return 1; }
void __attribute__((weak)) wk(void) {}
int target_alias(void) { return 0; }
int alias_fn(void) __attribute__((alias("target_alias")));
static int (*resolve(void))(void) { return target_alias; }
int ifn(void) __attribute__((ifunc("resolve")));
_Thread_local int tl = 5;
