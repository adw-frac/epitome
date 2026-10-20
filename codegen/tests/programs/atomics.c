// Atomic operations at each width and ordering, on memory main owns:
// read-modify-writes (some with an instruction, some loops), compare and
// swap, strong and weak, ordered loads and stores, and fences.

#define OPS(T, N)                                                                                         \
    T add_##N(T *p, T v) { return __atomic_fetch_add(p, v, __ATOMIC_SEQ_CST); }                          \
    T sub_##N(T *p, T v) { return __atomic_fetch_sub(p, v, __ATOMIC_ACQUIRE); }                          \
    T and_##N(T *p, T v) { return __atomic_fetch_and(p, v, __ATOMIC_RELEASE); }                          \
    T or_##N(T *p, T v) { return __atomic_fetch_or(p, v, __ATOMIC_ACQ_REL); }                            \
    T xor_##N(T *p, T v) { return __atomic_fetch_xor(p, v, __ATOMIC_RELAXED); }                          \
    T nand_##N(T *p, T v) { return __atomic_fetch_nand(p, v, __ATOMIC_SEQ_CST); }                        \
    T max_##N(T *p, T v) { return __atomic_fetch_max(p, v, __ATOMIC_SEQ_CST); }                          \
    T min_##N(T *p, T v) { return __atomic_fetch_min(p, v, __ATOMIC_ACQUIRE); }                          \
    T xchg_##N(T *p, T v) { return __atomic_exchange_n(p, v, __ATOMIC_SEQ_CST); }                        \
    T add_fetch_##N(T *p, T v) { return __atomic_add_fetch(p, v, __ATOMIC_RELEASE); }                    \
    int cas_##N(T *p, T *e, T v) {                                                                        \
        return __atomic_compare_exchange_n(p, e, v, 0, __ATOMIC_SEQ_CST, __ATOMIC_RELAXED);               \
    }                                                                                                     \
    int casw_##N(T *p, T *e, T v) {                                                                       \
        /* A weak one may fail spuriously: again until it says why. */                                    \
        T want = *e;                                                                                      \
        for (;;) {                                                                                        \
            if (__atomic_compare_exchange_n(p, e, v, 1, __ATOMIC_ACQ_REL, __ATOMIC_ACQUIRE)) return 1;    \
            if (*e != want) return 0;                                                                     \
        }                                                                                                 \
    }                                                                                                     \
    T load_##N(T *p) { return __atomic_load_n(p, __ATOMIC_SEQ_CST); }                                     \
    T load_acq_##N(T *p) { return __atomic_load_n(p, __ATOMIC_ACQUIRE); }                                 \
    T load_rlx_##N(T *p) { return __atomic_load_n(p, __ATOMIC_RELAXED); }                                \
    void store_##N(T *p, T v) { __atomic_store_n(p, v, __ATOMIC_SEQ_CST); }                               \
    void store_rel_##N(T *p, T v) { __atomic_store_n(p, v, __ATOMIC_RELEASE); }

OPS(signed char, s8)
OPS(unsigned char, u8)
OPS(short, s16)
OPS(unsigned short, u16)
OPS(int, s32)
OPS(unsigned, u32)
OPS(long long, s64)
OPS(unsigned long long, u64)

double fadd_f64(double *p, double v) { return __atomic_fetch_add(p, v, __ATOMIC_SEQ_CST); }
float fsub_f32(float *p, float v) { return __atomic_fetch_sub(p, v, __ATOMIC_RELAXED); }
double load_f64(double *p) {
    double r;
    __atomic_load(p, &r, __ATOMIC_ACQUIRE);
    return r;
}
void store_f64(double *p, double v) { __atomic_store(p, &v, __ATOMIC_SEQ_CST); }

void *xchg_ptr(void **p, void *v) { return __atomic_exchange_n(p, v, __ATOMIC_ACQ_REL); }
int cas_ptr(void **p, void **e, void *v) {
    return __atomic_compare_exchange_n(p, e, v, 0, __ATOMIC_ACQUIRE, __ATOMIC_ACQUIRE);
}

// A spin lock: test-and-set, then a release.
static unsigned char lock;
static int guarded;
int locked_add(int v) {
    while (__atomic_test_and_set(&lock, __ATOMIC_ACQUIRE))
        ;
    int r = guarded += v;
    __atomic_clear(&lock, __ATOMIC_RELEASE);
    return r;
}

// Message passing through a flag, with fences.
static int data, flag;
void publish(int v) {
    data = v;
    __atomic_thread_fence(__ATOMIC_RELEASE);
    __atomic_store_n(&flag, 1, __ATOMIC_RELAXED);
}
int consume(void) {
    if (!__atomic_load_n(&flag, __ATOMIC_RELAXED)) return -1;
    __atomic_thread_fence(__ATOMIC_ACQUIRE);
    int v = data;
    __atomic_thread_fence(__ATOMIC_SEQ_CST);
    return v;
}
