// Drives neon.ll on random data, a NaN in one round.
#include <stdio.h>
#include <arm_neon.h>
#include <string.h>
void ops(float32x4_t *, uint8x16_t *, int16x8_t *, uint32x4_t *);
float red(const float32x4_t *, const uint8x16_t *, const int32x4_t *, const float32x2_t *, const float64x2_t *);
int main(void) {
    unsigned s = 1;
    for (int t = 0; t < 10; t++) {
        float32x4_t f[8]; uint8x16_t u[4]; int16x8_t h[4]; uint32x4_t w[4]; int32x4_t q[1]; float32x2_t g[1]; float64x2_t d[1];
        unsigned char raw[512]; for (int i = 0; i < 512; i++) { s = s * 1103515245 + 12345; raw[i] = s >> 16; }
        float fv[8]; for (int i = 0; i < 8; i++) fv[i] = (float)(int)(raw[i] - 128) / 7.0f + (i == 3 && t == 2 ? __builtin_nanf("") : 0);
        f[0] = vld1q_f32(fv); f[1] = vld1q_f32(fv + 4);
        memcpy(u, raw + 64, 64); memcpy(h, raw + 128, 64); memcpy(w, raw + 192, 64); memcpy(q, raw + 256, 16);
        g[0] = vld1_f32(fv + 2); d[0] = (float64x2_t){fv[5], fv[6]};
        ops(f, u, h, w);
        unsigned hsh = 0; unsigned char *p = (unsigned char *)f; for (int i = 32; i < 112; i++) hsh = hsh * 31 + p[i];
        p = (unsigned char *)u; for (int i = 32; i < 64; i++) hsh = hsh * 31 + p[i];
        p = (unsigned char *)h; for (int i = 32; i < 64; i++) hsh = hsh * 31 + p[i];
        p = (unsigned char *)w; for (int i = 32; i < 64; i++) hsh = hsh * 31 + p[i];
        printf("%08x %a\n", hsh, red(f, u, q, g, d));
    }
    return 0;
}
