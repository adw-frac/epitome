// Calls atomics_lib.c's functions, from four threads too: none of the
// increments may be lost.
#include <stdio.h>
#include <pthread.h>
typedef struct __attribute__((packed)) { char c; int x; long l; } P;
extern __int128 g; extern P p;
__int128 ld(void); void st(__int128); __int128 add(__int128); __int128 xchg(__int128); int cas(__int128 *, __int128);
__int128 *bigs(int);
int mis(int); long misl(long); int misld(void); void misst(long); int miscas(int *, int); __int128 amax(__int128);
static void *worker(void *arg) { for (int i = 0; i < 100000; i++) { add(((__int128)1 << 64) + 1); mis(1); } return arg; }
int main(void) {
    st(((__int128)5 << 64) | 7);
    __int128 a = add(((__int128)1 << 63) * 2 + 3);
    __int128 x = xchg(42), e = 42; int c1 = cas(&e, 99); e = 0; int c2 = cas(&e, 1);
    printf("%llx %llx %llx %d %d %llx %llx\n", (unsigned long long)(a >> 64), (unsigned long long)a, (unsigned long long)x, c1, c2, (unsigned long long)e, (unsigned long long)ld());
    misst(0x1234); printf("%d %ld %d ", mis(5), misl(0xff), misld()); int me = 5; printf("%d %d %d\n", miscas(&me, 9), me, misld());
    printf("%llx\n", (unsigned long long)amax(77));
    st(0); p.x = 0;
    pthread_t t[4]; for (int i = 0; i < 4; i++) pthread_create(&t[i], 0, worker, 0); for (int i = 0; i < 4; i++) pthread_join(t[i], 0);
    __int128 v = ld(); printf("%llx %llx %d\n", (unsigned long long)(v >> 64), (unsigned long long)v, misld());
    for (int k = 0; k < 2; k++) { __int128 b = *bigs(k); printf("%llx %llx\n", (unsigned long long)(b >> 64), (unsigned long long)b); }
    return 0;
}
