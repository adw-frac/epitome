// Structs too big for registers: returned through the address the caller
// passes (sret; AArch64 passes it in x8), and passed as a pointer to a copy.
// Both ways across the boundary: these call ones in structs.main.c.

struct big {
    long a, b, c, d;
};
struct mixed {
    int i;
    double x;
    char s[20];
};

struct big make_big(long x);
long sum_big(struct big b);
struct mixed make_mixed(int i);

struct big make(long x) {
    struct big r = {x, x * 2, x * 3, x * 4};
    return r;
}

long take(struct big b) { return b.a + b.b * 10 + b.c * 100 + b.d * 1000; }

struct big twice(struct big b) {
    struct big r = {b.a * 2, b.b * 2, b.c * 2, b.d * 2};
    return r;
}

struct mixed mix(int i, double x) {
    struct mixed m = {i, x, "epitome"};
    m.s[i % 9] = 'X';
    return m;
}

long round_trip(long x) {
    struct big b = make_big(x);
    struct big c = twice(b);
    struct mixed m = make_mixed((int)x);
    return sum_big(c) + take(make(x)) + m.i + (long)m.x + m.s[0];
}
