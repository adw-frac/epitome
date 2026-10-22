// Drives neon_narrow.ll on values at the edges of each range.
#include <stdio.h>
#include <arm_neon.h>
void shifts(int16x4_t *, uint16x4_t *, int16x4_t *, uint16x4_t *, uint16x4_t *, int16x4_t *, const int32x4_t *, const uint32x4_t *);
int main(void) {
    int v[12] = {1000000, -1000000, 262143, -262145, 15, -17, 2147483647, -2147483647 - 1, 131071, 131072, 7, -8};
    for (int t = 0; t < 3; t++) {
        int32x4_t w = vld1q_s32(v + 4 * t); uint32x4_t u = vreinterpretq_u32_s32(w);
        int16x4_t a, c, g; uint16x4_t b, d, e;
        shifts(&a, &b, &c, &d, &e, &g, &w, &u);
        short *pa = (short *)&a, *pc = (short *)&c, *pg = (short *)&g; unsigned short *pb = (unsigned short *)&b, *pd = (unsigned short *)&d, *pe = (unsigned short *)&e;
        for (int i = 0; i < 4; i++) printf("%d %u %d %u %u %d | ", pa[i], pb[i], pc[i], pd[i], pe[i], pg[i]);
        printf("\n");
    }
    return 0;
}
