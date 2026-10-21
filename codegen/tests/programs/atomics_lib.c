// Atomics the C library does: of 128 bits, and of memory not aligned to
// their size (a packed struct's fields). And 128-bit integers in data.
typedef struct __attribute__((packed)) { char c; int x; long l; } P;
__int128 g; P p; _Atomic __int128 ga;
__int128 ld(void) { return __atomic_load_n(&g, __ATOMIC_SEQ_CST); }
void st(__int128 v) { __atomic_store_n(&g, v, __ATOMIC_RELEASE); }
__int128 add(__int128 v) { return __atomic_fetch_add(&g, v, __ATOMIC_SEQ_CST); }
__int128 xchg(__int128 v) { return __atomic_exchange_n(&g, v, __ATOMIC_ACQ_REL); }
int cas(__int128 *e, __int128 v) { return __atomic_compare_exchange_n(&g, e, v, 0, __ATOMIC_SEQ_CST, __ATOMIC_ACQUIRE); }
int mis(int v) { return __atomic_fetch_add(&p.x, v, __ATOMIC_SEQ_CST); }
long misl(long v) { return __atomic_fetch_xor(&p.l, v, __ATOMIC_RELAXED); }
int misld(void) { return __atomic_load_n(&p.x, __ATOMIC_ACQUIRE); }
void misst(long v) { __atomic_store_n(&p.l, v, __ATOMIC_SEQ_CST); }
int miscas(int *e, int v) { return __atomic_compare_exchange_n(&p.x, e, v, 0, __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST); }
__int128 amax(__int128 v) { __int128 o = ga; while (o < v && !__atomic_compare_exchange_n((__int128 *)&ga, &o, v, 1, __ATOMIC_SEQ_CST, __ATOMIC_RELAXED)); return o; }
__int128 big = ((__int128)0x1122334455667788 << 64) | 0x99aabbccddeeff00;
__int128 minus = -3;
__int128 *bigs(int k) { return k ? &minus : &big; }
