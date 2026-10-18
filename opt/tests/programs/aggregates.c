// Structs, arrays and unions used as local variables: the shapes SROA
// splits. Small structs are passed and returned in registers, so the
// compiler stores and loads them as whole integers.
#include <stdio.h>
#include <string.h>

struct point { int x, y; };
struct rect { struct point lo, hi; };
struct mixed { char tag; double value; short pair[2]; };
struct wide { long a, b, c; };   // returned through memory
union pun { float f; unsigned u; };

static struct point add(struct point a, struct point b) {
    struct point r = { a.x + b.x, a.y + b.y };
    return r;
}

static struct point scale(struct point p, int k) {
    p.x *= k;
    p.y *= k;
    return p;
}

static int area(struct rect r) {
    struct point d = { r.hi.x - r.lo.x, r.hi.y - r.lo.y };
    return d.x * d.y;
}

static struct mixed make(char t, double v, short a, short b) {
    struct mixed m;
    m.tag = t;
    m.value = v;
    m.pair[0] = a;
    m.pair[1] = b;
    return m;
}

static struct wide spread(long x) {
    struct wide w = { x, x * 2, x * 3 };
    return w;
}

static unsigned float_bits(float f) {
    union pun p;
    p.f = f;
    return p.u;
}

static int sum4(int a, int b, int c, int d) {
    int v[4] = { a, b, c, d };
    int s = 0;
    s += v[0];
    s += v[1] * 2;
    s += v[2] * 3;
    s += v[3] * 4;
    return s;
}

static long swap_halves(long x) {
    union { long l; int i[2]; } u;
    u.l = x;
    int t = u.i[0];
    u.i[0] = u.i[1];
    u.i[1] = t;
    return u.l;
}

int main(int argc, char **argv) {
    (void)argv;
    int k = argc + 2; // 3
    struct point a = { k, k * 2 }, b = { 10, -4 };
    struct point c = scale(add(a, b), k);
    printf("point %d %d\n", c.x, c.y);
    struct rect r = { { 1, 2 }, { 1 + k * 4, 2 + k * 5 } };
    printf("area %d\n", area(r));
    struct mixed m = make('q', 2.5 * k, (short)(k * 100), (short)-k);
    printf("mixed %c %.2f %d %d\n", m.tag, m.value, m.pair[0], m.pair[1]);
    struct wide w = spread(k * 1000L);
    printf("wide %ld %ld %ld\n", w.a, w.b, w.c);
    printf("bits %08x %08x\n", float_bits(1.5f * k), float_bits(-0.0f));
    printf("sum4 %d\n", sum4(k, k + 1, k + 2, k + 3));
    printf("swap %lx\n", swap_halves(0x1122334455667788L + k));
    char buf[16];
    memset(buf, 0, sizeof buf);
    snprintf(buf, sizeof buf, "%d-%d", c.x, c.y);
    printf("buf %s\n", buf);
    return 0;
}
