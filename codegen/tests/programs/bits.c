// Bit counts and byte swaps at every width: where a machine has no
// instruction for one, the code generator widens it or expands it.

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;

int clz16(u16 a) { return a ? __builtin_clzs(a) : 16; }
int clz32(u32 a) { return a ? __builtin_clz(a) : 32; }
int clz64(u64 a) { return a ? __builtin_clzll(a) : 64; }
int ctz16(u16 a) { return a ? __builtin_ctzs(a) : 16; }
int ctz32(u32 a) { return a ? __builtin_ctz(a) : 32; }
int ctz64(u64 a) { return a ? __builtin_ctzll(a) : 64; }
int pop8(u8 a) { return __builtin_popcount(a); }
int pop32(u32 a) { return __builtin_popcount(a); }
int pop64(u64 a) { return __builtin_popcountll(a); }
u16 swap16(u16 a) { return __builtin_bswap16(a); }
u32 swap32(u32 a) { return __builtin_bswap32(a); }
u64 swap64(u64 a) { return __builtin_bswap64(a); }
u32 rotl32(u32 a, int n) { return (a << (n & 31)) | (a >> (-n & 31)); }
u64 rotr64(u64 a, int n) { return (a >> (n & 63)) | (a << (-n & 63)); }
u32 funnel(u32 hi, u32 lo, int n) { return n & 31 ? (hi << (n & 31)) | (lo >> (32 - (n & 31))) : hi; }

// Branches on one bit, low and high (tbz and tbnz with the bit's number).
void hit(int k);
int bit_branches(u64 a, u32 b) {
    int n = 0;
    if (a & 1) hit(n += 1);
    if (a & (1ull << 5)) hit(n += 2);
    if (!(a & (1ull << 31))) hit(n += 4);
    if (a & (1ull << 40)) hit(n += 8);
    if (!(a & (1ull << 63))) hit(n += 16);
    if (b & (1u << 7)) hit(n += 32);
    if (!(b & (1u << 31))) hit(n += 64);
    return n;
}
