// Calls the functions in atomics.c on values at every place in a word (so
// that the narrow ones, done on the word holding them where the machine
// has no narrow instructions, must leave their neighbours as they were),
// and prints what they return and what memory holds after.
#include <stdio.h>

#define DECL(T, N)                                                                                       \
    T add_##N(T *, T), sub_##N(T *, T), and_##N(T *, T), or_##N(T *, T), xor_##N(T *, T);               \
    T nand_##N(T *, T), max_##N(T *, T), min_##N(T *, T), xchg_##N(T *, T), add_fetch_##N(T *, T);      \
    int cas_##N(T *, T *, T), casw_##N(T *, T *, T);                                                     \
    T load_##N(T *), load_acq_##N(T *), load_rlx_##N(T *);                                               \
    void store_##N(T *, T), store_rel_##N(T *, T);

DECL(signed char, s8)
DECL(unsigned char, u8)
DECL(short, s16)
DECL(unsigned short, u16)
DECL(int, s32)
DECL(unsigned, u32)
DECL(long long, s64)
DECL(unsigned long long, u64)
double fadd_f64(double *, double), load_f64(double *);
float fsub_f32(float *, float);
void store_f64(double *, double);
void *xchg_ptr(void **, void *);
int cas_ptr(void **, void **, void *);
int locked_add(int);
void publish(int);
int consume(void);

static union {
    unsigned long long q[2];
    unsigned char b[16];
} mem;

static void fill(void) {
    for (int i = 0; i < 16; i++) mem.b[i] = (unsigned char)(0x11 * (i + 1) ^ 0x5a);
}

static void dump(const char *what) {
    printf("%-10s", what);
    for (int i = 0; i < 16; i++) printf(" %02x", mem.b[i]);
    printf("\n");
}

static const long long operands[] = {0, 1, -1, 0x7f, 0x80, 0x5555, -0x8000, 0x12345678, -0x7fffffffLL - 1,
                                     0x123456789abcdef0LL};

#define RUN(T, N, F)                                                                                     \
    for (unsigned i = 0; i < sizeof operands / sizeof operands[0]; i++)                                 \
        for (unsigned at = 0; at < 16; at += sizeof(T)) {                                                \
            fill();                                                                                       \
            T *p = (T *)&mem.b[at];                                                                       \
            T old = F##_##N(p, (T)operands[i]);                                                           \
            printf(#F " " #N " %u %llx -> %llx;", at, (unsigned long long)(T)operands[i],                \
                   (unsigned long long)old);                                                              \
            dump("");                                                                                     \
        }

#define CAS(T, N, F)                                                                                     \
    for (unsigned i = 0; i < sizeof operands / sizeof operands[0]; i++)                                 \
        for (unsigned at = 0; at < 16; at += sizeof(T)) {                                                \
            fill();                                                                                       \
            T *p = (T *)&mem.b[at];                                                                       \
            T e = (i & 1) ? *p : (T)operands[i];                                                          \
            int ok = F##_##N(p, &e, (T)operands[i]);                                                      \
            printf(#F " " #N " %u %d %llx;", at, ok, (unsigned long long)e);                             \
            dump("");                                                                                     \
        }

#define ALL(T, N)                                                                                        \
    RUN(T, N, add) RUN(T, N, sub) RUN(T, N, and) RUN(T, N, or) RUN(T, N, xor) RUN(T, N, nand)            \
    RUN(T, N, max) RUN(T, N, min) RUN(T, N, xchg) RUN(T, N, add_fetch)                                  \
    CAS(T, N, cas) CAS(T, N, casw)                                                                       \
    for (unsigned at = 0; at < 16; at += sizeof(T)) {                                                    \
        fill();                                                                                           \
        T *p = (T *)&mem.b[at];                                                                           \
        printf("loads " #N " %u %llx %llx %llx;", at, (unsigned long long)load_##N(p),                   \
               (unsigned long long)load_acq_##N(p), (unsigned long long)load_rlx_##N(p));                \
        store_##N(p, (T)0x0123456789abcdefLL);                                                            \
        store_rel_##N(p + (at + 2 * sizeof(T) <= 16 ? 1 : 0), (T)-2);                                     \
        dump("stores");                                                                                   \
    }

int main(void) {
    ALL(signed char, s8)
    ALL(unsigned char, u8)
    ALL(short, s16)
    ALL(unsigned short, u16)
    ALL(int, s32)
    ALL(unsigned, u32)
    ALL(long long, s64)
    ALL(unsigned long long, u64)

    double d = 1.5;
    float f = 10.0f;
    for (int i = 0; i < 4; i++) {
        double was = fadd_f64(&d, 0.25 * i);
        float fwas = fsub_f32(&f, 1.5f);
        printf("fadd %g -> %g; fsub %g -> %g\n", was, d, (double)fwas, (double)f);
    }
    store_f64(&d, -3.0);
    printf("double %g\n", load_f64(&d));

    int x, y;
    void *slot = &x;
    void *was = xchg_ptr(&slot, &y);
    printf("xchg ptr %d %d\n", was == &x, slot == &y);
    void *e = &x;
    int ok = cas_ptr(&slot, &e, &x);
    printf("cas ptr %d %d %d\n", ok, e == &y, slot == &y);
    ok = cas_ptr(&slot, &e, &x);
    printf("cas ptr %d %d\n", ok, slot == &x);

    int sum = 0;
    for (int i = 1; i <= 10; i++) sum = locked_add(i);
    printf("locked %d\n", sum);
    printf("consume %d\n", consume());
    publish(42);
    printf("consume %d\n", consume());
    return 0;
}
