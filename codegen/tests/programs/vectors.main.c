// Calls the loops in vectors.c, at lengths around the vector widths, and
// prints checksums of what they compute.
#include <stdio.h>

int sum_i32(const int *, int);
long sum_i64(const long *, int);
void add_i32(int *, const int *, const int *, int);
void mul_i16(short *, const short *, const short *, int);
void xor_u8(unsigned char *, const unsigned char *, unsigned char, int);
void saxpy(float *, const float *, float, int);
void scale_f64(double *, const double *, double, int);
int max_i32(const int *, int);
unsigned min_u32(const unsigned *, int);
void abs_i32(int *, const int *, int);
void clamp_i32(int *, const int *, int, int, int);
long dot_i32(const int *, const int *, int);
int sum_bytes(const unsigned char *, int);
void widen(int *, const short *, int);
void narrow(short *, const int *, int);
void fill(int *, int, int);
int count_eq(const int *, int, int);
void to_float(float *, const int *, int);
void shift(unsigned *, const unsigned *, int);
double sum_f64(const double *, int);
double dot_f32(const float *, const float *, int);
void max_f32(float *, const float *, const float *, int);
void to_int(int *, const float *, int);
int count_lt(const signed char *, signed char, int);
void rgb_gray(unsigned char *, const unsigned char *, int);
void select_i64(long *, const long *, const long *, int);

#define N 1000
static int ia[N], ib[N], ic[N];
static long la[N], lb[N], lc[N];
static short sa[N], sb[N], sc[N];
static unsigned char ua[3 * N], uc[N];
static signed char ca[N];
static float fa[N], fb[N], fc[N];
static double da[N], dc[N];

static unsigned long mix(unsigned long h, unsigned long v) { return (h ^ v) * 1099511628211ul; }

#define HASH(arr, n)                                                       \
  do {                                                                     \
    unsigned long h = 14695981039346656037ul;                              \
    for (int k = 0; k < (n); k++) h = mix(h, (unsigned long)(arr)[k]);     \
    printf(" %lx", h);                                                     \
  } while (0)

static void reset(void) {
  for (int i = 0; i < N; i++) {
    ia[i] = (i * 7919) % 2001 - 1000;
    ib[i] = (i * 104729) % 1999 - 999;
    ic[i] = -1;
    la[i] = (long)i * 1000003 - 400000000;
    lb[i] = 300000000 - (long)i * 999983;
    lc[i] = -1;
    sa[i] = (short)((i * 31) % 361 - 180);
    sb[i] = (short)((i * 17) % 181 - 90);
    sc[i] = -1;
    uc[i] = 0xee;
    ca[i] = (signed char)(i * 13);
    fa[i] = (float)((i * 37) % 101) * 0.25f - 12.5f;
    fb[i] = (float)((i * 53) % 97) * 0.125f - 6.0f;
    fc[i] = -1;
    da[i] = (double)((i * 41) % 103) * 0.5 - 25.0;
    dc[i] = -1;
  }
  for (int i = 0; i < 3 * N; i++) ua[i] = (unsigned char)(i * 37 + (i >> 3));
}

int main(void) {
  static const int lens[] = {0, 1, 2, 3, 4, 7, 8, 15, 16, 17, 31, 32, 33, 100, 999, 1000};
  for (unsigned t = 0; t < sizeof lens / sizeof lens[0]; t++) {
    int n = lens[t];
    reset();
    printf("%d:", n);
    printf(" %d %ld %ld %d %u", sum_i32(ia, n), sum_i64(la, n), dot_i32(ia, ib, n), sum_bytes(ua, n), min_u32((const unsigned *)ib, n));
    if (n > 0) printf(" %d", max_i32(ia, n));
    printf(" %d %d %d", count_eq(ia, ia[n / 2], n), count_eq(ia, 12345, n), count_lt(ca, 17, n));
    printf(" %a %a", sum_f64(da, n), dot_f32(fa, fb, n));
    add_i32(ic, ia, ib, n);
    HASH(ic, N);
    mul_i16(sc, sa, sb, n);
    HASH(sc, N);
    xor_u8(uc, ua, 0x5a, n);
    HASH(uc, N);
    for (int i = 0; i < N; i++) fc[i] = fb[i];
    saxpy(fc, fa, 1.5f, n);
    HASH((const unsigned *)fc, N);
    scale_f64(dc, da, -0.75, n);
    HASH((const unsigned long *)dc, N);
    abs_i32(ic, ib, n);
    HASH(ic, N);
    clamp_i32(ic, ia, -300, 450, n);
    HASH(ic, N);
    widen(ic, sa, n);
    HASH(ic, N);
    narrow(sc, ia, n);
    HASH(sc, N);
    fill(ic, -50, n);
    HASH(ic, N);
    to_float(fc, ia, n);
    HASH((const unsigned *)fc, N);
    shift((unsigned *)ic, (const unsigned *)ib, n);
    HASH(ic, N);
    max_f32(fc, fa, fb, n);
    HASH((const unsigned *)fc, N);
    to_int(ic, fa, n);
    HASH(ic, N);
    rgb_gray(uc, ua, n);
    HASH(uc, N);
    select_i64(lc, la, lb, n);
    HASH(lc, N);
    printf("\n");
  }
  return 0;
}
