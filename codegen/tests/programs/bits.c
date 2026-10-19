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
