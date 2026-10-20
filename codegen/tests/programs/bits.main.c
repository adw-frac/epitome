// Calls the functions in bits.c on edge values and prints what they return.
#include <stdio.h>

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;

int clz16(u16), clz32(u32), clz64(u64), ctz16(u16), ctz32(u32), ctz64(u64);
int pop8(u8), pop32(u32), pop64(u64);
u16 swap16(u16);
u32 swap32(u32);
u64 swap64(u64);
u32 rotl32(u32, int);
u64 rotr64(u64, int);
u32 funnel(u32, u32, int);
int bit_branches(u64, u32);
static int hits;
void hit(int k) { hits = hits * 3 + k; }

static const u64 values[] = {
    0, 1, 2, 3, 0x80, 0xff, 0x100, 0x8000, 0xffff, 0x10000, 0x12345678, 0x80000000, 0xffffffff,
    0x100000000ULL, 0x123456789abcdef0ULL, 0x8000000000000000ULL, 0xffffffffffffffffULL, 0x5555555555555555ULL,
};

int main(void) {
    for (unsigned i = 0; i < sizeof values / sizeof values[0]; i++) {
        u64 v = values[i];
        printf("%llx: clz %d %d %d ctz %d %d %d pop %d %d %d swap %x %x %llx\n", v, clz16((u16)v), clz32((u32)v),
               clz64(v), ctz16((u16)v), ctz32((u32)v), ctz64(v), pop8((u8)v), pop32((u32)v), pop64(v),
               swap16((u16)v), swap32((u32)v), swap64(v));
        hits = 0;
        int nb = bit_branches(v, (u32)(v >> 3));
        printf("  bits %d %d\n", nb, hits);
        printf("  rot %x %llx %x %x %llx %x\n", rotl32((u32)v, (int)i), rotr64(v, (int)i * 5), rotl32((u32)v, -3),
               funnel((u32)v, (u32)(v >> 32), (int)i), rotr64(v, 64), funnel((u32)v, 0x87654321, 0));
    }
    return 0;
}
