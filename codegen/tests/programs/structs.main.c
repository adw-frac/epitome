// Calls the functions in structs.c, and is called by them.
#include <stdio.h>

struct big {
    long a, b, c, d;
};
struct mixed {
    int i;
    double x;
    char s[20];
};

struct big make(long x);
long take(struct big b);
struct big twice(struct big b);
struct mixed mix(int i, double x);
long round_trip(long x);

struct big make_big(long x) {
    struct big r = {x + 1, x + 2, x + 3, x + 4};
    return r;
}
long sum_big(struct big b) { return b.a + b.b + b.c + b.d; }
struct mixed make_mixed(int i) {
    struct mixed m = {i * 3, i * 0.5, "clang"};
    return m;
}

int main(void) {
    struct big b = make(5);
    printf("%ld %ld %ld %ld\n", b.a, b.b, b.c, b.d);
    printf("%ld\n", take(b));
    struct big t = twice(b);
    printf("%ld %ld %ld %ld\n", t.a, t.b, t.c, t.d);
    for (int i = 0; i < 4; i++) {
        struct mixed m = mix(i, i * 1.25);
        printf("%d %g %s\n", m.i, m.x, m.s);
    }
    printf("%ld %ld\n", round_trip(3), round_trip(-7));
    return 0;
}
