// Calls the functions in fminmax.c on pairs of special values (NaNs,
// zeros of both signs, infinities) and others, and prints the results:
// "nan" for a NaN, whose payload is not specified, else the value.
#include <math.h>
#include <stdio.h>
#include <string.h>
typedef float f32 __attribute__((ext_vector_type(4)));
typedef double f64 __attribute__((ext_vector_type(2)));
typedef float f32x8 __attribute__((ext_vector_type(8)));
typedef double f64x4 __attribute__((ext_vector_type(4)));
void minmax_f32(f32 *, const f32 *, const f32 *);
void minmax_f64(f64 *, const f64 *, const f64 *);
void minmax_f32x8(f32x8 *, const f32x8 *, const f32x8 *);
void minmax_f64x4(f64x4 *, const f64x4 *, const f64x4 *);
static const double values[] = {0.0, -0.0, 1.0, -1.0, 2.5, -87.5, 1e30, INFINITY, -INFINITY, NAN, -NAN};
#define N (sizeof values / sizeof values[0])
static void show(double x) {
    if (isnan(x)) printf(" nan");
    else printf(" %s%g", signbit(x) ? "-" : "+", fabs(x));
}
int main(void) {
    // Every pair, a lane at a time, in each type.
    for (unsigned i = 0; i < N; i++) {
        for (unsigned j = 0; j < N; j++) {
            f32 a = values[i], b = values[j], o32[2];
            f64 c = values[i], d = values[j], o64[2];
            f32x8 e = values[i], f = values[j], o8[2];
            f64x4 g = values[i], h = values[j], o4[2];
            a[1] = values[j]; b[1] = values[i];
            e[5] = values[j]; f[5] = values[i];
            minmax_f32(o32, &a, &b);
            minmax_f64(o64, &c, &d);
            minmax_f32x8(o8, &e, &f);
            minmax_f64x4(o4, &g, &h);
            printf("%u %u:", i, j);
            for (int k = 0; k < 2; k++) {
                show(o32[k][0]); show(o32[k][1]); show(o64[k][1]); show(o8[k][7]); show(o8[k][5]); show(o4[k][3]);
            }
            printf("\n");
        }
    }
    return 0;
}
