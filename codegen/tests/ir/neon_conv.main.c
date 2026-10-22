// Drives neon_conv.ll on ties, NaN, overflow and negatives.
#include <stdio.h>
#include <arm_neon.h>
#include <string.h>
void conv(int32x4_t *, uint32x4_t *, const float32x4_t *, int16x4_t *, uint16x4_t *, uint16x4_t *, const int32x4_t *, const uint32x4_t *);
int main(void) {
    float vals[16] = {0.5f, 1.5f, -2.5f, 2.4999f, -0.5f, 3e9f, -3e9f, __builtin_nanf(""), 1e20f, -1e20f, 7.75f, -7.25f, 65535.5f, 0.0f, -0.0f, 4294967040.0f};
    int wv[8] = {40000, -40000, 123, -5, 70000, 65535, -1, 32767};
    for (int t = 0; t < 4; t++) {
        float32x4_t f = vld1q_f32(vals + 4 * t); int32x4_t w = vld1q_s32(wv + 4 * (t % 2)); uint32x4_t uw = vreinterpretq_u32_s32(w);
        int32x4_t o[5]; uint32x4_t u[5]; int16x4_t n; uint16x4_t m, k;
        conv(o, u, &f, &n, &m, &k, &w, &uw);
        int *oi = (int *)o; unsigned *ui = (unsigned *)u; short *ni = (short *)&n; unsigned short *mi = (unsigned short *)&m, *ki = (unsigned short *)&k;
        for (int i = 0; i < 20; i++) printf("%d ", oi[i]); printf("| ");
        for (int i = 0; i < 20; i++) printf("%u ", ui[i]); printf("| ");
        for (int i = 0; i < 4; i++) printf("%d %u %u ", ni[i], mi[i], ki[i]); printf("\n");
    }
    return 0;
}
