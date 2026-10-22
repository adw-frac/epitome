// Drives crypto.ll: CRC32 (both polynomials, each width), rounds of SHA-1,
// SHA-256 and SHA-512 and their schedules, and AES rounds.
#include <stdio.h>
#include <stdint.h>
#include <arm_neon.h>
uint32_t crc(const uint8_t *, int, uint32_t); void sha256(uint32x4_t *, const uint32x4_t *); void sha1(uint32x4_t *, uint32_t *, const uint32x4_t *);
void sha512(uint64x2_t *, const uint64x2_t *); void aes(uint8x16_t *, const uint8x16_t *);
static void d(const void *p, int n) { const uint8_t *b = p; unsigned h = 0; for (int i = 0; i < n; i++) h = h * 131 + b[i]; printf("%08x ", h); }
int main(void) {
    uint8_t buf[64]; for (int i = 0; i < 64; i++) buf[i] = i * 37 + 5;
    printf("%08x\n", crc(buf, 61, 0xffffffff));
    uint32x4_t s[2], w[4]; for (int i = 0; i < 4; i++) w[i] = vld1q_u32((const uint32_t *)(buf + 16 * i)); s[0] = w[3]; s[1] = w[2];
    sha256(s, w); d(s, 32);
    uint32_t e = 99; sha1(s, &e, w); d(s, 32); printf("%u ", e);
    uint64x2_t t[2], v[5]; for (int i = 0; i < 5; i++) v[i] = vld1q_u64((const uint64_t *)(buf + 8 * i)); t[0] = v[4]; t[1] = v[0];
    sha512(t, v); d(t, 32);
    uint8x16_t a[2], k[5]; for (int i = 0; i < 5; i++) k[i] = vld1q_u8(buf + 8 * i); a[0] = k[1];
    aes(a, k); d(a, 32); printf("\n");
    return 0;
}
