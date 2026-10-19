// Integers wider than a register: __int128 arithmetic, shifts, comparisons,
// division (the runtime's __udivti3 and friends), memory, arguments in odd
// positions (AAPCS64 starts them in an even register), and the i65 that
// LLVM's closed forms of sums use.

typedef __int128 i128;
typedef unsigned __int128 u128;

u128 mul_wide(unsigned long a, unsigned long b) { return (u128)a * b; }
i128 mac(i128 acc, long a, long b) { return acc + (i128)a * b; }
u128 shl(u128 x, int n) { return x << n; }
u128 shr(u128 x, int n) { return x >> n; }
i128 sar(i128 x, int n) { return x >> n; }
u128 rot(u128 x) { return (x << 37) | (x >> 91); }
int cmp(i128 a, i128 b) { return (a < b) + 2 * (a == b) + 4 * ((u128)a > (u128)b); }
u128 udiv(u128 a, u128 b) { return a / b; }
i128 sdiv(i128 a, i128 b) { return a / b; }
u128 umod(u128 a, u128 b) { return a % b; }
long narrow(i128 x) { return (long)(x >> 3); }
i128 widen(int x) { return x; }
u128 odd_place(long a, u128 b, long c) { return b * 3 + a - c; }
u128 last_place(long a, long b, long c, long d, long e, long f, long g, u128 x) { return x + a + b + c + d + e + f + g; }

u128 total(const u128 *p, int n) {
    u128 s = 0;
    for (int i = 0; i < n; i++) s += p[i];
    return s;
}

void fill(u128 *p, int n, u128 step) {
    for (int i = 0; i < n; i++) p[i] = step * (u128)i;
}

// LLVM makes this a closed form computed in i65.
long sum_to(long n, long acc) {
    if (n == 0) return acc;
    return sum_to(n - 1, acc + n);
}

u128 callback(u128 (*f)(u128, int), u128 x) { return f(x, 5) + f(x, 70); }
